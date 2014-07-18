define ['underscore', './Resource'], (_, Resource) ->
	class ResourceFetcher
		@id:0
		constructor: (@productSid, args) ->
			@id = ResourceFetcher.id++
			{url:@url, requires:@requires} = args

		resetDeleteTimeout: ->
			clearTimeout @deleteTimeoutId
			@deleteTimeoutId = setTimeout (=>
				delete @cache
			), 1000*30
		
		fetch: (cb) ->
			if @cache
				@resetDeleteTimeout()
				cb @cache
			else if @fetching
				@cbs.push cb
			else if @url?
				@cbs = [cb]
				@fetching = true

				doFetch = (url) =>
					console.debug "fetching url #{url}"
					@background.httpRequest url,
						method: 'get'
						dataType: 'text'
						cb: (responseText, response) =>
							console.debug "fetched url #{url}"
							@fetching = false
							if response.status == 200 || response.status == 'success'
								# console.log result
								@cache = resource = new Resource responseText, url
								cb resource for cb in @cbs
								delete @cbs
								@resetDeleteTimeout()
							else
								delete @cbs
								@fetching = false
								throw new Error "#{url}: http status #{response.status}"
						error: =>
							console.debug "failed fetched url #{url}"

							@fetching = false
							cb null for cb in @cbs
							delete @cbs

				if @requires
					@scraper.resource(@requires).fetch (resource) =>
						doFetch @url resource
				else
					doFetch @url()

			else
				throw new Error 'ResourceFetcher must have URL constructor'