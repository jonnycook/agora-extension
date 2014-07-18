define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class SharedWithYouView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		udpateEntries: ->
			entries = []
			@agora.db.tables.shared_objects.records.each (record) =>
				if record.get('with_user_id') == @agora.user.get('id')
					entries.push _.extend(_.clone(record._values), id:record.get 'id')
			@entries.set entries

		isInBelt: (value, sharedObject) ->
			ObjectReference = @agora.modelManager.getModel('ObjectReference')
			objectReferences = ObjectReference.findAll({object_user_id:parseInt(sharedObject.get('user_id').substr(1)), object:sharedObject.get('object')})

			for objectReference in objectReferences
				rootElements = @agora.user.get('belts').get(0).get('elements').findAll({element_type:'ObjectReference', element_id:objectReference.get('id')})
				if rootElements.length
					value.set true
					return

			value.set false


		init: (args) ->
			@object = @agora.View.views.ShoppingBar.null.currentState().shareObject()
			@entries = @clientValue()
			@udpateEntries()

			@data = 
				entries:@clientArray @ctx, @agora.user.get('sharedWithMe'), (obj, onRemove, ctx) =>
					inBelt = @clientValue false
					@isInBelt inBelt, obj

					type = if obj.get('object') == '/'
						'Belt'
					else
						[table] = obj.get('object').split '.'
						if table == 'decisions'
							'Decision'
						else if table == 'belts'
							'Belt'

					title:
						if obj.get('object') == '/'
							ctx().clientValue 'Belt'
						else
							ctx().clientValue obj.field 'title'

					userName:obj.get 'user_name'
					seen:ctx().clientValue obj.field 'seen'
					inBelt:inBelt
					id:obj.get 'id'
					type:type
				status:@clientValue()

			@observeObject @agora.db.tables.shared_objects.records, =>
				@udpateEntries()

		methods:
			seen: ->
				@agora.user.get('sharedWithMe').each (instance) =>
					instance.set 'seen', true
			inBelt: (view, id, inBelt) ->
				sharedObject = @agora.db.tables.shared_objects.byId(id)

				if inBelt
					objectReference = @agora.modelManager.getModel('ObjectReference').create
						object_user_id:sharedObject.get('user_id').substr(1)
						object:sharedObject.get 'object'

					@agora.modelManager.getModel('BeltElement').create belt_id:@agora.user.get('belts').get(0).get('id'), element_type:'ObjectReference', element_id:objectReference.get 'id'
				else
					ObjectReference = @agora.modelManager.getModel('ObjectReference')
					objectReferences = ObjectReference.findAll({object_user_id:parseInt(sharedObject.get('user_id').substr(1)), object:sharedObject.get('object')})

					for objectReference in objectReferences
						rootElements = @agora.user.get('belts').get(0).get('elements').findAll({element_type:'ObjectReference', element_id:objectReference.get('id')})
						rootElement.delete() for rootElement in rootElements


			click: (view, id) ->
				sharedObject = @agora.db.tables.shared_objects.byId(id)
				object = sharedObject.get 'object'
				storeId = sharedObject.get('user_id').substr(1)
				@agora.updater.subscribe storeId, '@', =>
					@agora.updater.subscribe storeId, object, =>
						if object == '/'
							user = agora.modelManager.getInstance('User', sharedObject.get('user_id'))
							util.shoppingBar.pushRootState user
						else
							parts = object.split '.'
							if parts[0] == 'decisions'
								decision = @agora.modelManager.getInstance('Decision', 'G' + parts[1])
								util.shoppingBar.pushDecisionState decision
							else if parts[0] == 'belts'
								decision = @agora.modelManager.getInstance('Belt', 'G' + parts[1])
								util.shoppingBar.pushBeltState decision
