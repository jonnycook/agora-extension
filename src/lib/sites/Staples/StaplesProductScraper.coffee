define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class StaplesProductScraper extends ProductScraper
		@testProducts: [
			'571863'
		]
		resources:
			productPage:
				url: -> "http://www.staples.com//product_#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^|]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<product envfeeflag="0" comingsoonflag="0" price="([^"]*)/), 1] 
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<img id="largeProductImage" src="([^"]*)/), 1 

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

