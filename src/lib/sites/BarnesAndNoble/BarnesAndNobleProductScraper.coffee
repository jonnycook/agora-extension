
define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class BarnesAndNobleProductScraper extends ProductScraper
		@testProducts: [
			'1113003734'
		]
		resources:
			productPage:
				url: -> "http://www.barnesandnoble.com/w/-/#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<div class="[^"]*" itemprop="price" data-bntrack="[^"]*" data-bntrack-event="[^"]*">\$([^<]*)/), 1]
					[new RegExp(/<span class="bb-price">\s*\$(\S*)/), 1]
					[new RegExp(/<span class="mp-from">from<\/span>\s*\$(\S*)/), 1]
					[new RegExp(/<em class="bb-title-format">NOOK Book<\/em> <span class="bb-title-info">\(eBook\)<\/span>\s*<\/div>\s*<div class="bb-pricing pricing-break-early" itemprop="offers" itemscope itemtype="http:\/\/schema.org\/Offer">\s*<div class="[^"]*" itemprop="price" data-bntrack="[^"]*" data-bntrack-event="[^"]*">\$([^<]*)/), 1]
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
						overview: true #done
						details: true #done
						isbn: true #done
						author: true #done
						rating: true #done
						ratingCount: true #done
						editorialReviews: true #done
						originalPrice: true #done

						shipping: false #same shipping policy across site


					value = {}

					if switches.overview
						matches = @resource.match /<div id="product-commentary-overview-2"([\S\s]*?)<\/section>/
						overviewMatches = matches[1].match /<div class="simple-html"([\S\s]*?)<\/div>/
						value.overview = overviewMatches[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

					if switches.details
						details = {}
						matches = @resource.match /<div class="product-details([\S\s]*?)<\/section>/
						detailMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						for match in detailMatches
							title = match.match(/<span>([\S\s]*?)<\/span>/)[1]
							title = title.match(/([^:]*)/)[1]
							content = match.match(/<\/span>([\S\s]*?)<\/li>/)[1]
							details[title] = content.replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ") #trim spaces and returns etc - .trim() stopped working 
						value.details = details

					if switches.isbn
						matches = @resource.match /<div class="product-details([\S\s]*?)<\/section>/
						isbn = matches[1].match /<span>ISBN-13:<\/span>([\S\s]*?)<\/li>/
						value.isbn = isbn[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")		

					if switches.author
						author = {}
						authorNames = {}
						matches = @resource.match /<ul class="contributors([\S\s]*?)<\/ul>/
						authorMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						count = 0

						for item in authorMatches
							if count > 0
								name = item.match(/<li([\S\s]*?)<\/li>/)[1]
								name = name.match(/<a([\S\s]*?)<\/a>/)[1]
								name = name.match(/>([\S\s]*)/)[1]
								url = item.match(/<li([\S\s]*?)<\/li>/)[1]
								authorNames[name] = url.replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
							count++
						author["names"] = authorNames

						bioMatch = @resource.match /<div class="basic-info([\S\s]*?)<\/section>/
						if bioMatch
							bioMatches = bioMatch[1].match /<div class="content([\S\s]*?)<\/div>/
							bio = bioMatches[1].match />([\S\s]+)/
							author["bio"] = bio[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

						
						imageMatch = @resource.match(/<div id="product-commentary-meet-the-author-1"([\S\s]*?)<\/section>/)
						if imageMatch
							image = imageMatch[1].match /src="([^"]+)/
							if image
								author["authorImage"] = image[1]

						value.author = author

					if switches.rating
						matches = @resource.match /"customerAvgStarRating" : ([\S\s]*?),/
						if matches
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /"customerRatingCount" : ([\S\s]*?),/
						if matches
							value.reviewCount = matches[1]

					if switches.editorialReviews

						matches = @resource.match /<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/
						if matches
							editorialReviews = {}
							erMatches = matches[1].match /<article class="simple-html">([\S\s]*?)<\/article>/g
							for match in erMatches
								from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1]
								content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
								editorialReviews[from] = content
							value.editorialReviews = editorialReviews

					if switches.originalPrice
						matches = @resource.match /"listPrice" : ([\S\s]*?),/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = []
						matches = @resource.match /id="viewer-image-1"([\S\s]*?)<\/li>/
						imageMatches = matches[1].match /data-bn-src-url="([^"]+)/g
						for match in imageMatches
							image = match.match /data-bn-src-url="([^"]+)/
							images.push image[1]
						value.images = images


					#old
					if switches.specifications 
						specifications = {}
						@execBlock ->
							@getResource 'specificationsTab', (resource) ->
								matches = resource.safeMatch /<tbody>([\S\s]*?)<\/tbody>/ # safeMatch throws an error if it can't find a match - use it
								specMatches = matches[1].match /<tr>([\S\s]*?)<\/tr>/g
								for match in specMatches
									name = match.match(/<th[^>]*>([\S\s]*?)<\/th>/)[1]
									details = match.match(/<td>([\S\s]*?)<\/td>/)[1]
									desc = match.match(/<td>([\S\s]*?)<\/td>/g)[1] #finds the second td tags
									desc = desc.match(/<td>([\S\s]*?)<\/td>/)[1] #clips out the td tags
									specifications[name] = details:details, desc:desc
								value.specifications = specifications
								@value value
								@done true
							null

					@value value
