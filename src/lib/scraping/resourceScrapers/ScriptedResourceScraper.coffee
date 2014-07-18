define ['underscore', '../ResourceScraper', 'BlockRunner', '../DeclarativeScraper'], (_, ResourceScraper, BlockRunner, DeclarativeScraper) ->
	class ScriptedResourceScraper extends ResourceScraper
		constructor: (@script) -> return ResourceScraper arguments if @ == window
		value: (arg) ->
			if _.isUndefined arg then return @vCont.value
			else if typeof arg == 'object' && !_.isArray arg
				if typeof @vCont.value != 'object' then @vCont.value = {}
				_.extend @vCont.value, arg
			else
				@vCont.value = arg
			
		scrape: (cb) ->
			@vCont = {}
			A = ->
			A.prototype = @
			a = new A
			
			_.extend a, BlockRunner.prototype
			BlockRunner.call a, @script
			
			a.onDone => 
				cb @vCont.value
			a.exec()

		get: (url, cb, fail=null) ->
			@propertyScraper.productScraper.background.httpRequest url,
				method: 'get'
				dataType: 'text'
				cb: (responseText, response) =>
					if response.status == 200 || response.status == 'success'
						# console.log result
						# resource = @cache = new Resource responseText, url
						cb.call @, responseText
					else
						if fail
							fail response
						else
							throw new Error "#{url}: http status #{response.status}"

		post: (url, data, cb) ->
			@propertyScraper.productScraper.background.httpRequest url,
				method: 'post'
				dataType: 'text'
				data:data
				cb: (responseText, response) =>
					if response.status == 200 || response.status == 'success'
						# console.log result
						# resource = @cache = new Resource responseText, url
						cb.call @, responseText
					else
						throw new Error "#{url}: http status #{response.status}"

		matchAll: (string, pattern, group=false) ->
			matches = string.match new RegExp (if _.isString pattern then pattern else pattern.source), 'g'
			if matches
				if group==false
					for match in matches
						match.match pattern
				else
					for match in matches
						match.match(pattern)[group]
			else
				[]

			
		getResource: (resourceName, cb) ->
			resourceFetcher = @propertyScraper.productScraper.resource resourceName
			resourceFetcher.fetch (resource) =>
				cb.call @, resource

		declarativeScraper: (name, property=@propertyScraper.propertyName, subject=null) ->
			scrapers = @propertyScraper.productScraper.background.declarativeScrapers
			for scraper in scrapers
				if scraper.site == @site.name && scraper.name == name
					if scraper.properties[property]
						scraper = new DeclarativeScraper scraper.properties[property]
						try
							result = scraper.scrape(subject ? @resource)[0]?.value
							return if @map then @map result else result
						catch e
							e.info = path:scraper.getPath()
							throw e
					else
						return null
			throw new Error "failed to find scraper for #{@site.name} #{@name}"

# return DeclarativeScraper(scraper.properties[property], this.resource)[0].value;