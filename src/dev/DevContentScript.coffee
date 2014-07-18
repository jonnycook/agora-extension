define ->
	-> class DevContentScript extends ContentScript	
		browser: 'Dev'

		onRequest: (listener) ->
			devBackground.addContentScriptListener listener

		sendRequest: (request, cb) ->
			devBackground.requestHandler request, {}, cb

		injectUtilScripts: (cb) -> devBackground.cs_injectUtilScripts cb
		
		resourceUrl: (resource) -> "resources/#{resource}"
		