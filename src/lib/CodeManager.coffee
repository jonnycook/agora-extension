define ->
	class CodeManager
		constructor: (@agora) ->

		reload: (module) ->
			className = null
			if module.module
				className = module.className
				module = module.module

			agora.background.httpRequest "build/lib/client/#{module}.js", 
				cb: (response) =>
					for tab in @agora.tabs
						chrome.tabs.sendMessage tab, action:'updateCode', module:module, className:className, code:response