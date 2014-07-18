define ['underscore', 'siteConfig'], (_, siteConfig) ->
	class Site
		@productClasses: {}
		@sites: {}

		@siteForUrl: (url) ->
			url = url.match('^https?://(.*)$')?[1]
			if url
				for name, config of siteConfig
					if config.hosts
						for part in config.hosts
							if url.substr(0, part.length) == part
								return @site name, part
			null

			# return @site 'General', host
					
			# throw new Error "no site for host #{host}"


			# parts = url.split '/'
			# host = parts[2]
			# @siteForHost host

			
		# @siteForHost: (host) ->
		# 	null
		
		@site: (name, host) ->
			if matches = name.match /^General\/(.*)$/
				new Site 'General', siteConfig.General, matches[1]
			else
				if @sites["#{name};#{host}"]
					@sites["#{name};#{host}"]
				else
					config = siteConfig[name]
					if config
						@sites["#{name};#{host}"] = new Site name, config, host
					else
						throw new Error "No site '#{name}'"
			
		@productSid: (background, url, cb) ->
			site = @siteForUrl url
			site.productSid background, url, cb

		@siteById: (id) ->
			site = @site id
			unless site
				[name, host] = id.split '/'
				site = @site name, host

			site
		@id: 0
		constructor: (@name, @config, @host) ->
			@nid = Site.id++
			{hosts:@hosts, icon:@icon} = config
			@url = "http://agora.sh/site.php?name=#{@name}"
			allFeatures = ['offers', 'reviews', 'rating', 'priceWatch']
			@features = if config.excludedFeatures then _.difference allFeatures, config.excludedFeatures else allFeatures

			@_productScraper = {}

		hasFeature: (feature) -> feature in @features

		id: ->
			if @name == 'General'
				"#{@name}/#{@host}"
			else
				@name
		
		getSiteInjector: (background, cb) ->
			siteInjectorName = "#{@name}SiteInjector"
			background.require ["sites/#{@name}/#{siteInjectorName}"], (siteInjector) =>
				cb siteInjector, @
				
		getSiteScraper: (background, cb) ->
			siteScraperName = "#{@name}SiteScraper"
			background.require ["sites/#{@name}/#{siteScraperName}"], (siteScraper) ->
				cb siteScraper
			
		productScraperClass: (background, cb) ->
			productScraperName = "#{@name}ProductScraper"
			background.require ["sites/#{@name}/#{productScraperName}"], (productScraper) ->
				cb productScraper
	
		productSid: (background, url, cb, retrievalId) ->
			@productScraperClass background, (productScraper) =>
				productScraper.productSid background, url, cb, retrievalId
				
		productScraper: (background, productSid, cb) ->
			if @_productScraper?[productSid]
				cb @_productScraper?[productSid]
			else
				@cbs ?= {}
				if @cbs[productSid]
					@cbs[productSid].push cb
				else
					@cbs[productSid] = [cb]
					@productScraperClass background, (productScraper) =>
						@_productScraper[productSid] = scraper = new productScraper @, productSid, background
						(cb scraper) for cb in @cbs[productSid]
						delete @cbs[productSid]

		productUrl: (sid) -> @config.productUrl sid

		product: (background, product, cb) ->
			if @config.hasProductClass
				if Site.productClasses[@name]
					siteProduct = new Site.productClasses[@name] product
					siteProduct.site = @
					cb siteProduct
				else
					productClassName = "#{@name}Product"
					background.require ["sites/#{@name}/#{productClassName}"], (productClass) =>
						Site.productClasses[@name] = productClass
						siteProduct = new productClass product
						siteProduct.site = @
						cb siteProduct
			else
				# throw new Error "No site"
				cb()


		# product: (background, product, cb) ->
		# 	productClass = siteProducts.class @name
		# 	siteProduct = new productClass product
		# 	if cb
		# 		cb siteProduct
		# 	siteProduct
