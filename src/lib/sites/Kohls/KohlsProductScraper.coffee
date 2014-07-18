define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class KohlsProductScraper extends ProductScraper
		@testProducts: [

		]
		parseSid: (sid) ->
			[id, color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: ->
					url = "http://www.kohls.com/product/prd-#{@productSid.id}/.jsp"
					if @productSid.color
						url += "?skuId=#{@productSid.color}"
					url

		resources:
			productPage:
				url: -> "http://www.kohls.com/product/prd-#{@productSid}/.jsp"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<div class="sale">[\s]*Sale[\s]*\$([\S\s]*?)[\s]*<\/div>/), 1]
					[new RegExp(/br_data.sale_price = "\$([^"]*)/), 1]
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
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done
						options: true
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

					if switches.description
						matches = @resource.match /<div class="Bdescription">([\S\s]*?)<\/div>/
						if matches
							value.description = matches[1]

					if switches.options
						options = []
						matches = @resource.match /var allVariants={([\S\s]*?)<\/script>/

					# if switches.options
					# 	options = []
					# 	matches = @resource.match /<div class="column_content([\S\s]*?)<div class="product-cd/
					# 	matches = matches[1].match /<div class="price-holder">([\S\s]*?)<div class="spacer-dotted">/g
					# 	for match in matches
					# 		optionSet = {}
					# 		optionName = match.match(/<div id="([^"]+)/)[1]
					# 		optionMatches = match.match /<a id="([^"]+)/g
					# 		for optionMatch in optionMatches







					# 		options.push optionName


					# 	# sizeMatches = matches[1].match /<li id="size"([\S\s]*?)<\/li>/g
					# 	# if sizeMatches
					# 	# 	sizes = {}
					# 	# 	for match in sizeMatches
					# 	# 		code = match.match(/<a id='([^']+)/)[1]
					# 	# 		size = match.match(/<a[^>]+>([\S\s]*?)<\/a>/)[1]
					# 	# 		sizes[size] = code
					# 	# 	options.push sizes

					# 	# colorMatches = matches[1].match /<a class="swatch"([\S\s]*?)<\/a>/g
					# 	# if colorMatches
					# 	# 	colors = {}
					# 	# 	for match in colorMatches
					# 	# 		code = {}
					# 	# 		name = match.match(/alt="([^"]*)/)[1]
					# 	# 		code["image"] = "http://s7d9.scene7.com/is/image/JCPenney/" + match.match(/onmouseover="updateRender\('([^']*)/)[1] + "?wid=500&hei=500&fmt=jpg&op_usm=.4,.8,0,0&resmode=sharp2" 
					# 	# 		code["swatch"] = match.match(/src="([^"]*)/)[1]
					# 	# 		code["number"] = match.match(/<a class="swatch" href='([^']*)/)[1]
					# 	# 		colors[name] = code
					# 	# 	options.push colors						


					# 	value.options = options

					

					if switches.rating
						rating = []
						ratingURL = "http://kohls.ugc.bazaarvoice.com/9025/#{@productSid}/reviews.djs?format=embeddedhtml"
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
						matches = @resource.match /var numberOfReviews = "([^"]*)/
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
						matches = @resource.match /br_data.price = "\$([^"]*)/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = {}
						matches = @resource.match /<div id="rightCarousel"([\S\s]*?)<\/div>/
						imageMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						for match in imageMatches
							image = match.match /rel="([^"]+)/
							title = match.match /title="([^"]+)/
							images[title[1]] = image[1]
						value.images = images


					@value value
