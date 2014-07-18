define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class MacysProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://www1.macys.com/shop/product/?ID=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<h1 id="productTitle" class="productTitle" itemprop="name">([^<]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta itemprop="price" content="\$([^"]*)/), 1

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta xmlns:og="http:\/\/ogp\.me\/ns#" xmlns:fb="http:\/\/www\.facebook\.com\/2008\/fbml" property="og:image" content="([^"]*)/), 1

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->

