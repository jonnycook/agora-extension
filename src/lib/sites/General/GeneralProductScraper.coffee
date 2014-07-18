define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper) ->
	class GeneralProductScraper extends ProductScraper
		@productSid: (background, url, cb) ->
			cb url

		resources:
			page: #new ResourceFetcher
				url: -> @productSid

		properties:
			title: #new PropertyScraper
				resource: 'page'
				scraper: PatternResourceScraper /<title>\s*([^<]*)<\/title>/i, 1
			price: #new PropertyScraper
				resource: 'page'
				scraper: PatternResourceScraper(/((?:\$|EUR )[0-9]+([.,][0-9]+)?)/, 1, true, '')
			# image: (cb) -> cb null #new PropertyScraper
				# resource: 'page'
				# scraper: 
