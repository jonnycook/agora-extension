define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class AmericanApparelProductScraper extends ProductScraper
		parseSid: (sid) ->
			[id, color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: -> "http://store.americanapparel.net/product/index.jsp?productId=#{@productSid.id}&c=#{@productSid.color}"

			reviewData:
				url: -> "http://i.americanapparel.net/storefront/ratingsreviews/Reviews.aspx?r=1&s=#{@productSid.id}"

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
			rating:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'rating'
			ratingCount:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'ratingCount'


			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					match = /<input type="hidden" value="([^"]*)" id="skuVarData"\/>/.exec(@resource)[1]

					obj = JSON.parse match.replace /&quot;/g, '"'

					more.colors = (name:name, image:color.hoverImage for name,color of obj.colors)

					more.sizes = (size.value for size in obj.sizes)


					url = @resource.match(/AA\.productImgsUrl = "([^"]*)";/)[1]
					@execBlock ->
						@get url, (response) ->
							more.images = ("http://i.americanapparel.net#{image[1]}" for image in JSON.parse(response))
							@value more
							@done true
						null

					@value more

			reviews:
				resource: 'reviewData'
				scraper: DeclarativeResourceScraper 'reviews', 'reviews'
