define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class FreePeopleProductScraper extends ProductScraper
		parseSid: (sid) ->
			[id, name, color] = sid.split ':'
			id:id, name:name, color:color

		@productSid: (background, url, cb) ->
			background.httpRequest url,
				cb: (response) ->
					name = /<link rel="canonical" href="http:\/\/www\.freepeople\.com\/([^\/]*)\/"\/>/.exec(response)[1]
					id = response.match(/<meta name="apple-itunes-app" content="app-id=\d*,app-argument=.*?([^\/"]*)">/)[1]
					cb "#{id}:#{name}"

		resources:
			productPage:
				url: ->
					url = "http://www.freepeople.com/#{@productSid.name}"

					if @productSid.color
						url += "/_/productOptionIDs/#{@productSid.color}"

					url

			reviewData:
				url: -> "http://freepeople.ugc.bazaarvoice.com/3393/#{@productSid.id}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image'
			# price:
			# 	resource: 'productPage'
			# 	scraper: 
			# image:
			# 	resource: 'productPage'
			# 	scraper: 
			# rating: 
			# 	resource: 'productPage'
			# 	scraper:
			# ratingCount: 
			# 	resource: 'productPage'
			# 	scraper: 
			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					matches = /var productImages = \$\.namespace\('WEBLINC.productImages'\);([\S\s]*?)<\/script>/.exec(@resource)[1]
					imageMatches = @matchAll matches, /productImages\['[^']*'\]\["([^"]*)"\]\["([^"]*)"]\["(aliasName|altSize|zoomSize|detailSize)"\] = "([^"]*)";/

					imageMap = {}
					for match in imageMatches
						imageMap[match[1]] ?= {}
						imageMap[match[1]][match[2]] ?= {}
						imageMap[match[1]][match[2]][match[3]] = match[4]
						
					images = {}
					for colorId, imageData of imageMap
						imgs = []
						for i,img of imageData
							imgs.push
								altSize:img.altSize
								detailSize:img.detailSize
								zoomSize:img.zoomSize
								
						images[(imageData['0'] ? imageData['a']).aliasName] = imgs


					more.images = images

					more.currentColor = /<dd class="alias" itemprop="color" data-integration="productDetail-colorAlias">([^<]*)/.exec(@resource)[1]
				
					@value more

			rating:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					id = @resource.match(/<meta name="apple-itunes-app" content="app-id=\d*,app-argument=.*?([^\/"]*)">/)[1]
					@execBlock ->
						@get "http://freepeople.ugc.bazaarvoice.com/3393/#{id}/reviews.djs?format=embeddedhtml", (response) =>
							@value response.match(/title=\\"([\d.]*) out of 5\\"/)?[1] ? 0
							@done true
						null

			ratingCount:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					id = @resource.match(/<meta name="apple-itunes-app" content="app-id=\d*,app-argument=.*?([^\/"]*)">/)[1]
					@execBlock ->
						@get "http://freepeople.ugc.bazaarvoice.com/3393/#{id}/reviews.djs?format=embeddedhtml", (response) =>
							@value response.match(/<span class=\\"BVRRNumber\\">(\d*)<\\\/span> product reviews/)?[1] ? 0
							@done true
						null

			reviews:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					id = @resource.match(/<meta name="apple-itunes-app" content="app-id=\d*,app-argument=.*?([^\/"]*)">/)[1]
					@execBlock ->
						@get "http://freepeople.ugc.bazaarvoice.com/3393/#{id}/reviews.djs?format=embeddedhtml", (response) =>
							reviewsText = response.match(/BVRRDisplayContentBodyID([\S\s]*)/)?[1]
							if reviewsText
								titleMatches = @matchAll reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1
								
								contentMatches = @matchAll reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1

								ratingsMatches = @matchAll reviewsText, /title=\\"(\d+) out of 5\\"/, 1

								authorMatches = @matchAll reviewsText, /<span class=\\"BVRRNickname\\">([^<]*?) <\\\/span>/, 1

								dateMatches = @matchAll reviewsText, /<span class=\\"BVRRValue BVRRReviewDate\\">([^<]*)<\\\/span>/, 1

								reviews = for titleMatch,i in titleMatches
									title:titleMatch
									content:contentMatches[i]
									rating:ratingsMatches[i]
									author:authorMatches[i]
									date:dateMatches[i]
								@value reviews
							else
								@values []
							@done true
						null
