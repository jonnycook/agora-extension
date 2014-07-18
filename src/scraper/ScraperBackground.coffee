define ['jQuery', 'Background'], ($, Background) ->
	class ScraperBackground extends Background		
		getVersion: -> '0.3.22'
		httpRequest: (url, opts) ->
			$.ajax url, 
				type:opts.method
				data:opts.data
				dataType:opts.dataType
				success: (response, status, xhr) ->
					opts?.cb? response, 
						status: status
						header: (name) -> xhr.getResponseHeader name

				error: (error) ->
					console.log name, value for name,value of error
					opts?.error?()


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
