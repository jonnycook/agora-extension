define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class ReiProductScraper extends ProductScraper
		@testProducts: [
			'868539'
		]
		resources:
			productPage:
				url: -> "http://www.rei.com/product/#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta name="name" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<li class="price" itemprop="price">[\s]*\$([^<]*)/), 1] 
					[new RegExp(/<li class="salePrice price" itemprop="price">[\s]*\$([^<]*)/), 1] 
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:image" content="([^"]*)/), 1


			rating:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->	
					matches = @resource.match /recommendation_ratings="([^"]+)/
					if matches
						@value matches[1]

			ratingCount:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->		
					matches = @resource.match /recommendation_count="([^"]+)/
					if matches
						@value matches[1]

			# reviews:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->		
			# 		ratUrl = "http://reviews.walgreens.com/2001/prod#{@productSid}/-/reviews.htm"
			# 		revs = []
			# 		@execBlock ->
			# 			@get ratUrl, (response)->
			# 				reviews = response.match /<div id="BVRRDisplayContentReviewID([\S\s]*?)BVRRSSeparatorContentBodyBottom/g
			# 				if reviews
			# 					for entry in reviews
			# 						isReview = entry.match /class="BVRRValue BVRRReviewTitle">([^<]*)/
			# 						if isReview
			# 							if isReview[1].length != 0
			# 								revHash = {}
			# 								revHash["author"] = entry.match(/class="BVRRNickname">([^<]+)/)[1]				
			# 								revHash["title"] = entry.match(/class="BVRRValue BVRRReviewTitle">([^<]+)/)[1]
			# 								revHash["review"] = entry.match(/class="BVRRReviewText">([\S\s]*?)<\/span>/)[1]
			# 								rating = entry.match /BVRRRatingNumber">([\S\s]*?)<\/span>/
			# 								if rating
			# 									if rating[1].length != 0
			# 										revHash["rating"] = rating[1]
			# 								revHash["time"] = entry.match(/BVRRReviewDate">([\S\s]*?)<\/span>/)[1]
			# 								revs.push revHash
			# 				@value revs	
			# 				@done true
			# 			null
			# 		@value revs


			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						overview: true #done
						details: true #done
						specifications: true #done
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done

						shipping: false #free shipping over $50 - sitewide


					value = {}

					if switches.overview
						matches = @resource.match /<h2 class="primaryProductDescription">([\S\s]*?)<\/h2>/
						value.overview = matches[1]

					if switches.details
						matches = @resource.match /<div class="tabArea1">([\S\s]*?)<\/div>/
						value.details = matches[1]

					if switches.specifications
						matches = @resource.match /<table id="spec_table"([\S\s]*?)<\/table>/
						value.specifications = "<table" + matches[1] + "</table>"					

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
						matches = @resource.match /class="originalPrice">([\S\s]*?)<\//
						if matches
							matches = matches[1].match /\$([\S\s]*)/
							value.originalPrice = matches[1]

					if switches.images
						images = []
						imageMatches = @resource.match /hiresimg="([^"]+)/g
						for match in imageMatches
							image = match.match /hiresimg="([^"]+)/
							images.push "http://www.rei.com" + image[1]
						value.images = images


					@value value
