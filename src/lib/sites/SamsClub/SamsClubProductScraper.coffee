define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class SamsClubProductScraper extends ProductScraper
		@testProducts: [
			'11690047'
		]
		resources:
			productPage:
				url: -> "http://www.samsclub.com/sams/-/prod#{@productSid}.ip"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<span itemprop="name">([^<]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/'item_price':'([^']*)/), 1] 
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper(new RegExp(/<div class="[^"]*" id='plImageHolder'>[\s]*<img src='([^\?]*)/), 1).config
					map: (value) -> "#{value}?$img_size_500x500$"

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						details: true #done
						rating: true #done
						ratingCount: true #done
						originalPrice: false # haven't found a page with any sales on it

						shipping: false


					value = {}



					if switches.details
						matches = @resource.match /<div class="[^"]*" id="tabItemDetails">([\S\s]*?)id="tabRatings"/
						value.details = "<div>" + matches[1] + "> </div>"

					if switches.rating
						rating = []
						ratingURL = "http://samsclub.ugc.bazaarvoice.com/1337/prod#{@productSid}/reviews.djs?format=embeddedhtml"
						@execBlock ->
							@get ratingURL, (response)->
								match = response.match /<span class=\\"BVRRNumber BVRRRatingNumber\\">([^<]*)/
								if match
									rating.push match[1]
								@done true
								@value value
							null
						value.rating = rating

					if switches.reviewCount
						reviewCount = []
						ratingURL = "http://samsclub.ugc.bazaarvoice.com/1337/prod#{@productSid}/reviews.djs?format=embeddedhtml"
						@execBlock ->
							@get ratingURL, (response)->
								match = response.match /<span class=\\"BVRRNumber\\">([^<]*)/
								if match
									reviewCount.push match[1]
								@done true
								@value value
							null
						value.reviewCount = reviewCount

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
						images = {}
						matches = @resource.match /<div class="variantSwatches([\S\s]*?)<div class="clearfix"/
						if matches
							imageMatches = matches[1].match /<a([\S\s]*?)<\/a>/g
							for match in imageMatches
								style = match.match(/data-value="([^"]+)/)[1]
								swatch = match.match(/src='([^']+)/)[1]
								styleNum = match.match(/http:\/\/scene7.samsclub.com\/is\/image\/samsclub\/([\S\s]*?)_S1/)[1]
								jsonUrl = "http://scene7.samsclub.com/is/image/samsclub/" + styleNum + "?req=imageset,json&id=init"
								styleImages = []
								do (jsonUrl, styleImages) =>

									@execBlock ->
										@get jsonUrl, (response)->
											numMatches = response.match /\/([0-9A-Z_]*?);/g
											for numMatch in numMatches
												num = numMatch.match(/\/([0-9A-Z_]*?);/)[1]
												styleImages.push "http://scene7.samsclub.com/is/image/samsclub/" + num + "?$img_size_380x380$"
											@done true
											@value value
										null
								styleImages.push swatch
								images[style] = styleImages
						else
							styleNum = @resource.match(/var imageList = '([\S\s]*?)';/)[1]
							jsonUrl = "http://scene7.samsclub.com/is/image/samsclub/" + styleNum + "?req=imageset,json&id=init"
							styleImages = []
							do (jsonUrl, styleImages) =>

								@execBlock ->
									@get jsonUrl, (response)->
										numMatches = response.match /\/([0-9A-Z_]*?);/g
										for numMatch in numMatches
											num = numMatch.match(/\/([0-9A-Z_]*?);/)[1]
											styleImages.push "http://scene7.samsclub.com/is/image/samsclub/" + num + "?$img_size_380x380$"
										@done true
										@value value
									null
							images["main"] = styleImages
						value.images = images


					@value value
