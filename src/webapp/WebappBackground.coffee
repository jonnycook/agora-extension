define ['jQuery', 'Background', './WebappContentScript'], ($, Background, WebappContentScript) ->
	class WebappBackground extends Background
		constructor: (@type='webapp') ->
			super
		# domain: 'agora.sh/agora'

		getStyles: (cb) ->
			if env.stylesheet
				$.get "#{env.root}/resources/stylesheets/webapp.#{env.stylesheet}.css", cb
			else
				$.get "#{env.root}/resources/stylesheets/webapp.css", cb

		clientLibsPath: -> env.root + '/libs/client/merged.js'

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
			
		contentScript: -> WebappContentScript
		
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

		setInterval: (func, time) -> setInterval func, time
		clearInterval: (id) -> clearInterval id

		getValue: (name) -> window[name]
		setValue: (name, value) -> window[name] = value
		defaultValue: (name, value) -> window[name] ?= value

		getCookie: (domain, name, cb) -> cb()

		getResourceUrl: (resource) ->
			"/view/#{resource}"


		storage:{}
		getStorage: (fields, cb) ->
			cb @storage

		setStorage: (values) ->
			for field,value of values
				@storage[field] = value

		removeStorage: (fields) ->
			for field in fields
				delete @storage[field]
