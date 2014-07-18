define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class WomanWithinProductScraper extends ProductScraper
		parseSid: (sid) ->
			[sku, style] = sid.split '-'
			sku:sku
			style:style

		resources:
			productPage:
				url: ->
					url = "http://www.womanwithin.com/clothing/-.aspx?pfId=#{@productSid.sku}&producttypeid=1"
					if @productSid.style
						url += "&styleno=#{@productSid.style}"
					url

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			rating:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'rating'
			ratingCount:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'ratingCount'
			reviews:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'reviews'
			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					for color in more.colors
						if color.id == @productSid.style
							more.color = color.name
							break

					@value more
			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					style = @productSid.style
					image = @resource.match("mainimageUrl='(.*?\_#{style}.jpg?[^']*)' colorName")?[1]
					if image
						image = image.replace /&amp;/g, '&'
					else 
						image = /<meta property="og:image" content="([^"]*)/.exec(@resource)[1]

					@value image
