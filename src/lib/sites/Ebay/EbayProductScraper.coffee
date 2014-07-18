define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class EbayProductScraper extends ProductScraper
		@testProducts: [

		]
		resources:
			productPage:
				url: -> "http://www.ebay.com/itm/-/#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta\s+property="og:title"\s+content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<span\s+class="notranslate"\s+id="prcIsum"\s+itemprop="price"\s+style="[^"]*">US \$([^<]*)/), 1]
					[new RegExp(/<span class="notranslate" id="prcIsum_bidPrice" itemprop="price">US \$([^<]*)/), 1]
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<img id="icImg" class="[^"]*" itemprop="image" src="([^"]*)/), 1

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

