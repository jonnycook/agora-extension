define ['underscore', 'model/ModelInstance', 'CommandExecuter', 'model/ObservableValue', 'model/Event'], (_, ModelInstance, CommandExecuter, ObservableValue, Event) ->

	class UpdaterTransport
		constructor: (@updater) ->

	class WebSocketTransport extends UpdaterTransport
		polling: false
		constructor: ->
			super
			@updateQueue = []

		changesSent: (changes) ->
			@sentChanges = changes

		changesConfirmed: ->
			delete @sentChanges

		executeUpdate: (message) ->
			if 'userId' of message
				@updater.setUser parseInt message.userId

			@updater.disabled = true
			if _.isArray message.changes
				for changes in message.changes
					@updater.db.executeChanges changes
			else
				@updater.db.executeChanges message.changes
			@updater.disabled = false

		userChanged: ->
			if @ws
				@clientId = @updater.clientId = null
				@ws.close()
				delete @ws
				console.debug 'registering client'
				@registerClient (response) =>
					if response
						@createWebSocket()
					else
						@updater.setUser 0
			else
				@init()

		doInit: (messageType) ->
			console.debug 'sending client id %s', @clientId
			@updating = true
			data = 
				type:messageType
				clientId:@clientId

			if @sentChanges
				data.changes = JSON.stringify @sentChanges
				data.updateToken = @updateToken
			else if @_hasChanges
				delete @_hasChanges
				changes = @updater.compileChanges()
				@updater.clearChanges()
				if changes
					@changesSent changes
					data.changes = JSON.stringify changes
					data.updateToken = @updateToken
			@ws.send JSON.stringify data

		createWebSocket: (onInit) ->
			console.debug 'creating websocket...'
			@ws = new WebSocket "ws://#{@server}:8080"
			# @ws.onerror = => console.debug arguments...

			@ws.onclose = =>
				console.debug 'socket close'
				@open = false
				@close = true
				if @clientId
					setTimeout (=>@createWebSocket onInit), 1000


			@ws.onmessage = (message) =>
				if message.data == 'invalid client id'
					@registerClient =>
						@doInit 'changeClient'
					console.debug 'invalid client id'
					return

				message = JSON.parse message.data
				console.debug message

				switch message.type
					when 'update'
						if @updating
							@updateQueue.push message
						else
							@executeUpdate message

					when 'init'
						@updating = false

						if @sentChanges
						# if @updateToken == message.updateToken
							@changesConfirmed()

							@updateToken = message.newUpdateToken

							if @_hasChanges || @moreChanges
								delete @_hasChanges
								delete @moreChanges
								@hasChanges()

						@updater.reset() if @started
						@started = true

						@executeUpdate message

						onInit?()
						if @updateQueue.length
							for update in @updateQueue
								@executeUpdate update
							@updateQueue = []

					when 'response'
						# TODO: Handle "fail" response
						# if message.updateToken == @updateToken
						@changesConfirmed()
						@updateToken = message.newUpdateToken
						if message.mapping?
							@updater.db.addMapping message.mapping
						@updating = false
						# @updateArgs.success? message
						# delete @updateArgs

						if @moreChanges
							delete @moreChanges
							@hasChanges()
						else
							if @updateQueue.length
								for update in @updateQueue
									@executeUpdate update
								@updateQueue = []
						# else


			@ws.onopen = =>
				@open = true
				@doInit 'init'

			@ws

		registerClient: (cb) ->
			@updater.background.httpRequest @updater.background.apiRoot + 'ws/registerClient.php',
				data:extVersion:@updater.background.extVersion
				dataType:'json'
				cb: (response) =>
					if response == 'not signed in'
						@server = @updater.clientId = @clientId = null
						cb null
					else if response.status == 'success'
						@updater.clientId = @clientId = response.clientId
						@server = response.updaterServer
						cb? response

		init: (onInit) ->
			@registerClient (response) =>
				if response == null
					onInit?()
				else
					@updateToken = response.updateToken
					@createWebSocket onInit

		hasChanges: ->
			if @open
				if @updating
					@moreChanges = true
				else if !@startedUpdating
					@startedUpdating = true
					setTimeout (=>
						delete @startedUpdating
						@updating = true
						changes = @updater.compileChanges()
						@updater.clearChanges()

						if changes
							@changesSent changes
							console.debug 'sending', changes
							@ws.send JSON.stringify
								type:'update'
								changes:JSON.stringify changes
								updateToken:@updateToken
					), 200
			else
				@_hasChanges = true

			

	class HttpTransport extends UpdaterTransport
		polling:true
		init: (onInit) ->
			@updater.update onInit

		sendUpdate: (args) ->
			@updater.background.httpRequest @updater.background.apiRoot + 'update.php',
				method:'post'
				dataType: 'json'
				data:args.data
				cb: (response) =>
					if response == 'not signed in'
						console.debug 'not signed in'
						@updater.mergePrevTablesWithTables()
						@updater.resetUpdateTimer 3000
					else if !response || response == 'error'
						@updater.mergePrevTablesWithTables()
						@updater.resetUpdateTimer 10000
						console.debug 'done with error', response
						@updater.errorState.set true
					else
						#===
						if 'status' of response
							@updater.status.set response.status

						@updater.message.set response.message

						if 'updateInterval' of response
							@updater.updateInterval = response.updateInterval

						if 'clientId' of response
							@updater.background.clientId = @updater.clientId = response.clientId

						if 'track' of response
							tracking.enabled = response.track

						if 'domain' of response
							@updater.background.setDomain response.domain

						userId = parseInt response.userId
						@updater.setUser userId

						if @updater.userId
							@updater.db.addMapping response.mapping
							@updater.disabled = true
							@updater.db.executeChanges response.changes
							@updater.disabled = false
						
						@updater.lastUpdated = response.time

						if response.commands
							try
								@updater.commandExecuter.executeCommands response.commands
							catch e
						#====
						
						console.debug 'done'
						@updater.errorState.set false

					args?.success response
					@updater.resetUpdateTimer()
				error: (response) =>
					args?.fail response
					@updater.resetUpdateTimer 10000


		hasChanges: ->
			# if @updater.autoUpdate && !@updater.updating
			# 	@updater.background.clearTimeout @timerId
			# 	@timerId = @background.setTimeout (=>
			# 		@updater.update()
			# 	), @updater.updateInterval
	
			@updater.resetUpdateTimer()


	class Updater
		test: (data) ->
			for tableName,records of data
				for id,record of records
					localId = @db.globalToLocalMapping?[tableName]?[id] ? id
					values = @db.tables[tableName]._recordsByRid[localId]._values
					if values
						localRecord = @prepare tableName, values

						for fieldName, value of localRecord
							continue if fieldName == 'more' || fieldName == 'offers' || fieldName == 'timestamp'
							continue if fieldName in (@db.tables[tableName].schema.local ? [])
							# console.debug "#{tableName} #{id}|#{localId} #{fieldName} #{value} #{record[fieldName]}"

							if `value != record[fieldName]`
								console.debug "#{tableName} #{localId}|#{id} #{fieldName} `#{value}` `#{record[fieldName]}`"
					else
						console.debug "#{tableName} #{localId}|#{id} #{fieldName}"


			for tableName,table of @db.tables
				for id,{_values:record} of table._recordsByRid
					globalId = @convertId tableName, id

					localRecord = @prepare tableName, record


					# localId = @updater.db.globalToLocalMapping?[tableName]?[id] ? id

					for fieldName, value of localRecord
						# console.debug "#{tableName} #{id}|#{localId} #{fieldName} #{value} #{record[fieldName]}"

						if !data[tableName][globalId]
							# console.debug "#{tableName} #{globalId}", localRecord
						else
							remoteValue = response.allData[tableName][globalId][fieldName]

							if `remoteValue != value`
								console.debug "#{tableName} #{globalId}|#{id} #{fieldName} #{value} #{remoteValue}"


		constructor: (@background, @db, @userIdValue, @errorState) ->
			@tables = {}
			@userId = @userIdValue.get() ? 0
			@updateInterval = 2000
			@autoUpdate = true
			@history = {}
			@changes = false

			@userIdCookieValue = null

			@status = new ObservableValue
			@message = new ObservableValue

			@transport = new WebSocketTransport @
			# @transport = new HttpTransport @

			# @events = onInited:new Event



			# @_update = @update
			# @update = (cb) -> @updateCb = cb

			# @background.getStorage ['updaterChanges', 'localToGlobalMapping', 'globalToLocalMapping'], (data) =>
			# 	@tables = data.updaterChanges ? {}
			# 	@db.localToGlobalMapping = data.localToGlobalMapping ? {}
			# 	@db.globalToLocalMapping = data.globalToLocalMapping ? {}

			# 	# console.log data
			# 	@update = @_update
			# 	delete @_update
			# 	if @updateCb
			# 		@update @updateCb
			# 		delete @updateCb


			@commandExecuter = new CommandExecuter @background

		cookiePolling: ->
			cookieUrl = if env.cookieDomain then "http://#{env.cookieDomain}" else @background.apiRoot
			@background.getCookie cookieUrl, 'userId', (cookie) =>
				@userIdCookieValue = cookie?.value

				@background.setInterval (=>
					@background.getCookie cookieUrl, 'userId', (cookie) =>
						if cookie?.value != @userIdCookieValue
							@userIdCookieValue = cookie?.value
							@transport.userChanged()
							# @forceUpdate()
				), 1000

		init: (cb) ->
			@transport.init (args...) =>
				@cookiePolling()
				cb args...

		isDisabled: -> @disabled || !@userId

		setUser: (userId) ->
			if userId != @userId
				console.debug 'new user', @userId, userId
				@db.localToGlobalMapping = {}
				@db.globalToLocalMapping = {}
				@disabled = true
				@db.clear()
				@disabled = false
				
				@background.userId = @userId = userId
				@userIdValue.set @userId


		isLocalId: (id) ->
			(id + '')[0] != 'G'
		hasGlobalId: (table, id) ->
			if @isLocalId id
				@db.localToGlobalMapping?[table]?[id]?
			else
				true

		convertId: (table, id) ->
			if @isLocalId id
				@db.localToGlobalMapping?[table]?[id] ? id
			else
				id

		prepare: (table, record) ->
			# table = record.table.name
			values = {}
			for field,value of record
				if referentTable = @db.tables[table].schema?.referents?[field]
					if _.isFunction referentTable
						referentTable = referentTable record
					# if @isLocalId(value) && !@hasGlobalId referentTable, value
						# if !@tables[referentTable][value]
						# 	throw new Error "#{referentTable}.#{value} not in changes"
					value = @convertId referentTable, value

				if value instanceof Date
					value = '0000-00-00 00:00:00'

				else if _.isPlainObject value
					value = JSON.stringify value

				values[field] = value
			values

		forceUpdate: ->
			@background.clearTimeout @timerId
			@update()


		compileChanges: ->
			data = {}
			count = 0
			hasData = false
			for table,records of @tables
				for id,record of records
					# data[record.storeId] ?= {}
					data[table] ?= {}
					values = {}
					if record != 'deleted'
						values = @prepare table, record
					else
						values = 'deleted'
					hasData = true

					if table == 'products' && !(values.siteName || values.productSid) && !@hasGlobalId table, id
						throw new Error "BAD"
					++ count
					data[table][@convertId table, id] = values
			data

		update: (cb) ->
			data = @compileChanges()
			console.debug 'updating...'
			@updating = true
			@transport.sendUpdate
				data:
					lastTime: @lastUpdated ? ''
					userId:@userId
					clientId:@clientId
					changes:JSON.stringify data
					extVersion:@background.version
					apiVersion:@background.apiVersion
					instanceId:@background.instanceId
					debug:env.dev
					schema:@db.schema
				success: (response) =>
					@updating = false
					cb? response
				fail: =>
					@updating = false
					@mergePrevTablesWithTables()
					console.debug 'done with error'
					@errorState.set true

			@changes = false
			@clearStorage()

		clearChanges: ->
			@prevTables = @tables
			@tables = {}
			@changes = false

		clearStorage: ->
			@background.removeStorage ['updaterChanges', 'localToGlobalMapping', 'globalToLocalMapping']

		mergePrevTablesWithTables: ->
			for name,records of @prevTables
				@tables[name] ?= {}
				for id,record of records
					if record == 'deleted'
						@tables[name][id] = 'deleted'
					else if @tables[name][id] != 'deleted'
						@tables[name][id] ?= {}
						for field,value of record
							unless field of @tables[name][id]
								@tables[name][id][field] = value
			@prevTables = {}
			@saveTables()

		resetUpdateTimer: (duration = @updateInterval) ->
			if @autoUpdate && !@updating
				@background.clearTimeout @timerId
				@timerId = @background.setTimeout (=>
					@update()
				), duration

		saveTables: -> 
			# @background.setStorage
			# 	updaterChanges:@tables
			# 	localToGlobalMapping:@db.localToGlobalMapping
			# 	globalToLocalMapping:@db.globalToLocalMapping

		addUpdate: (record, field) ->
			return if @isDisabled() || record.table.schema.local && field in record.table.schema.local
			#Debug.log 'update', field, record, record.get(field) if field == 'index'

			@history[record.table.name] ?= {}
			@history[record.table.name][record.id] ?= []
			@history[record.table.name][record.id].push type:'update', field:field


			@tables[record.table.name] ?= {}
			@tables[record.table.name][record.id] ?= {}
			@tables[record.table.name][record.id][field] = record.get(field)
			@changes = true
			@transport.hasChanges()
			@saveTables()
			
		addInsertion: (record) ->
			if @isDisabled()
				# console.log record
				# throw new Error "THIS IS WRONG"
				return
			#Debug.log 'insertion', record.table.name, record

			@history[record.table.name] ?= {}
			@history[record.table.name][record.id] ?= []
			@history[record.table.name][record.id].push type:'insert'


			@tables[record.table.name] ?= {}

			values = null
			if record.table.schema.local
				values = {}
				for name,value of record._values
					unless name in record.table.schema.local
						values[name] = value
			else
				values = _.clone record._values

			@tables[record.table.name][record.id] = values

			@changes = true
			@transport.hasChanges()
			@saveTables()
		
		addDeletion: (record) ->
			return if @isDisabled()
			#Debug.log 'deletion', record

			@history[record.table.name] ?= {}
			@history[record.table.name][record.id] ?= []
			@history[record.table.name][record.id].push type:'delete'

			if record.hasGlobal()
				@tables[record.table.name] ?= {}
				@tables[record.table.name][record.id] = 'deleted'
			else
				delete @tables[record.table.name][record.id] if @tables[record.table.name]

			@changes = true
			@transport.hasChanges()
			@saveTables()

		reset: ->
			agora.reset()
			@disabled = true
			@db.clear()
			@disabled = false

