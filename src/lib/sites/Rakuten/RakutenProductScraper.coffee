define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class RakutenProductScraper extends ProductScraper
		@testProducts: [
			'263019782'
		]
		resources:
			productPage:
				url: -> "http://www.rakuten.com/prod/-/#{@productSid}.html"

			altProductPage:
				url: -> "http://www.rakuten.com/pr/product.aspx?sku=#{@productSid}"
				# url: -> "http://www.rakuten.com/pr/product.aspx?sku=#{@productSid}&listingId=#{@productSid2}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<span id="spanMainTotalPrice" class="pr-pricing-total-price" itemprop="price">\$([^<]*)/), 1]
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:image" content="([^"]*)/), 1 #relative links

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true
						overview: true
						details: true
						rating: true
						ratingCount: true
						originalPrice: true

						shipping: false


					value = {}

					if switches.overview
						overview = []
						matches = @resource.match /<div id="product-commentary-overview-1"([\S\s]*?)<\/section>/
						overviewMatches = matches[1].match /<p([\S\s]*?)<\/p>/g
						for match in overviewMatches
							text = match.match /<p([\S\s]*?)<\/p>/
							overview.push text[1]
						value.overview = overview

					if switches.details
						details = []
						matches = @resource.match /<div class="product-details([\S\s]*?)<\/section>/
						detailMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						for match in detailMatches
							title = match.match(/<span>([\S\s]*?)<\/span>/)[1]
							content = match.match(/<\/span>([\S\s]*?)<\/li>/)[1]
							text = title + content
							details.push text.replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ") #trim spaces and returns etc - .trim() stopped working 
						value.details = details

					if switches.isbn
						matches = @resource.match /<div class="product-details([\S\s]*?)<\/section>/
						isbn = matches[1].match /<span>ISBN-13:<\/span>([\S\s]*?)<\/li>/
						value.isbn = isbn[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")		

					if switches.author
						author = {}
						authorNames = []
						matches = @resource.match /<ul class="contributors([\S\s]*?)<\/ul>/
						authorMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						count = 0

						for item in authorMatches
							if count > 0
								name = item.match(/<li([\S\s]*?)<\/li>/)[1]
								authorNames.push name.replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
							count++
						author["names"] = authorNames

						authorBio = []
						bioMatch = @resource.match /<div class="basic-info([\S\s]*?)<\/section>/
						bioMatches = bioMatch[1].match /<p>([\S\s]*?)<\/p>/g
						for match in bioMatches
							par = match.match(/<p>([\S\s]*?)<\/p>/)[1]
							authorBio.push par
						author["bio"] = authorBio

						
						# imageMatch = @resource.match(/<div id="product-commentary-meet-the-author-1"([\S\s]*?)<\/section>/)
						# image = imageMatch[1].safeMatch(/src="([^"]+)/)[1] #Author Image only exists on some pages, make this conditional
						# if image
						# 	author["authorImage"] = image

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
						editorialReviews = {}
						matches = @resource.safeMatch /<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/
						erMatches = matches[1].match /<article class="simple-html">([\S\s]*?)<\/article>/g
						for match in erMatches
							from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1]
							content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^<br \/>+|<br \/>+$/gm,'')
							editorialReviews[from] = content
						value.editorialReviews = editorialReviews

					if switches.originalPrice
						matches = @resource.match /"listPrice" : ([\S\s]*?),/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = []
						matches = @resource.match /<div id="product-image-smaller-1-viewer"([\S\s]*?)<div id="product-promos-aside-1"/
						imageMatches = matches[1].match /data-bn-src-url="([^"]+)/g
						for match in imageMatches
							image = match.match /data-bn-src-url="([^"]+)/
							images.push image[1]
						value.images = images


					@value value
