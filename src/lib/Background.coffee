define ['client/ContentScript'], (ContentScript) ->
	class Background
		# domain: env.domain
		# domain: 'localhost/agora'
		# domain: '23.239.17.29/agora'
		# domain: 'agora-dev.elasticbeanstalk.com'
		# domain: 'agora-dev.elasticbeanstalk.com'
		# domain: 'baggg.it'
		apiVersion: '0.0.1'

		contentScriptListen: (eventName, tabId) ->
			if l = @contentScriptListeners[eventName]
				l.push tabId unless l.indexOf(tabId) != -1
			else
				@contentScriptListeners[eventName] = [tabId]

		setDomain: (domain) ->
			@domain = domain
			@apiRoot = "http://#{@domain}/ext/"

		constructor: (opts={}) ->
			opts.client ?= true
			@domain ?= env.domain if typeof env != 'undefined'
			@apiRoot = "http://#{@domain}/ext/"

			if opts.client
				@listeners = {}
				@contentScriptListeners = {}

				@onRequest (request, sender, sendResponse) =>
					if request.version? && request.version != @version
						sendResponse 'oldVersion'
						return true
					else
						# console.log 'Request from content script:', request
						switch request.request
							when 'injectUtilScripts'
								@injectUtilScripts sender, sendResponse
								return true
								
							when 'listen'
								if l = @contentScriptListeners[request.eventName]
									l.push sender.id unless l.indexOf(sender.id) != -1
								else
									@contentScriptListeners[request.eventName] = [sender.id]
							
							when 'stopListening'
								if l = @contentScriptListeners[request.eventName]
									i = l.indexOf sender.id
									l.splice i, 1
									if !l.length
										delete @contentScriptListeners[request.eventName]
							
							when 'BackgroundMessage'
								if listener = @listeners[request.messageName]
									eventSource = url:sender.url, tabId:sender.id
									listener eventSource, request.args, sendResponse
								else
									console.log "No listener for #{request.event}"
								return true

			String.prototype.safeMatch = (pattern) ->
				if @match
					matches = @match pattern
					if matches then matches else throw new Error "#{pattern} not found in #{@}"


		# libs: [
		# 	'libs/client/merged.js'
		# 	# ['libs/client/underscore-min.js', 'libs/client/jquery-1.7.2.min.js']
		# 	# ['libs/client/easing.jquery.js', 'libs/client/jquery-ui-1.8.21.custom.min.js', 'libs/client/jquery.mousewheel.js']
		# 	# ['libs/client/jquery.ui.sortable.js', 'libs/client/jquery.ui.touch-punch.min.js']
		# ]

		triggerContentScriptEvent: (eventName, args, debug=false) ->
			#Debug.log 'triggerContentScriptEvent', eventName, args, @contentScriptListeners[eventName]?.length
			l = @contentScriptListeners[eventName]
			if debug
				console.debug 'triggerContentScriptEvent', eventName, args, @contentScriptListeners[eventName]?.length
			if l
				for tabID in l
					@sendRequest tabID, eventName:eventName, args:args

	
	
		listen: (request, cb) -> @listeners[request] = cb


		logError: (type, message, file, line, column, stack, info, args) ->
			if !env.dontSubmitErrors
				@httpRequest "#{@apiRoot}logErrors.php",
					method: 'post'
					data:
						type:type
						args:args
						error:message:message, file:file, line:line, column:column, info:info, stack:stack

						userId:@userId
						extVersion:@version
						apiVersion:@apiVersion
						clientId:@clientId

		error: ->
			args = []
			error = {}
			realError = null
			for arg,i in Array.prototype.slice.call arguments, 1
				if arg instanceof Error
					realError = arg
					error = message:arg.message, stack:arg.stack, info:arg.info, line:arg.line
				else
					args.push arg

			@logError arguments[0], error.message, error.file, error.line, error.column, error.stack, error.info, args

			throw realError if realError && !env.gracefulFailure

		log: ->
			console.debug arguments...
			args = []
			error = {}
			realError = null
			for arg,i in arguments
				args.push arg

			setTimeout (=>
				@httpRequest "#{@apiRoot}log.php",
					method: 'post'
					data:
						args:JSON.stringify args
						timestamp:new Date().getTime()
						userId:@userId
						extVersion:@version
						instanceId:@instanceId
						clientId:@clientId
			), 0

		contentScript: ->

		# opts.url, opts.data, opts.cb
		httpGet: (opts) ->
		require: (modules, cb) ->
		
		unregisterTab: (tabId) ->
			console.log 'unregistering tab', tabId
			for event, tabIds of @contentScriptListeners
				i = tabIds.indexOf tabId
				if i != -1
					tabIds.splice i, 1
					if !tabIds.length
						delete @contentScriptListeners[event]

		reset: ->
			# @listeners = {}
			@contentScriptListeners = {}

		ping: ->
			@httpRequest "#{@apiRoot}ping.php",
				data:
					id:@instanceId
					version:@version
					state:@state
				cb: (response) =>
					if response
						response = JSON.parse response
						if response.commands
							for command in response.commands
								do (command) =>
									agora.updater.commandExecuter.executeCommand JSON.parse(command.command), (result) =>
										@httpRequest "#{@apiRoot}returnCommand.php",
											method:'post'
											data:
												commandId:command.id
												result:JSON.stringify result
