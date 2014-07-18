define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class FancyProductScraper extends ProductScraper
		@testProducts: [
			'405991157672181989'
		]
		resources:
			productPage:
				url: -> "http://fancy.com/things/#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="fancy:name" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<meta property="fancy:price" content="\$([^"]*)/), 1] 
					[new RegExp(/<span id="itemprice" style="display:none">\$([^<]*)/), 1] 
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:image" content="([^"]*)/), 1

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						description: true #done
						reacts: true #done
						select: true #done
						quantity: true #done
						shipping: false #no shipping info available


					value = {}

					if switches.description
						matches = @resource.match /<meta property="og:description" content="([^"]*)/
						value.description = matches[1]

					if switches.select
						select = {}
						matches = @resource.match /<select name="option_id" id="option_id">([\S\s]*?)<\/select>/
						overviewMatches = matches[1].match /<option[^>]*>([^<]*)<\/option>/g
						for match in overviewMatches
							name = match.match(/<option[^>]*>([^<]*)<\/option>/)[1]
							content = match.match(/value="([^"]*)/)[1]
							select[name] = content
						value.select = select

					if switches.quantity
						quantity = {}
						matches = @resource.match /<select name="quantity" id="quantity">([\S\s]*?)<\/select>/
						overviewMatches = matches[1].match /<option[^>]*>([^<]*)<\/option>/g
						for match in overviewMatches
							name = match.match(/<option[^>]*>([^<]*)<\/option>/)[1]
							content = match.match(/value="([^"]*)/)[1]
							quantity[name] = content
						value.quantity = quantity

					if switches.reacts
						matches = @resource.match /reacts="([^"]+)/
						if matches
							num = parseInt(matches[1],10)
							value.reacts = num + 1

					if switches.images
						images = []
						matches = @resource.match /<ul class="big">([\S\s]*?)<\/ul>/
						imageMatches = matches[1].match /background-image:url\(([^\)]+)/g
						for match in imageMatches
							image = match.match /background-image:url\(([^\)]+)/
							images.push image[1]
						value.images = images


					@value value
