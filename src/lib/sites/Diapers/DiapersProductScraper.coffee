define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class DiapersProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://www.diapers.com/p/--#{@productSid}"

			reviewPage:
				url: ->
					str = @productSid + ''
					"http://www.diapers.com/amazon_reviews/#{str.substr(0, 2)}/#{str.substr(2, 2)}/#{str.substr(4)}/mosthelpful_Default.html"

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
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					reviews = @declarativeScraper 'scraper', 'reviews'

					obj = reviews:reviews

					@execBlock ->
						@getResource 'reviewPage', (resource) ->
							obj.amazonReviews = @declarativeScraper 'amazonReviews', 'reviews', resource
							@value obj
							@done true
						null

					@value obj

