define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class Singer22ProductScraper extends ProductScraper
		parseSid: (sid) -> {}

		resources:
			productPage:
				url: -> "http://www.singer22.com/#{@productSid}.html"

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

					match = /var arrProductImages = (\{[\S\s]*?\}\})/.exec(@resource)[1]

					obj = JSON.parse match
					more.colorImages = obj

					@value more

			# reviews:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->