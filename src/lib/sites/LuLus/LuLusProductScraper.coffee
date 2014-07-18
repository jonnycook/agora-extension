define ['scraping/ProductScraper'], (ProductScraper) ->
	ProductScraper.declarativeProductScraper 'scraper',
		resources:
			productPage:
				url: -> "http://www.lulus.com/products/#{@productSid}.html"
		scraper: 'scraper'
		resource: 'productPage'
		mapping:
			rating: (rating) -> rating/100 * 5