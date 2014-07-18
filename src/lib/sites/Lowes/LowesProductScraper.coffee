define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class LowesProductScraper extends ProductScraper
		@testProducts: [
			'6051381'
		]
		resources:
			productPage:
				url: -> "http://www.lowes.com/pd_#{@productSid}" #SEE NOTES

		# properties:
		# 	title:
		# 		resource: 'productPage'
		# 		scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content='([^|]*)/), 1

		# 	price:
		# 		resource: 'productPage'
		# 		scraper: PatternResourceScraper [
		# 			[new RegExp(/<span id="vpdSinglePrice">\$([^<]*)/), 1]
		# 			[new RegExp(/<b class="price sale" id='sale_amount' itemprop="price">\$([^<]*)/), 1]
		# 		]

		# 	image:
		# 		resource: 'productPage'
		# 		scraper: PatternResourceScraper new RegExp(/<meta property="og:image" content='([^']*)/), 1 

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

