define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class SoapProductScraper extends ProductScraper
		parseSid: (sid) -> {}

		resources:
			productPage:
				url: -> "http://www.soap.com/p/product-#{@productSid}"

			reviewPage:
				url: ->
					str = @productSid + ''
					"http://www.soap.com/amazon_reviews/#{str.substr(0, 2)}/#{str.substr(2, 2)}/#{str.substr(4)}/mosthelpful_Default.html"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			rating:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'rating'
			ratingCount:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'ratingCount'
			more:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'more'
			reviews:
				resource: 'reviewPage'
				scraper: DeclarativeResourceScraper 'reviews', 'reviews'
