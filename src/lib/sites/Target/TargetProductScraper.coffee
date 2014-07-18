define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class TargetProductScraper extends ProductScraper
		@testProducts: [

		]
		resources:
			productPage:
				url: -> "http://www.target.com/p/-/A-#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp('<span class="fn" itemprop="name">([^<]*)'), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<span class="offerPrice" itemprop="price">\s*\$(\S*)/), 1

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<img itemprop="image" height="[^"]*" width="[^"]*" alt="[^"]*" src="([^"]*)/), 1

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

