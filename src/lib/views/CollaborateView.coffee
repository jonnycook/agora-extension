define ['View', 'Site', 'Formatter', 'util', 'underscore', 'model/ObservableArray', 'model/ObservableValue'], (View, Site, Formatter, util, _, ObservableArray, ObservableValue) ->
	filteredArray = (ctx, subject, output, test, reversed=false) ->
		add = if reversed
			(obj) -> output.unshift obj
		else
			(obj) -> output.push obj
		subject.each (record) =>
			if test record
				add record

		ctx.observeObject subject, (mutation) =>
			if mutation.type == 'insertion'
				if test mutation.value
					add mutation.value
			else if mutation.type == 'deletion'
				if test mutation.value
					output.remove mutation.value

	class CollaborateView extends View
		@nextId: 0
		@id: (args) -> 
			if args == 'ShoppingBar'
				args
			else
				++ @nextId


		doInit: (obj) ->
				return if !@agora.user
				getObject = (modelName, id) =>
					model = @agora.modelManager.getModel(modelName)
					id = @agora.db.globalToLocalMapping?[model._table.name]?[id] ? id
					model.withId id, false

				@obj = obj
				@stateCtx.clear()

				userId = null
				object = null
				@object = if _.isString obj
					# userId = @agora.user.saneId()
					# if obj == '/'
					# 	object = @agora.user
					# else
					[table,id] = obj.split '.'
					object = @agora.modelManager.instanceForRecord(@agora.db.table(table).bySaneId(id))
					if object
						userId = parseInt object.record.storeId
						obj
				else if obj.isA 'Decision'
					object = obj
					userId = parseInt obj.record.storeId
					"decisions.#{obj.record.globalId().substr 1}"
				else if obj.isA 'Belt'
					object = obj
					userId = parseInt obj.record.storeId
					"belts.#{obj.record.globalId().substr 1}"
				else if obj.isA 'ObjectReference'
					userId = obj.get 'object_user_id'
					if obj.get('object') == '/'
						object = @agora.modelManager.getInstance 'User', "G#{userId}"
					else
						[table,id] = obj.get('object').split '.'
						object = @agora.modelManager.instanceForRecord(@agora.db.table(table).bySaneId(id))
					
					obj.get 'object'

				return if !@object

				# title = ''
				# if @object == '/'
				# else
				# 	[table, id] = @object.split '.'
				# 	if table == 'decisions'
				# 		decision = @agora.db.tables.decisions.byId('G' + id)
				# 		title = decision.get 'share_title'

				@collaborators = new ObservableArray
				filteredArray @stateCtx, @agora.db.tables.collaborators.records, @collaborators, 
					(record) => 
						`record.get('object_user_id') == userId` && record.get('object') == @object

				_nameMap = {}
				_next = {}
				nameMap = (model, id) ->
					key = "#{model}.#{id}"
					if _nameMap[key]
						_nameMap[key]
					else
						_next[model] ?= 0
						_nameMap[key] = "#{model} #{String.fromCharCode 65 + _next[model]++}"

				@activity = new ObservableArray
				filteredArray @stateCtx, @agora.db.tables.activity.records, @activity, ((record) =>
					curObj = getObject record.get('object_type'), record.get('object_id')
					while curObj
						if curObj.isA(object.modelName) && curObj.get('id') == object.get 'id'
							# console.debug record.get('timestamp'), record.get('type'), record.get('object_type'), record.get('object_id'), record.get('args')
							return true
						parent = curObj.record.owner()
						if parent
							# console.log 'parent', parent
							curObj = agora.modelManager.instanceForRecord parent
						else
							return false
					return false), true

				objectText = (inObject) =>

				objectData = (inObject) ->
					text = null
					model = null
					id = null
					if _.isString(inObject.model)
						obj = getObject inObject.model, inObject.id
						if obj
							return objectData obj
						else
							text = nameMap inObject.model, inObject.id
					else
						model = inObject.modelName
						id = inObject.get('id')
						if inObject.isA 'Product'
							text = if inObject.get('title') then inObject.get('title').substr(0, 10) + '...' else nameMap inObject.modelName, inObject.get 'id'
						else if inObject.isA('Decision') && inObject.equals(object) && inObject.get('share_title')
							text = inObject.get('share_title')
						else if inObject.isA('Belt') && inObject.equals(object) && inObject.get('title')
							text = inObject.get('title')
						else
							text = nameMap inObject.modelName, inObject.get 'id'

					text:text
					model:model
					id:id


				@data.set 
					owner:@agora.user.get('id') == 'G' + userId
					collaborators:@clientArray @stateCtx, @collaborators, (obj, onRemove, ctx) =>
						if obj.get('pending')
							name:obj.get('email')
							pending:true
							id:obj.get('invitation')
						else
							userWrapper = util.userWrapper obj.get 'user_id'

							ctx().onDestruct = =>
								userWrapper.destruct()

							abbreviation = ctx().clientValue()
							updateAbbreviation = ->
								if userWrapper.empty
									abbreviation.set obj.get('user_id')
								else
									abbreviation.set userWrapper.get('name')[0]
							updateAbbreviation()
							ctx().observe userWrapper.field('name'), updateAbbreviation


							name:ctx().clientValue userWrapper.field 'name'
							owner:`obj.get('user_id') == userId`
							id:obj.get('user_id')
							abbreviation:abbreviation
							color:util.colorForUser @agora.user, userWrapper

					activity:@clientArray @stateCtx, @activity, (entry, onRemove, ctx) =>
						pertainingObject = getObject entry.get('object_type'), entry.get('object_id')

						user = @agora.modelManager.getInstance('User', entry.get('generator_id'), false)
						userString = if user
							user.get('name')
						else
							 "User #{if entry.get('generator_id')[0] == 'G' then entry.get('generator_id').substr(1) else entry.get('generator_id')}"

						images = []

						numberForPreview = if entry.get('type') == 'convert'
							-1
						else 
							0

						num = entry.get('args').length + numberForPreview

						for i in [0...num]
							arg = entry.get('args')[i]
							if arg.model == 'Product'
								product = getObject arg.model, arg.id
								if product
									images.push ctx().clientValue product.field 'image'
							else if arg.model == 'Decision' 
								images.push 'decision'
							else if arg.model == 'Belt' 
								images.push 'belt'
							else if arg.model == 'Bundle' 
								images.push 'bundle'

						text = switch entry.get('type')
							when 'add'
								[objectData(entry.get('args')[0]), 'was added to', objectData(pertainingObject)]
							when 'remove'
								[objectData(entry.get('args')[0]), 'was removed from', objectData(pertainingObject)]
							when 'decision.select'
								[objectData(entry.get('args')[0]), 'was selected in', objectData(pertainingObject)]
							when 'decision.deselect'
								[objectData(entry.get('args')[0]), 'was deselected in', objectData(pertainingObject)]
							when 'convert'
								[objectData(entry.get('args')[0]), 'and', objectData(entry.get('args')[1]), 'was converted to', objectData(entry.get('args')[2]), 'in', objectData(pertainingObject)]
							when 'decision.setDescriptor'
								[objectData(pertainingObject), 'was edited']
							else

								['Something was done']

						if userString
							id = if entry.get('generator_id')[0] == 'G' then entry.get('generator_id').substr(1) else entry.get('generator_id')
							text = text.concat ['by', {text:userString, type:'user', color:util.colorForUser @agora.user, id}]

						date = new Date entry.get('timestamp')*1000
						type:entry.get('type')
						text:text
						images:images.slice 0, 4
						timestamp:date.toLocaleString()


		initAsync: (@args, done) ->
			@data = @clientValue()

			@stateCtx = @context()
			init = (obj) =>
				@doInit obj
				done()

			if @args
				if @args == 'ShoppingBar'
					if @agora.View.views.ShoppingBar.null.shareObject.get()
						init @agora.View.views.ShoppingBar.null.shareObject.get().object

					@agora.View.views.ShoppingBar.null.shareObject.observe (mutation) =>
						if @obj != mutation.value.object
							init mutation.value.object
				else
					@resolveObject @args, (obj) =>
						init obj
			else
				init @agora.View.views.ShoppingBar.null.currentState().shareObject()

		update: ->
			@doInit @agora.View.views.ShoppingBar.null.shareObject.get().object


		methods:
			# update: (view, title) ->
			# 	@agora.background.httpRequest "#{@agora.background.apiRoot}shared/update.php",
			# 		method: 'post'
			# 		data:
			# 			object:@object
			# 			title:title

			# add: (view, title, email) ->
			# 	@agora.background.httpRequest "#{@agora.background.apiRoot}shared/create.php",
			# 		method: 'post'
			# 		data:
			# 			with:email
			# 			object:@object
			# 			title:title
			# 		cb: (response) =>
			# 			if response != 'no user'
			# 				@data.status.set 'ok'
			# 			else
			# 				@data.status.set 'no user'

			delete: (view, id) ->
				shareObject = @agora.db.tables.shared_objects.selectFirst object:@object, with_user_id:'G' + id
				params = 
					id:shareObject.globalId().substr 1
				# @agora.updater.transport.ws.send "m#{@agora.user.saneId()}\tshare/delete\t#{JSON.stringify params}"
				@agora.updater.transport.messageStream.sendMessage 'message', @agora.user.saneId(), 'share/delete', JSON.stringify params

			deletePending: (view, id) ->
				params = 
					invitation:id
				# @agora.updater.transport.ws.send "m#{@agora.user.saneId()}\tshare/delete\t#{JSON.stringify params}"
				@agora.updater.transport.messageStream.sendMessage 'message', @agora.user.saneId(), 'share/delete', JSON.stringify params

