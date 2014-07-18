if !document.location.href.match('^http:\/\/agora\.dev') && !document.location.href.match('^http:\/\/baggg\.it') && !document.location.href.match('^http:\/\/agoraext\.dev')
	chrome.extension.sendMessage 'getScript', (script) ->
		eval script if script

	chrome.runtime.onMessage.addListener (request) ->
		if request == 'needsReload'
			siteInjector.onOldVersion()
		else if request == 'startContentClipping'
			if window.siteInjector
				siteInjector.startContentClipping()
			else
				window.onAgoraInit = ->
					siteInjector.startContentClipping()
				chrome.extension.sendMessage 'init'

		else if request == 'toggle'
			if window.siteInjector
				siteInjector.toggle()
			else
				chrome.extension.sendMessage 'init'
		else if request.action == 'updateCode'
			name = request.module.match('/?([^/]*)$')[1];

			className = request.className ? name

			module = null
			define = (func) ->
				module = func()

			`with (__classes) {
				eval(request.code);

				var obj;
				if (module.c) obj = module.c;
				else obj = module;
			
				window[className] = __classes[className] = obj();
			}`

			null


reloadStyles = ->
	chrome.extension.sendMessage "getStyles", (styles) ->
		stylesheet = document.getElementById("agoraStylesheet")
		stylesheet.parentNode.removeChild stylesheet
		stylesheet = document.createElement("style")
		stylesheet.id = "agoraStylesheet"
		stylesheet.setAttribute "type", "text/css"
		stylesheet.setAttribute "rel", "stylesheet"
		stylesheet.innerHTML = styles
		document.head.appendChild stylesheet

reloadModules = (modules...) ->
	chrome.runtime.sendMessage action:'reloadModules', modules:modules
