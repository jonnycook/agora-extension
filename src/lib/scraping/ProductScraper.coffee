define ['./PropertyScraper', './ResourceFetcher', './resourceScrapers/DeclarativeResourceScraper', 'underscore'], (PropertyScraper, ResourceFetcher, DeclarativeResourceScraper, _) ->
	class ProductSid extends String
		constructor: (@value) ->
			String.call @, @value
		toString: -> @value
		valueOf: -> @value

	class ProductScraper
		@declarativeProductScraper: (name, opts) ->
			properties = {}
			for prop in ['title', 'image', 'price', 'more', 'rating', 'ratingCount', 'reviews']
				properties[prop] = 
					resource:opts.resource
					scraper: DeclarativeResourceScraper name, prop, opts.mapping?[prop]

			class DeclarativeProductScraper extends ProductScraper
				resources: opts.resources
				parseSid: opts.parseSid
				properties: properties



		constructor: (@site, productSid, @background) ->
			@productSid = new ProductSid productSid
		
			_.extend @productSid, @parseSid productSid if @parseSid

			if @resources
				resources = @resources
				@resources = {}
			
				for resource, fetcher of resources
					#unless fetcher instanceof ResourceFetcher
					@resources[resource] = new ResourceFetcher @productSid, fetcher
					@resources[resource].site = @site
					@resources[resource].background = @background
					@resources[resource].scraper = @
					#else
					#	@resources[resource] = fetcher
			
			if @properties
				properties = @properties
				@properties = {}
				for property, scraper of properties
					#unless scraper instanceof PropertyScraper
					
					if _.isFunction scraper
						@properties[property] = scrape:scraper, productSid:@productSid
					else
						@properties[property] = new PropertyScraper @productSid, @site, scraper
						@properties[property].productScraper = @
						@properties[property].background = @background
						@properties[property].propertyName = property
	
		resource: (resourceName) ->
			resource = @resources[resourceName]
			if resource
				resource
			else
				throw new Error "no resource '#{resourceName}'"

		versionString: ->
			parts = [@version ? 0]

			if @background.declarativeScrapers
				for scraper in @background.declarativeScrapers
					if scraper.site == @site.name
						parts.push scraper.timestamp

			parts.join ';'

		
		propertyScraper: (propertyName) ->
			@properties[propertyName]

		scrapeProperty: (property, cb) ->
			if env.core
				cb()
			else
				propertyScraper = @propertyScraper property

				if propertyScraper
					propertyScraper.scrape cb
				else
					cb()

		canScrapeProperty: (property) ->
			@propertyScraper property
		
		scrape:	(properties, cb) ->
			values = {}
			num = 0
			collectValue = (prop, value) =>
				values[prop] = value
				if ++ num == properties.length
					cb values
			
			for prop in properties
				do (prop) =>
					@scrapeProperty prop, (value) => collectValue prop, value
					# propertyScraper = @propertyScraper prop
					# propertyScraper.scrape (value) => collectValue prop, value
