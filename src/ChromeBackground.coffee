define ['jQuery', 'Background', 'ChromeContentScript'], ($, Background, ChromeContentScript) ->
	class ChromeBackground extends Background
		version: "chrome-#{chrome.runtime.getManifest().version}"

		getVersion: -> chrome.runtime.getManifest().version

		constructor: ->
			super
			@portsForTab = {}
			chrome.runtime.onConnect.addListener (port) =>
				if port.sender.tab
					@portsForTab[port.sender.tab.id] = port
					port.onDisconnect.addListener =>
						delete @portsForTab[port.sender.tab.id]
						@unregisterTab port.sender.tab.id

					port.onMessage.addListener (message) =>
						if message.requests
							for request in message.requests
								do (request) =>
									@handler request.request, port.sender.tab, (response) =>
										port.postMessage type:'response', id:request.id, response:response
						else
							@handler message.request, port.sender.tab, (response) =>
								port.postMessage type:'response', id:message.id, response:response

		getStyles: (cb) ->
			$.get chrome.extension.getURL('resources/stylesheets/chrome.css'), cb

		clientLibsPath: -> chrome.extension.getURL 'libs/client/merged.js'

		injectUtilScripts: (sender, done) ->
			_loadScripts = (scripts, cb) ->
				count = scripts.length
				tick = ->
					cb() if --count == 0
				
				for script in scripts
					chrome.tabs.executeScript sender.id, file:script, tick
			
			loadScripts = (scripts, cb) ->
				i = 0
				doLoadScripts = ->
					s = scripts[i++]
					if s
						s = [s] unless _.isArray s
						_loadScripts s, doLoadScripts
					else
						cb()
				doLoadScripts()
		
			count = 2 #stylesheet
									
			cb = (script) ->
				if --count == 0
					done()
			
			loadScripts @libs, cb
			
			chrome.tabs.insertCSS sender.id, file:'resources/stylesheets/chrome.css', cb

		onRequest: (handler) ->
			@handler = handler

			# chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
			# 	r = handler request, sender.tab, sendResponse
			# 	# console.debug request, r
			# 	# return true
			# 	return r
			
		sendRequest: (tabId, request, response) ->
			if @portsForTab[tabId]
				@portsForTab[tabId].postMessage type:'request', request:request
			else
				console.log 'no port for tab', tabId, request
			# chrome.tabs.sendMessage tabId, request, response
					
		contentScript: -> ChromeContentScript
		
		httpRequest: (url, opts={}) ->
			# console.log opts.data
			$.ajax url, 
				type:opts.method
				data:opts.data
				dataType:opts.dataType
				success: (response, status, xhr) ->
					opts?.cb? response, 
						status: status
						header: (name) -> xhr.getResponseHeader name

				error: ->
					opts?.error?()

		require: (modules, cb) ->
			require modules, cb
				

		setInterval: (cb, duration) -> setInterval cb, duration
		clearInterval: (id) -> clearInterval id
		setTimeout: (cb, duration) ->
			setTimeout cb, duration

		clearTimeout: (id) ->
			clearTimeout id

		getCookie: (url, name, cb) ->
			chrome.cookies.get url:url, name:name, (cookie) -> cb if cookie then value:cookie.value else null

		getValue: (name) -> window[name]
		setValue: (name, value) -> window[name] = value
		defaultValue: (name, value) -> window[name] ?= value

		getResourceUrl: (resource) ->
			chrome.extension.getURL resource

		openTab: (url) ->

		getStorage: (values, cb) ->
			chrome.storage.local.get values, cb

		setStorage: (values) ->
			chrome.storage.local.set values

		removeStorage: (fields) ->
			chrome.storage.local.remove fields
