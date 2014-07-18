define ->	->
	class ContentScript
		constructor: ->
			@listeners = {}
			@eventMap = {}
			@onRequest (request) =>
				if request.eventName
					if @eventMap[request.eventName]
						Debug.log 'ReceivedRequest', request.eventName, @eventMap[request.eventName], request.args
					else 
						Debug.log 'ReceivedRequest', request.eventName, request.args

					if l = @listeners[request.eventName]
						listener(request.args) for listener in l
					else
						# Debug.log 'noListeners', request
				
		mapEvent: (event, obj) ->
			@eventMap[event] = obj

		listen: (eventName, listener, tag) ->
			if @eventMap[eventName]
				#Debug.log "listen #{eventName}", @eventMap[eventName], tag
			else 
				#Debug.log "listen #{eventName}", tag

			if @listeners[eventName]
				@listeners[eventName].push listener
			else
				@listeners[eventName] = [listener]
				@sendRequest request:'listen', eventName:eventName, version:@version, (response) =>
					if response == 'oldVersion'
						siteInjector.onOldVersion()
				
		stopListening: (eventName, listener, tag) ->
			if @eventMap[eventName]
				#Debug.log "stopListening #{eventName}", @eventMap[eventName], tag
			else 
				#Debug.log "stopListening #{eventName}", tag

			if l = @listeners[eventName]
				i = l.indexOf listener
				if i != -1
					l.splice i, 1
				if !l.length
					@sendRequest request:'stopListening', eventName:eventName, version:@version, (response) =>
						if response == 'oldVersion'
							siteInjector.onOldVersion()
					delete @listeners[eventName]

		reloadExtension: ->
			@triggerBackgroundEvent 'reloadExtension'

		triggerBackgroundEvent: (eventName, args, cb) ->
			#Debug.log 'triggerBackgroundEvent', eventName, args
			@sendRequest request:'BackgroundMessage', messageName:eventName, args:args, version:@version,  (response) =>
				if response == 'oldVersion'
					siteInjector.onOldVersion()
				else
					cb? response

		querySelector: (selector) -> document.querySelector selector
		querySelectorAll: (selector) ->	document.querySelectorAll selector
		createElement: (tag) -> document.createElement tag

		safeQuerySelector: (selector) ->
			el = @querySelector selector
			if el then el else throw new Error "#{selector} no found"
			
		selfQuerySelectorAll: (selector) ->
			els = @querySelectorAll
			if els.length then els else throw new Error "#{selector} not found"