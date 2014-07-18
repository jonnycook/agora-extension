define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class GapProductScraper extends ProductScraper
		@testProducts: [
			135898
			941783012
		]
		resources:
			productPage:
				url: -> "http://www.gap.com/browse/product.do?pid=#{@productSid}"
			productData:
				url: -> "http://www.gap.com/browse/productData.do?pid=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<h1>\s*(.*?)\s*<\/h1>/), 1

			price:
				resource: 'productData'
				scraper: PatternResourceScraper [
					[new RegExp(/<span class="priceDisplay">\$([^<]*)/), 1]
					[new RegExp(/<span class="priceDisplay"><span class="priceDisplaySale">\$([^<]*)/), 1]
				]

			image:
				resource: 'productData'
				scraper: (PatternResourceScraper new RegExp(/"Main\^,\^([^|]*)/), 1).config map:(value) -> "http://www.gap.com#{value}" if value

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

