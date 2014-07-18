define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class AsosProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://us.asos.com/pgeproduct.aspx?iid=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					color = @resource.match(/var preSelectedColour = '([^']*)';/)?[1]
					if color
						color = color.replace(/\s+/g, '').toLowerCase()
						@value @resource.match("http://images.asos-media.com/inv/media/\\d*/\\d*/\\d*/\\d*/\\d*/#{color}/image1xl.jpg")[0]
					else
						@value @resource.match(/<meta name="og:image" content="([^"]*)"\/>/)[1]
			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					@value more
