define ->
	-> class ChromeContentScript extends ContentScript
		browser: 'Chrome'

		constructor: ->
			super
			# @requestQueue = []
			@port = chrome.runtime.connect()
			@port.onMessage.addListener (message) =>
				# console.log message
				if message.type == 'response'
					if @responseCbs[message.id]
						@responseCbs[message.id] message.response
						delete @responseCbs[message.id]
				else if message.type == 'request'
					@listener message.request

			@port.onDisconnect.addListener =>
				console.lo
				siteInjector.onOldVersion()

			@requestId = 1
			@responseCbs = {}

		onRequest: (listener) ->
			@listener = listener
			# chrome.extension.onMessage.addListener listener
			
		sendRequest: (request, cb) ->
			id = @requestId++
			if cb
				@responseCbs[id] = cb

			if !@requestQueue
				@requestQueue = []
				@requestQueue.push request:request, id:id
				setTimeout (=>
					@port.postMessage requests:@requestQueue
					delete @requestQueue
				), 0
			else
				@requestQueue.push request:request, id:id

			# chrome.extension.sendMessage request, if cb then cb else ->
	
		injectUtilScripts: (cb) -> chrome.extension.sendMessage request:'injectUtilScripts', cb
		
		resourceUrl: (resource) -> chrome.extension.getURL "resources/#{resource}"