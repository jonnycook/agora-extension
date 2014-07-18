define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy'], (View, Site, Formatter, util, _, taxonomy) ->	
	class BarItemView extends View
		@nextId: 1
		@id: (args) -> 
			if args.container
				"#c.{args.container.type}.#{args.container.id}.#{args.type}.#{args.id}"
			else if args.type && args.id
				"#{args.type}.#{args.id}"
			else if args.elementType && args.elementId
				id = "#{args.elementType}.#{args.elementId}"
				if args.decisionId
					id += ".#{args.decisionId}"
				id
			else
				@nextId++

		dropped: (obj, dropAction) ->
			if @obj
				if obj.modelName == 'Datum'
					tracking.event 'ShoppingBar', 'addData'
					obj.set 'element_type', @obj.modelName
					obj.set 'element_id', @obj.get 'id'

				else if obj.modelName == 'Descriptor'
					if @descriptor
						@descriptor.set 'descriptor', obj.get 'descriptor'
						obj.delete()

					else if @obj.modelName == 'Decision'
						@obj.get('list').set 'descriptor', obj.get 'descriptor'
						obj.delete()

					else 
						obj.set 'element_type', @obj.modelName
						obj.set 'element_id', @obj.get 'id'
						@element.set 'element_type', obj.modelName
						@element.set 'element_id', obj.get 'id'

				else
					newObj = null
					if dropAction == 'createBundle'
							tracking.event 'ShoppingBar', 'createBundle'
							bundle = @agora.modelManager.getModel('Bundle').create()
							obj = util.resolveObject obj
							bundle.get('contents').add @obj
							bundle.get('contents').add obj

							_activity 'convert', @element, @obj, obj, bundle

							newObj = bundle
					else
						if @descriptor && @obj.isNull()
							@descriptor.set 'element_type', obj.modelName
							@descriptor.set 'element_id', obj.get 'id'

						else if @barItem.dropped
							newObj = @barItem.dropped obj, dropAction

					if newObj
						if @descriptor
							@descriptor.set 'element_type', newObj.modelName
							@descriptor.set 'element_id', newObj.get 'id'
						else if @element
							@element.set 'element_type', newObj.modelName
							@element.set 'element_id', newObj.get 'id'
						else if @slot
							@slot.set 'element_type', newObj.modelName
							@slot.set 'element_id', newObj.get 'id'
			else if @barItemType
				@barItem.dropped obj, dropAction

		# ripped: (obj) ->
		# 	@barItem.ripped obj

		onClientDisconnect: ->
			@destruct()

		initAsync: (args, done) ->
			@data = @clientValueNamed 'BarItemView.data'
			@barItemCtx = @context()
			@element = @agora.modelManager.getModel(@args.elementType).withId @args.elementId
			@additionalData = {}

			update = (cb) =>
				if @descriptor
					@stopObservingObject @descriptor.get('element')

				delete @objectReference
				delete @getObj
				delete @descriptor
				delete @barItemType

				@obj = @element.get('element')
				if @obj.modelName == 'Descriptor'
					@descriptor = @obj
					@obj = @obj.get 'element'
					@observeObject @descriptor.get('element'), update
				else if @obj.modelName == 'ObjectReference'
					@objectReference = @obj
					@obj = null
					@getObj = -> @objectReference
					object = @objectReference.get 'object'
					@additionalData.user = color:util.colorForUser @agora.user, @objectReference.get('object_user_id')

					@agora.updater.transport.whenObject @objectReference.get('object_user_id'), ['@', object],
						=>
							delete @barItemType
							if object == '/'
								@barItemType = 'SharedBelt'
								# @obj = @sharedObject
								setTimeout (=>@updateBarItem()), 200
							else
								[table, id] = object.split '.'
								if table == 'decisions'
									@obj = @agora.modelManager.getInstance('Decision', "G#{id}")
									setTimeout (=>@updateBarItem()), 200
								else if table == 'belts'
									@obj = @agora.modelManager.getInstance('Belt', "G#{id}")
									setTimeout (=>@updateBarItem()), 200
						=>
							@obj = null
							@barItemType = 'Unauthorized'
							if object == '/'
								@additionalData.objectType = 'Belt'
							else
								[table, id] = object.split '.'
								if table == 'decisions'
									@additionalData.objectType = 'Decision'
								else if table == 'belts'
									@additionalData.objectType = 'Belt'

							# delete @barItemType
							setTimeout (=>@updateBarItem()), 200
	
				@updateBarItem cb


			if @element.get('creator_id') && @element.get('creator_id') != @agora.user.get('id')
				creatorId = @element.get('creator_id').substr 1
				userWrapper = util.userWrapper creatorId
				@additionalData.creator =
					color:util.colorForUser @agora.user, creatorId
					name:@clientValue userWrapper.field 'name'

			# handles the checkboxes if the bar item happens to be in a decision
			if @element.modelName == 'ListElement' && args.decisionId
				selected = @clientValueNamed 'selected'
				_.merge @additionalData, selected:selected, decisionId:args.decisionId
				@decision = @agora.modelManager.getInstance('Decision', args.decisionId)

				updateSelected = =>
					selected.set @decision.get('selection').contains @element

				updateSelected()
				@decision.get('selection').observe updateSelected


			@observeObject @element.get('element'), update
			update done
		
		updateBarItem: (cb=null) ->
			@initBarItem =>
				if @obj
					if @descriptor && @obj.isNull()
						data = descriptor:@descriptor.get('descriptor'), icon:taxonomy.icon @descriptor.get('descriptor')?.product?.type
						_.extend data, @additionalData if @additionalData
						@data.set data
						cb?()
					else
						@barItem.getData (data) =>
							data.descriptor = @descriptor.get('descriptor') if @descriptor
							data.id = @obj.get 'id'
							_.extend data, @additionalData if @additionalData
							@data.set data
							cb?()
				else if @barItemType
					@barItem.getData (data) =>
						_.extend data, @additionalData if @additionalData
						@data.set data
						cb?()
				else
					@data.set null
					cb?()

		initBarItem: (cb) ->
			@barItemCtx.clear()
			if @obj || @barItemType
				if @descriptor && (!@obj || @obj.isNull())
					delete @barItem
					cb()
				else
					type = @barItemType ? if @obj.model.name == 'ProductVariant' then 'Product' else @obj.model.name
					@getBarItem type, @obj, (barItem) =>
						@barItem = barItem
						cb()
			else
				cb()

		getBarItem: (type, obj, cb) ->
			@agora.background.require ["views/ShoppingBarView/#{type}BarItem"], (klass) =>
				barItem = new klass
				barItem.barItemView = @
				barItem.obj = obj
				barItem.ctx = @barItemCtx
				barItem.init?()
				if barItem.initAsync
					barItem.initAsync -> cb barItem
				else
					cb barItem

		hasMethod: (name) -> @methods[name] || @barItem?.methods?[name]

		method: (name) ->
			if @methods[name]
				@methods[name]
			else
				@barItem.methods[name]

		delete: ->
			if @slot
				@slot.set 'element_type', null
				@slot.set 'element_id', null
			else
				_activity 'remove', @element, @element.get('element')
				obj = @element.get('element')
				@element.delete()
				if obj.modelName in ['ObjectReference']
					obj.delete()



		methods:
			delete: ->
				@delete()

			click: (view) ->
				@barItem?.methods?.click?.call @barItem, view

			reorder: (view, fromIndex, toIndex) ->
				util.reorder @obj.get('contents'), fromIndex, toIndex

			add: (view, type) ->
				composite = @agora.modelManager.getModel('Composite').createWithType type
				@obj.get('contents').add composite

			setSelected: (view, selected) ->
				if @decision
					if selected
						@decision.get('selection').add @element
						_activity 'decision.select', @decision, @element.get('element')
					else
						@decision.get('selection').remove @element
						_activity 'decision.deselect', @decision, @element.get('element')


