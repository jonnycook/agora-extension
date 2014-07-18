define ->
	-> class WebappContentScript extends ContentScript	
		browser: 'Webapp'

		webApp:true

		onRequest: (listener) ->
			webappBackground.addContentScriptListener listener

		sendRequest: (request, cb) ->
			webappBackground.requestHandler request, {}, cb

		injectUtilScripts: (cb) -> webappBackground.cs_injectUtilScripts cb
		
		resourceUrl: (resource) -> "#{env.root}/resources/#{resource}"
		