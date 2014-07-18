define ['model/Model', 'Site', 'model/ModelInstance', 'util'], (Model, Site, ModelInstance, util) ->
	class ProductRetriever
		@cache: {}
		@get: (Product, input) ->
			key = null

			if typeof input == 'number' || typeof input == 'string'
				key = input
			else if input.productSid
				key = "#{input.siteName}/#{input.productSid}"
			else if input.productUrl
				key = input.productUrl
			else
				key = "#{input.pageUrl}|#{input.linkUrl}"

			retriever = @cache[key]
			unless retriever
				retriever = @cache[key] = new ProductRetriever Product, input
			retriever

		constructor: (@Product, @input) ->
			@subscribers = []

			if @input.productSid
				@product = Product.find siteName:@input.siteName, productSid:@input.productSid
			else if @input.retrievalId
				@product = Product.find retrievalId:@input.retrievalId

		_retrieve: (method) ->
			@retrieving = true
			method (product) =>
				@product = product
				if @subscribers.length
					subscriber product for subscriber in @subscribers
					delete @subscribers
				@retrieving = false

		withProduct: (cb, create = true) ->
			if @product
				cb @product
			else
				@subscribers.push cb
				if create && !@retrieving
					if typeof @input == 'number' || typeof @input == 'string'
						@_retrieve (cb) =>
							product = @Product.withId @input
							@Product.update product
							cb product

					else if @input.productSid
						@_retrieve (cb) =>
							cb @Product.getBySid @input.siteName, @input.productSid, @input

					else if @input.retrievalId
						@_retrieve (cb) =>
							product = @Product.find (p) => p.get('retrievalId') == @input.retrievalId
							if product
								cb product
							else
								@Product.getFromUrl @input.productUrl, @input, cb, @input.retrievalId

					else if @input.productUrl
						@_retrieve (cb) =>
							@Product.getFromUrl @input.productUrl, @input, cb

					else
						@_retrieve (cb) =>
							@Product.explorativeGet @input.linkUrl, @input.pageUrl, @input, cb

				else if !@retrieving
					cb null

	class ProductInstance extends ModelInstance
		instanceMethods: ['update', 'displayValue', 'getDisplayValue', 'site', 'interface', 'productId']

		productId: -> @get 'id'

		site: -> Site.site(@get('siteName'))

		interface: (cb) ->
			@model.siteProduct @, cb

		getDisplayValue: (property) ->
			value = @get(property)
			if value == @model.errorMap[property]
				switch property
					when 'ratingCount'
						'error'
					when 'image'
						agora.background.getResourceUrl 'resources/images/agorabelt-512.png'
					else
						'(error)'
			else
				switch property
					when 'price'
						@get 'displayPrice'
					when 'ratingCount'
						util.numberWithCommas value
					else
						value

		displayValue: (property) ->
			(value) => @getDisplayValue property

		update: -> @model.update @

		retrievers: 
			more: (cb) ->
				site = Site.site @_get 'siteName'
				site.productScraper @model.background, @get('productSid'), (scraper) =>
					scraper.scrapeProperty 'more', (value, error) ->
						if error
							cb {}
						else
							cb value
			reviews: (cb) ->
				site = Site.site @_get 'siteName'
				site.productScraper @model.background, @get('productSid'), (scraper) =>
					if scraper.canScrapeProperty 'reviews'
						scraper.scrapeProperty 'reviews', cb
					else
						cb()

			offers: (cb) ->
				site = Site.site @_get 'siteName'
				if site.config.query
					getOffers = =>
						query = site.config.query @
						query.site = @_get 'siteName'

						@model.background.httpRequest "#{@model.background.apiRoot}products.php",
							data:query
							cb: (response) ->
								cb (if response.products == '' then null else response.products)
								# product.set 'sem3_id', response.sem3Id


					if (!site.config.hasMore || @get 'more')
						getOffers()
					else
						@field('more').observe (mutation) =>
							if mutation.value
								@field('more').stopObserving arguments.callee
								getOffers()
				else
					console.debug 'no offers'
					cb()


	class Product extends Model
		errorMap:
			title:'AGORA_ERROR'
			image:'AGORA_ERROR'
			price:'AGORA_ERROR'
			rating:-1
			ratingCount:999999999

		constructor: ->
			super
			@ModelInstance = ProductInstance

		init: ->
			@_list.observe (mutation) =>
				if mutation.type == 'insertion'
					instance = mutation.value
					if !instance.get('image')
						instance.update()

		update: (product) ->
			if !env.core
				site = Site.site(product.get 'siteName')
				site.productScraper @background, product.get('productSid'), (scraper) =>
					version = scraper.versionString()
					allProperties =  ['title', 'price', 'image']

					if 'rating' in site.features
						allProperties = allProperties.concat ['rating', 'ratingCount']

					properties = []
					if product.get('scraper_version') != version
						# console.debug 'wrong version', product.get('scraper_version'), version
						properties = allProperties
					else
						for property in allProperties
							if !product._get(property)?
								properties.push property

					product.retrieve 'more'# if site.config.hasMore
					if !Product.node
						product.retrieve 'reviews' if 'reviews' in site.features
						product.retrieve 'offers' if 'offers' in site.features

					if properties.length
						product.set 'last_scraped_at', parseInt new Date().getTime()/1000
						product.set 'scraper_version', version

						count = properties.length
						errors = 0
						product.set 'status', 1

						for property in properties
							do (property) =>
								scraper.scrapeProperty property, (value, error) =>
									if error
										++errors
										product.set property, @errorMap[property]
									else
										product.set property, value

									if !--count
										if errors
											product.set 'status', 2
										else
											product.set 'status', 3
									# console.log property, value, JSON.stringify(value), product.get(property)
									# if property == 'title' && 'deals' in site.features && !Product.node
									# 	@background.httpRequest "#{@background.apiRoot}coupons.php",
									# 		data:{query:value}
									# 		cb: (response) ->
									# 			product.set 'coupons', response


		getBySid: (siteName, productSid, context) ->
			console.log "#{siteName} #{productSid}"
			product = @find (p) =>
				p._get('siteName') == siteName && p._get('productSid') == productSid
			
			site = Site.site(siteName)

			unless product
				product = @add
					siteName: siteName
					productSid: productSid
					image: context?.image
					retrievalId: context?.retrievalId
					status:0

			@update product
			
			product

		getFromUrl: (url, context, cb, retrievalId) ->
			site = Site.siteForUrl url
			
			site.productSid @background, url, ((productSid) =>
				if productSid
					cb @getBySid site.name, productSid, context
				else
					throw new Error "failed to get sid from #{url}"
					cb()
			), retrievalId

		explorativeGet: (linkUrl, pageUrl, context, cb) ->
			if linkUrl
				@background.httpRequest linkUrl, 
					cb: (response, extra) =>
						if extra.header('Content-Type').match /^text\/html/
							@getFromUrl linkUrl, context, cb
						else
							@getFromUrl pageUrl, context, cb
			else
				@getFromUrl pageUrl, context, cb

		scraper: (input, cb) ->
			@resolveInput input, (input) =>
				site = Site.site input.siteName
				site.productScraper @background, input.productSid, cb

		resolveInput: (input, cb) ->
			if input.siteName && input.productSid
				cb input
			else if input.productUrl
				site = Site.siteForUrl input.productUrl
				
				site.productSid @background, input.productUrl, (productSid) =>
					cb siteName:site.name, productSid:productSid
			else
				throw new Error "invalid input"

		get: (input, cb, create = true) ->
			retriever = ProductRetriever.get @, input
			retriever.withProduct cb, create

		siteProduct: (product, cb) ->
			site = Site.site(product.get 'siteName')
			site.product @background, product, cb

		images: (product, cb) ->
			@siteProduct product, (siteProduct) ->
				if siteProduct
					siteProduct.images cb
				else
					cb()
