define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class VitacostProductScraper extends ProductScraper
		@testProducts: [
			''
		]
		resources:
			productPage:
				url: -> "#{@productSid}"

		# properties:
			# title:
			# 	resource: 'productPage'
			# 	scraper: PatternResourceScraper new RegExp(/<h1 class="prodName">([^<]*)/), 1

			# price:
			# 	resource: 'productPage'
			# 	scraper: PatternResourceScraper [
			# 		[new RegExp(/data-salePrice="\$([^"]*)/), 1] 
			# 		[new RegExp(/<span itemprop="price">\$([^<]*)/), 1] 
			# 	]

			# image:
			# 	resource: 'productPage'
			# 	scraper: PatternResourceScraper new RegExp(/<img itemprop="image" src="([^"]*)/), 1 #relative links

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

