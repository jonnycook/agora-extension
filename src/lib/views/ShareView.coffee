define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class ShareView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		udpateEntries: ->
			entries = []
			@agora.db.tables.shared_objects.records.each (record) =>
				if record.get('user_id') == @agora.user.get('id') && record.get('object') == @object
					entries.push _.extend(_.clone(record._values), id:record.globalId())
			@entries.set entries

		initAsync: (args, done) ->
			getObject = (tableName, id) =>
				table = @agora.db.table(tableName)
				id = @agora.db.globalToLocalMapping?[tableName]?[id] ? id
				table.byId id

			init = =>
				@entries = @clientValue()
				title = ''
				if @object == '/'
				else
					[table, id] = @object.split '.'
					if table == 'decisions'
						decision = getObject('decisions', 'G' + id)
						title = decision.get 'share_title'
						message = decision.get 'share_message'
					else if table == 'belts'
						belt = getObject('belts', 'G' + id)
						title = belt.get 'title'
						message = ''#decision.get 'share_message'


				@udpateEntries()
				@data = 
					entries:@entries
					status:@clientValue()
					title:title
					message:message

				@observeObject @agora.db.tables.shared_objects.records, =>
					@udpateEntries()

				done()

			if args && args != 'ShoppingBar'
				@resolveObject args, (obj) =>
					userId = null
					@object = if obj.isA 'Decision'
						"decisions.#{obj.record.globalId().substr 1}"
					else if obj.isA 'Belt'
						"belts.#{obj.record.globalId().substr 1}"
					else if obj.isA 'ObjectReference'
						obj.get 'object'

					init()
			else
				@object = @agora.View.views.ShoppingBar.null.currentState().shareObject()
				init()

		methods:
			update: (view, title, message) ->
				params = 
					object:@object
					title:title
					message:message
				# @agora.updater.transport.ws.send "m#{@agora.user.saneId()}\tshare/update\t#{JSON.stringify params}"
				@agora.updater.transport.messageStream.sendMessage 'message', @agora.user.saneId(), 'share/update', JSON.stringify params

			add: (view, title, message, email) ->
				tracking.event 'Collaboration', 'add'
				params = 
					with:email
					object:@object
					title:title
					message:message
				# @agora.updater.transport.ws.send "m#{@agora.user.saneId()}\tshare/create\t#{JSON.stringify params}"
				@agora.updater.transport.messageStream.sendMessage 'message', @agora.user.saneId(), 'share/create', JSON.stringify params



			delete: (view, id) ->
				tracking.event 'Collaboration', 'remove'
				params = 
					id:id.substr 1
				# @agora.updater.transport.ws.send "m#{@agora.user.saneId()}\tshare/delete\t#{JSON.stringify params}"
				@agora.updater.transport.messageStream.sendMessage 'message', @agora.user.saneId(), 'share/delete', JSON.stringify params
