define ['underscore', 'model/ModelInstance', 'CommandExecuter', 'model/ObservableValue', 'model/Event'], (_, ModelInstance, CommandExecuter, ObservableValue, Event) ->
	parse = (json, cb=null) =>
		if cb
			obj = null
			try
				obj = JSON.parse json
			catch e
				background.error 'JsonError', e

			cb obj != null, obj ? json
		else
			try
				JSON.parse json
			catch e
			# TODO: Handle errors better...
			# if !env.dev
				# @updater.reset()


	class UpdaterTransport
		constructor: (@updater) ->

	class MessageStream
		constructor: ->
			@queue = []
			@number = 0

		clearMessageQueue: ->
			@queue = []

		_sendMessage: (type, params) ->
			if _.isFunction params[params.length - 1]
				@cb = params[params.length - 1]
				params = params.slice 0, -1

			@working = true
			@type = type
			code = @messageTypes[type].code
			currentNumber = @currentNumber = @number++
			@ws.send "#{code}#{@currentNumber}\t#{params.join '\t'}"
			background.log "sending message #{@type}, #{currentNumber}..."

			@timerId = setTimeout (=>
				console.log 'timeout', type
				background.error 'MessageStreamError', 'timeout', type, currentNumber
				@interupted 'timeout'
			), 15 * 1000

		sendMessage: (type, params...) ->
			if @working
				@queue.push type:type, params:params
			else
				@_sendMessage type, params

		interupted: (reason) ->
			if @type
				background.log "message interupted #{@type}, #{@currentNumber}, #{reason}"

				cb = @cb
				delete @cb
				done = (r) =>
					if cb
						cb r
				@messageTypes[@type].interupted? done, reason

				delete @type
				delete @currentNumber
				@working = false


				if @queue.length
					next = @queue.shift()
					@_sendMessage next.type, next.params

		sendNextMessage: ->
			if @queue.length
				next = @queue.shift()
				@_sendMessage next.type, next.params


		receivedResponse: (response) ->
			clearTimeout @timerId
			responseParams = response.split '\t'
			number = responseParams[0]
			responseParams = responseParams.slice 1
			if `number == this.currentNumber`
				background.log "message response #{@type}, #{@currentNumber}"

				cb = @cb
				delete @cb
				done = (r) =>
					if cb
						cb r, response

				@messageTypes[@type].responseHandler done, responseParams...

				@working = false
				delete @type
				@sendNextMessage()
			# else
				# background.error 'Error', 

	class WebSocketTransport extends UpdaterTransport
		polling: false
		constructor: ->
			super
			@workQueue = []
			@subscriptions = {}
			@messageStream = new MessageStream

			@messageStream.messageTypes = 
				init:
					code: 'i'
					responseHandler: (done, gatewayServerId, changes) =>
						@updater.setGatewayForStore gatewayServerId, @userId
						parse changes, (success, changes) =>
							if success
								@sync changes, @userId, '*', =>
									done true
							else
								console.log changes
								done false

					interupted: (done, reason) ->
						background.state = 3
						done false

				update:
					code: 'u'
					responseHandler: (done, response) =>
						if !(response == 'error' || response == 'not allowed')
							@changesConfirmed()
							parse response, (success, response) =>
								if success
									if response.mapping?
										@updater.db.addMapping response.mapping

									@updateToken = response.updateToken

									if response.changes?
										@executeChanges response.changes, @user, ->
											done true
									else
										done true
								else
									done false, response
						else
							done false, response

					interupted: (done) ->
						done false

				subscribe:
					code: 's'
					responseHandler: (done, gatewayServerId, storeId, object, changes) =>
						if changes == 'not allowed'
							done false
						else
							@updater.setGatewayForStore gatewayServerId, storeId
							parse changes, (success, changes) =>
								if success
									@sync changes, storeId, object, =>
										@subscriptions[storeId] ?= {}
										@subscriptions[storeId][object] ?= {}
										@subscriptions[storeId][object].retrieved = true
										done true
								else
									done false

				retrieve:
					code: 'r'
					responseHandler: (done, parts...) =>
						changes = {}
						for i in [0...parts.length/2]
							_.merge changes, parse parts[i*2 + 1]
						done changes

				message:
					code: 'm'
					responseHandler: (done) -> done()

			@updater.db.tables.shared_objects.observe (mutation) =>
				if mutation.type == 'deletion'
					storeId = mutation.record.get('user_id').substr(1)
					@unsubscribe storeId, mutation.record.get('object')
					if !@updater.db.tables.shared_objects.selectFirst(user_id:mutation.record.get('user_id'))
						@unsubscribe storeId, '@'

				@testWhenObject obj for obj in @_whenObjects if @_whenObjects


		changesSent: (changes) ->
			@sentChanges = changes

		changesConfirmed: ->
			delete @sentChanges

		testWhenObject: (obj) ->
			for object in obj.objects
				if !@isPermitted obj.storeId, object
					background.log 'not permitted', obj.storeId, object
					if obj.state
						if obj.state == 2
							obj.unavailable()
						obj.state = 0
					else if !obj.initial
						obj.initial = true
						obj.unavailable()
					return

			if !obj.state
				obj.state = 1
				count = 0
				start = (succeeded) =>
					if succeeded
						if count == obj.objects.length
							obj.available()
							obj.state = 2
						else
							@subscribe obj.storeId, obj.objects[count++], start
					else
						obj.state = 0
						obj.unavailable()
				start true

		reset: ->
			@_whenObjects = []
			delete @sentChanges
			@working = false

		whenObject: (storeId, objects, available, unavailable) ->
			@_whenObjects ?= []
			obj =
				storeId:storeId
				objects:objects
				available:available
				unavailable:unavailable

			@_whenObjects.push obj

			@testWhenObject obj
			obj

		unregisterWhenObject: (obj) ->
			if @_whenObjects
				_.pull @_whenObjects, obj

		isPermitted: (storeId, object) ->
			if `storeId == this.userId`
				return true 
			if object == '@'
				if @updater.db.tables.shared_objects.selectFirst(user_id:'G' + storeId) || @updater.db.tables.shared_objects.selectFirst(with_user_id:'G' + storeId)
					return true

				if collaborator = @updater.db.tables.collaborators.selectFirst(user_id:storeId)
					return "#{collaborator.get('object_user_id')} #{collaborator.get('object')}"

				return false
			else
				if !@updater.db.tables.shared_objects.selectFirst(user_id:'G' + storeId, object:object)
					return false
			return true

		subscribed: (storeId, object) ->
			@subscriptions[storeId]?[object]


		_getContents: (record) ->
			contents = []
			for child in record.contained false
				if !@subscriptions[child.storeId]["#{child.table.name}.#{child.saneId()}"]
					contents.push child
					contents = contents.concat @_getContents child
			contents

		unsubscribe: (storeId, object) ->
			if @subscriptions[storeId]?[object]
				onUnsubscribeCbs = @subscriptions[storeId][object].onUnsubscribe
				if onUnsubscribeCbs
					onUnsubscribeCb() for onUnsubscribeCb in onUnsubscribeCbs
				delete @subscriptions[storeId][object]

				record = agora.getObject storeId, object
				if record
					@updater.disabled = true
					contents = []
					if object == '/'
						contents = @_getContents record
					else if object == '@'
						record.delete()
					else
						if !record.owner()
							contents = @_getContents record
							record.delete()

					for r in contents
						r.delete()
				@updater.disabled = false

		renewSubscriptions: (storeId=null) ->
			if storeId
				for object,__ of @subscriptions[storeId]
					key = @isPermitted storeId, object
					if key
						do (object) =>
							@work 'subscribe', =>
								params = if !_.isBoolean key then [storeId, object, key] else [storeId, object]
								@messageStream.sendMessage 'subscribe', params..., => @doneWorking()
			else
				for storeId, ___ of @subscriptions
					@renewSubscriptions storeId


		subscribe: (storeId, object, cb, onUnsubscribe=null) ->
			key = null
			# if _.isPlainObject object
			# 	key = object.key
			# 	object = object.object
			# console.log 'susbcribe', storeId, object
			if `storeId == this.userId`
				cb true
				return
			return if !(key = @isPermitted storeId, object)

			@subscriptions[storeId] ?= {}
			if !@subscriptions[storeId][object]
				# @startWorking()
				@subscriptions[storeId][object] = retrieved:false, cbs:[cb], onUnsubscribe:if onUnsubscribe then [onUnsubscribe] else []
				@work 'subscribe', =>
					params = if !_.isBoolean key then [storeId, object, key] else [storeId, object]
					@messageStream.sendMessage 'subscribe', params..., (r) =>
						@doneWorking()
						if !r
							if @subscriptions[storeId][object].cbs
								cb false for cb in @subscriptions[storeId][object].cbs 
								delete @subscriptions[storeId][object].cbs
						else
							if @subscriptions[storeId][object].cbs
								cb true for cb in @subscriptions[storeId][object].cbs 
								delete @subscriptions[storeId][object].cbs

			else
				s = @subscriptions[storeId][object]
				if onUnsubscribe
					s.onUnsubscribe.push onUnsubscribe

				if s.retrieved
					cb true
				else
					s.cbs ?= []
					s.cbs.push cb

		checkToRetrieve: (changes, externalStoreId) ->
			toRetrieve = {}
			needsToRetrieve = false
			map = Product:'products', ProductVariant:'product_variants', Decision:'decisions', Bundle:'bundles'

			for table in ['root_elements', 'list_elements', 'bundle_elements', 'belt_elements']
				if changes[table]
					for id, record of changes[table]
						if t = map[record.element_type]
							continue if changes?[t]?[record.element_id]
							id = @updater.db.globalToLocalMapping?[t]?[record.element_id] ? record.element_id
							if !@updater.db.table(t).byId id
								storeId = null
								if @updater.db.table(t).canBeExternal
									storeId = externalStoreId
								else
									storeId = @updater.db.storeId
								toRetrieve[storeId] ?= {}
								toRetrieve[storeId][t] ?= []
								toRetrieve[storeId][t].push record.element_id
								needsToRetrieve = true

			# TODO: make more general
			for table in ['product_variants']
				if changes[table]
					for id, record of changes[table]
						t = 'products'
						continue if changes?[t]?[record.product_id]
						id = @updater.db.globalToLocalMapping?[t]?[record.product_id] ? record.product_id
						if !@updater.db.table(t).byId id
							storeId = null
							if @updater.db.table(t).canBeExternal
								storeId = externalStoreId
							else
								storeId = @updater.db.storeId
							toRetrieve[storeId] ?= {}
							toRetrieve[storeId][t] ?= []
							toRetrieve[storeId][t].push record.product_id
							needsToRetrieve = true
			if needsToRetrieve
				toRetrieve

		executeChanges: (changes, storeId, cb=null) ->
			# console.log 'execute changes', changes
			doExecuteChanges = =>					
				@updater.disabled = true
				@updater.db.externalStoreId = storeId
				@updater.db.executeChanges allChanges
				@updater.disabled = false

				delete @updater.db.externalStoreId

				cb?()

			allChanges = {}

			checkChanges = (changes) =>
				_.merge allChanges, changes
				toRetrieve = @checkToRetrieve changes, storeId
				if toRetrieve
					# console.log toRetrieve
					parts = []
					for theStoreId, stuffToRetrieve of toRetrieve
						parts.push theStoreId
						parts.push JSON.stringify stuffToRetrieve
					# console.log 'retrieving', toRetrieve
					@messageStream.sendMessage 'retrieve', parts..., checkChanges
					# @retrieveCb = checkChanges
				else
					doExecuteChanges()

			checkChanges changes

		sync: (data, storeId, object, cb=null) ->
			@updater.disabled = true
			if object == '*'
				for name, table of @updater.db.tables
					continue if name in ['products', 'product_variants']
					toDelete = []
					table.records.each (record) =>
						if data[name]
							if `storeId == record.storeId` && !data[name][record.globalId()]
								toDelete.push record.globalId()

					for id in toDelete
						table.byGlobalId(id).delete()
			else if object == '@'
			else
				[table, id] = object.split '.'
				record = @updater.db.table(table).bySaneId id
				if record
					contained = record.contained()
					for containedRecord in contained
						if !data?[containedRecord.table.name]?[containedRecord.globalId()]
							containedRecord.delete()
			@updater.disabled = false

			@executeChanges data, storeId, cb
			
		userChanged: ->
			# if @ws
				background.log 'user changed'
				@clientId = @updater.clientId = null
				if @ws
					@ws.close()
					delete @ws

				@registerClient (response) =>
					if response
						@createWebSocket()
			# else
				# @init()

		doInit: (cb) ->
			init = =>
				@sendNextChanges()
				@work 'init', =>
					@messageStream.sendMessage 'init', @clientId, @userId, (success) =>
						@doneWorking()
						if success
							cb? true
							@renewSubscriptions()
							@sendNextChanges()
						else
							cb? false

			if @workingChanges
				@work 'sendPreviousChanges', =>
					@sendChanges @workingChanges, =>
						@doneWorking()
						init()
			else
				init()

		createWebSocket: (onInit) ->
			background.log 'creating websocket...'
			@ws = new WebSocket "ws://#{@server}"
			@messageStream.ws = @ws
			@ws.onerror = =>
				console.log 'error', arguments

			@ws.onclose = (event) =>
				background.log 'socket close', event.reason, event.code

				@open = false
				@working = false
				@clearWorkQueue()
				@messageStream.clearMessageQueue()

				if !@started && !@inited
					@inited = true
					@updater.status.set 'down'
					@updater.message.set 'Agora is down for the moment. Please be patient! Thank you. :)'
					onInit? false
					agora.onInit false

				# @updater.status.set 'down'
				# @updater.message.set 'Agora is down for the moment. Please be patient! Thank you. :)'

				if @clientId
					setTimeout (=>@createWebSocket onInit), 1000

			@ws.onmessage = (message) =>
				message = message.data
				console.debug 'message:', message
				type = message[0]
				message = message.substr 1
				switch type
					when '$'
						[commandId, command] = message.split '\t'
						@updater.commandExecuter.executeCommand JSON.parse(command), (response, encode=true) =>
							@ws.send "$#{commandId}\t#{if encode then JSON.stringify response else response}"

					when '.'
						# @updater.reset()
						if @started
							# @updater.setGatewayAvailable message, true
							if parseInt(message) == @updater.gatewayForStore @userId
								@doInit()
							else
								@renewSubscriptions message
								@sendNextChanges()
						else
							@updater.reset()

					when ','
						# @updater.setGatewayAvailable message, false
						@messageStream.interupted 'server'

						# @updater.status.set 'down'
						# @updater.message.set 'Agora is down for the moment. Please be patient! Thank you. :)'

					when '<'
						@messageStream.receivedResponse message

					when 'u'
						[storeId, changes] = message.split '\t'
						parse changes, (success, changes) =>
							if success
								@work 'update', =>
									@executeChanges changes, storeId, => @doneWorking()
							else
								background.error 'UpdaterError', 'invalidUpdateMessage', changes

					when 'p'
						@ws.send "P#{message}"

			@ws.onopen = =>
				# if @started
				# 	@updater.reset()
				# else
				@updater.status.set 'online'
				@updater.message.set ''
				@open = true

				@doInit (success) =>
					if success
						if !@started
							@started = true
							if !@inited
								@inited = true
								onInit? true
								background.state = 2
						else
							agora.onInit true
					else
						@updater.status.set 'down'
						@updater.message.set 'Agora is down for the moment. Please be patient! Thank you. :)'

						if !@inited
							@inited = true
							onInit? false
							agora.onInit false

			@ws

		registerClient: (cb) ->
			background.log 'registering client'
			@updater.background.httpRequest @updater.background.apiRoot + 'ws/registerClient.php',
				data:
					extVersion:@updater.background.version
					instanceId:@updater.background.instanceId
				dataType:'json'
				cb: (response) =>
					if response == 'not signed in'
						background.clientId = @server = @updater.clientId = @clientId = null
						@updater.setUser 0
						@userId = 0
						tracking.enabled = false
						cb null
					else if response.status == 'success'
						@updateToken = response.updateToken
						background.clientId = @updater.clientId = @clientId = response.clientId
						@userId = parseInt response.userId
						@server = response.updaterServer
						@updater.setUser @userId
						if response.track?
							tracking.enabled = !!parseInt response.track
						else
							tracking.enabled = false
						if response.convert
							agora.convert = response.convert

						cb? response

		init: (onInit) ->
			@registerClient (response) =>
				if response == null
					@started = true
					onInit?()
				else
					@createWebSocket onInit

		clearWorkQueue: ->
			@workQueue = []

		work: (args...) ->
			if @working || !@open
				@workQueue.push args
			else
				cb = if _.isString args[0]
					@name = args[0]
					args[1]
				else
					args[0]
				@working = true
				background.log 'working', @name
				cb()

		doneWorking: ->
			background.log 'done working', @name
			delete @name
			@working = false

			if @workQueue.length
				args = @workQueue.shift()
				cb = if _.isString args[0]
					@name = args[0]
					args[1]
				else
					args[0]
				cb()
			else if @changes
				@changes = false
				@sendNextChanges()

		sendNextChanges: ->
			changes = @updater.nextChanges()
			if changes
				f = (currentChanges) =>
					@sendChanges currentChanges, (success) =>
						if success
							nextChanges = @updater.nextChanges()
							if nextChanges
								f nextChanges
							else
								@doneWorking()
						else
							@doneWorking()

				@work 'sendChanges', -> f changes

		sendChanges: (changes, cb) ->
			console.log changes
			@workingChanges = changes
			storeId = _.keys(changes)[0]
			theseChanges = @updater.convertIds changes[storeId]

			@messageStream.sendMessage 'update', @updateToken, storeId, JSON.stringify(theseChanges), (success, message) =>
				if success
					delete @workingChanges
					cb true
				else
					cb false, message

		hasChanges: ->
			if @open
				if @working
					@changes = true
				else
					clearTimeout @updaterTimerId
					@updaterTimerId = setTimeout (=>
						@sendNextChanges()
					), 200
			else
				@changes = true

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
			@deleted = []
			@userId = @userIdValue.get() ? 0
			@updateInterval = 2000
			@autoUpdate = true
			@history = {}
			@changes = false

			@userIdCookieValue = null

			@status = new ObservableValue
			@message = new ObservableValue

			@transport = new WebSocketTransport @

			@gateways = {}
			@gatewayByStore = {}
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

		isStoreAvailable: (storeId) -> true#@gateways[@gatewayByStore[storeId]].available

		gatewayForStore: (storeId) -> @gatewayByStore[storeId]


		setGatewayForStore: (gatewayServerId, storeId) ->
			@gateways[gatewayServerId] ?= available:true, stores:[]
			@gateways[gatewayServerId].stores.push parseInt storeId
			@gatewayByStore[storeId] = parseInt gatewayServerId

		setGatewayAvailable: (gatewayServerId, available) ->
			@gateways[gatewayServerId] ?= available:true, stores:[]
			@gateways[gatewayServerId].available = available

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
			userId = parseInt userId
			if userId != @userId
				background.log 'new user', @userId, userId
				@db.localToGlobalMapping = {}
				@db.globalToLocalMapping = {}
				@db.storeId = userId
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
					value = @convertId referentTable, value

				if value instanceof Date
					value = '0000-00-00 00:00:00'

				else if _.isPlainObject(value) || _.isArray value
					value = JSON.stringify value

				values[field] = value
			values

		forceUpdate: ->
			@background.clearTimeout @timerId
			@update()

		nextChanges: ->
			data = {}
			toDelete = []

			for table,records of @tables
				for id,record of records
					storeId = @db.table(table).byId(id)?.storeId
					continue if !storeId || !@isStoreAvailable storeId
					data[storeId] ?= {}
					data[storeId][table] ?= {}
					values = @prepare table, record

					if table == 'products' && !(values.siteName || values.productSid) && !@hasGlobalId table, id
						throw new Error "BAD"

					# toDelete.push table:table, id:id

					data[storeId][table][id] = values


			# for i in toDelete
			# 	delete @tables[i.table][i.id]
			# 	if _.isEmpty @tables[i.table]
			# 		delete @tables[i.table]

			# toDelete = []
			for info,i in @deleted
				continue if !@isStoreAvailable info.storeId

				data[info.storeId] ?= {}
				data[info.storeId][info.table] ?= {}
				data[info.storeId][info.table][info.id] = 'deleted'
				# toDelete.unshift i

			# for i in toDelete
			# 	@deleted.splice i, 1

			if !_.isEmpty data
				selectedStoreId = null
				storeIds = _.keys data
				if data[@userId]
					selectedStoreId = @userId
				else
					selectedStoreId = storeIds[0]
				
				for storeId in storeIds
					if `storeId != selectedStoreId`
						delete data[storeId]

				for storeId, tables of data
					for table, records of tables
						for id, changes of records
							if changes == 'deleted'
								for info,i in @deleted
									if info.table == table && `info.id == id`
										@deleted.splice i, 1
										break
							else
								delete @tables[table][id]
								if _.isEmpty @tables[table]
									delete @tables[table]

				data

		convertIds: (changes) ->
			newChanges = {}
			for table,records of changes
				newChanges[table] = {}
				for id,record of records
					newChanges[table][@convertId table, id] = record
			newChanges


		clearChanges: (changes) ->
			@prevTables = @tables
			@tables = {}
			@deleted = []
			@changes = false

		clearStorage: ->
			@background.removeStorage ['updaterChanges', 'localToGlobalMapping', 'globalToLocalMapping']

		addUpdate: (record, field) ->
			if @isDisabled() || record.table.schema.local && field in record.table.schema.local
				return

			@tables[record.table.name] ?= {}
			@tables[record.table.name][record.id] ?= {}
			@tables[record.table.name][record.id][field] = record.get(field)
			@changes = true
			@transport.hasChanges()
			
		addInsertion: (record) ->
			values = null
			if record.table.schema.local
				values = {}
				for name,value of record._values
					unless name in record.table.schema.local
						values[name] = value
			else
				values = _.clone record._values

			return if @isDisabled()

			@tables[record.table.name] ?= {}
			@tables[record.table.name][record.id] = values

			@changes = true
			@transport.hasChanges()
		
		addDeletion: (record) ->
			return if @isDisabled()

			if record.hasGlobal()
				@deleted.push table:record.table.name, id:record.id, storeId:record.storeId
			else
				delete @tables[record.table.name][record.id] if @tables[record.table.name]

			@changes = true
			@transport.hasChanges()

		reset: ->
			agora.signalReload()
			chrome.runtime.reload()
			return
			agora.reset()
			@disabled = true
			@db.clear()
			@disabled = false
			@transport.reset()
			@changes = false
			@tables = {}

		subscribe: (storeId, object, cb, onUnsubscribe=null) ->
			@transport.subscribe storeId, object, cb, onUnsubscribe
