define ['../ChromeBrowser'], (ChromeBrowser) ->
	class TestBrowser extends ChromeBrowser
		constructor: ->
			
		listen: (request, cb) ->
			@listeners ?= {}
			@listeners[request] = cb
			
		triggerRequest: (source, request, sendResponse) ->
			@listeners?[request]? source, sendResponse
			
			
		httpGet: (opts) ->
			if data = @urlData?[opts.url]
				opts.cb data
			else
				super