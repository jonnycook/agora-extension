define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class OverstockProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://www.overstock.com/#{@productSid}/product.html"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<div itemprop="name">\s*<h1>([^<]*)<\/h1>\s*<\/div>/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<span name="[^"]*" class="[^"]*"\s*itemprop="price"\s*>\s*\$(\S*)/), 1

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<div class="proImageCenter">\s*<img src="([^"]*)/), 1],
					[new RegExp(/<img width="[^"]*" id="activeImage" src="([^"]*)/), 1],
				]

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

