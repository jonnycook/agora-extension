define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	ProductScraper.declarativeProductScraper 'scraper',
		resources:
			productPage:
				url: -> "https://www.renttherunway.com/shop/designers/#{@productSid}"
		scraper: 'scraper'
		resource: 'productPage'
