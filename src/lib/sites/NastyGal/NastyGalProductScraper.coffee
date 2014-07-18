define ['scraping/ProductScraper'], (ProductScraper) ->
	ProductScraper.declarativeProductScraper 'scraper',
		parseSid: (sid) ->
			[style, name] = sid.split ':'
			style:style, name:name
		resources:
			productPage:
				url: -> "http://www.nastygal.com/-/#{@productSid.name.toLowerCase()}"
		scraper: 'scraper'
		resource: 'productPage'