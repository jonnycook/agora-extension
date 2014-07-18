define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class MakeMeChicProductScraper extends ProductScraper
		parseSid: (sid) ->
			# [sku, name] = sid.split ':'
			# sku:sku
			# name:name
			name:sid

		resources:
			productPage:
				url: -> "http://www.makemechic.com/#{@productSid.name}.html"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image'

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					imageUrl = /<meta property="og:image" content="([^"]*)/.exec(@resource)[1]
					colorAbbreviation = imageUrl.match(/\/\w+-([a-z]+)[^\/]*\.jpg$/)[1]

					colorId = @resource.match(new RegExp("<li class=\"color-swatch-85-(\\d*)\\s*\">\\s*<span[^>]*>[^<]*</span>\\s*<img class=\"image-base\" src=\"[^\"]*\/\\w+-#{colorAbbreviation}.\\w+\""))?[1]
					if colorId
						for color in more.colors
							if color.id == colorId
								more.color = color.name
								break

					match = /var spConfig = new Product.Config\((.*?)\);/.exec(@resource)[1]

					obj = JSON.parse match

					images = {}
					more.images = images

					for option in obj.attributes[85].options
						do (option) =>
							@execBlock ->
								@post "http://www.makemechic.com/cloudzoom/ajax/images/", _.map(option.products, (i) -> "products[]=#{i}").join('&'), (response) ->
									imgs = JSON.parse response
									images[option.label] = _.map imgs, (img) -> small:img.small, big:img.big
									@value more
									@done true
								null

					@value more