define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy'], (View, Site, Formatter, util, _, taxonomy) ->	
	class ItemView extends View
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

						else if @item.dropped
							newObj = @item.dropped obj, dropAction

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
			else if @itemType
				@item.dropped obj, dropAction

		initAsync: (args, done) ->
			@data = @clientValue()
			@itemCtx = @context()
			@element = @agora.modelManager.getModel(@args.elementType).withId @args.elementId, false
			if @element
				@additionalData = {}
				@element.observe (mutation) =>
					if mutation.type == 'deleted'
						@destruct()

				update = (cb) =>
					if @descriptor
						@stopObservingObject @descriptor.get('element')

					delete @objectReference
					delete @getObj
					delete @descriptor
					delete @itemType

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

						if @public
							@itemType = 'Unauthorized'
							if object == '/'
								@additionalData.objectType = 'Belt'
							else
								[table, id] = object.split '.'
								if table == 'decisions'
									@additionalData.objectType = 'Decision'
								else if table == 'belts'
									@additionalData.objectType = 'Belt'
						else
							@agora.updater.transport.whenObject @objectReference.get('object_user_id'), ['@', object],
								=>
									delete @itemType
									if object == '/'
										@itemType = 'SharedBelt'
										# @obj = @sharedObject
										setTimeout (=>@updateItem()), 200
									else
										[table, id] = object.split '.'
										if table == 'decisions'
											@obj = @agora.modelManager.getInstance('Decision', "G#{id}")
											setTimeout (=>@updateItem()), 200
										else if table == 'belts'
											@obj = @agora.modelManager.getInstance('Belt', "G#{id}")
											setTimeout (=>@updateItem()), 200
								=>
									@obj = null
									@itemType = 'Unauthorized'
									if object == '/'
										@additionalData.objectType = 'Belt'
									else
										[table, id] = object.split '.'
										if table == 'decisions'
											@additionalData.objectType = 'Decision'
										else if table == 'belts'
											@additionalData.objectType = 'Belt'

									# delete @itemType
									setTimeout (=>@updateItem()), 200
		
					@updateItem cb


				if !@public
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
			else
				done()
			
		updateItem: (cb=null) ->
			@initItem =>
				if @obj
					if @descriptor && @obj.isNull()
						data = descriptor:@descriptor.get('descriptor'), icon:taxonomy.icon @descriptor.get('descriptor')?.product?.type
						_.extend data, @additionalData if @additionalData
						@data.set data
						cb?()
					else
						@item.getData (data) =>
							data.descriptor = @descriptor.get('descriptor') if @descriptor
							data.id = @obj.get 'id'
							_.extend data, @additionalData if @additionalData
							@data.set data
							cb?()
				else if @itemType
					@item.getData (data) =>
						_.extend data, @additionalData if @additionalData
						@data.set data
						cb?()
				else
					@data.set null
					cb?()

		initItem: (cb) ->
			@itemCtx.clear()
			if @obj || @itemType
				if @descriptor && (!@obj || @obj.isNull())
					delete @item
					cb()
				else
					type = @itemType ? if @obj.model.name == 'ProductVariant' then 'Product' else @obj.model.name
					@getItem type, @obj, (item) =>
						@item = item
						cb()
			else
				cb()

		getItem: (type, obj, cb) ->
			@agora.background.require [@itemClass type], (klass) =>
				item = new klass
				item.itemView = item.view = @
				item.obj = obj
				item.ctx = @itemCtx
				item.init?()
				if item.initAsync
					item.initAsync -> cb item
				else
					cb item

		hasMethod: (name) -> @methods[name] || @item?.methods?[name]

		method: (name) ->
			if @methods[name]
				@methods[name]
			else
				@item.methods[name]

		delete: ->
			if @slot
				@slot.set 'element_type', null
				@slot.set 'element_id', null
			else
				_activity 'remove', @element, @element.get('element')
				obj = @element.get('element')
				@element.delete()
				# if obj.modelName in ['ObjectReference']
				# 	obj.delete()

		methods:
			delete: ->
				@delete()

			click: (view) ->
				@item?.methods?.click?.call @item, view

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