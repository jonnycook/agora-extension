define ['jQuery', 'Background', './DevContentScript'], ($, Background, DevContentScript) ->
	class DevBackground extends Background
		apiRoot: 'agoraext.dev/api/'

		getStyles: (cb) ->
			$.get '/resources/stylesheets/dev.css', cb

		clientLibsPath: -> '/libs/client/merged.js'
				
		cs_injectUtilScripts: (cb) ->
			libs = @libs
			
			i = 0
			inc = -> 
				if i == libs.length
					cb()
				else
					l = libs[i++]
					l = [l] unless _.isArray l
					require l, inc
			inc()

			link = document.createElement("link");
			link.type = "text/css";
			link.rel = "stylesheet";
			link.href = 'resources/stylesheets/dev.css';
			document.getElementsByTagName("head")[0].appendChild(link);


		onRequest: (handler) ->
 			@requestHandler = handler

		sendRequest: (tabId, request, response) ->
			if @csListeners
				for listener in @csListeners
					listener request, {}, response

		addContentScriptListener: (listener) ->
			@csListeners ?= []
			@csListeners.push listener

		# cs_listen: (eventName, listener) ->
		# 	console.log 'cs_listen', eventName
		# 	if l = @contentScriptListeners[eventName]
		# 		l.push listener
		# 	else
		# 		@contentScriptListeners[eventName] = [listener]
				
		# cs_stopListening: (eventName, listener) ->
		# 	if l = @contentScriptListeners[eventName]
		# 		i = l.indexOf listener
		# 		l.splice i, 1
		# 		if !l.length
		# 			delete @contentScriptListeners[eventName]

		# cs_BackgroundMessage: (messageName, args, cb) ->
		# 	console.log 'cs_BackgroundMessage', messageName, args
		# 	if listener = @listeners[messageName]
		# 		eventSource = url:document.location.href
		# 		listener eventSource, args, cb
		# 	else
		# 		console.log "No listener for #{request.event}"
			
		# triggerContentScriptEvent: (eventName, args) ->
		# 	console.log 'triggerContentScriptEvent', eventName, args
		# 	if l = @contentScriptListeners[eventName]
		# 		for listener in l
		# 			listener args
		
		# listen: (request, cb) -> @listeners[request] = cb
			
		contentScript: -> DevContentScript
		
		httpRequest: (url, opts) ->
			$.ajax url, 
				data:opts.data
				success:opts.cb
				dataType:opts.dataType
				error: (error) ->
					console.log arguments

		require: (modules, cb) ->
			require modules, cb
				
		setTimeout: (cb, duration) ->
			setTimeout cb, duration

		clearTimeout: (id) ->
			clearTimeout id

		getValue: (name) -> window[name]
		setValue: (name, value) -> window[name] = value
		defaultValue: (name, value) -> window[name] ?= value
