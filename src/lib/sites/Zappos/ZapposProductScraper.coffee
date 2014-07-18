define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, DeclarativeResourceScraper, _) ->


	matchAll = (string, pattern) ->
		matches = string.match new RegExp (if _.isString pattern then pattern else pattern.source), 'g'
		if matches
			for match in matches
				match.match pattern
		else
			[]

	class ZapposProductScraper extends ProductScraper
		@productSid: (background, url, cb) ->
			background.httpRequest url,
				cb: (response) ->
					matches = /<span id="sku" itemprop="sku">SKU (\d+)<\/span>/.exec response
					
					if matches
						sku = matches[1]
						
						matches = /<input type="hidden" id="color" value="(\d+)" name="colorId" \/>/.exec response
						if matches
							colorId = matches[1]
						else
							matches = /<select id="color" name="colorId" class="btn secondary">([\S\s]+)<\/select>/.exec response
							matches = /<option value="(\d+)" selected="selected">[^<]+<\/option>/.exec matches[1]

							colorId = matches[1]
					
						cb "#{sku}-#{colorId}"
					else
						cb()

		resources:
			productPage:
				url: -> @site.productUrl @productSid

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

			rating:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'rating'

			ratingCount:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'ratingCount'

			reviews:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'reviews'

				# scraper: ScriptedResourceScraper ->
				# 	additionalReviews = @resource.match(/<a href="[^"]*" title="Go to Additional Customer Reviews" class="[^"]*">Read Additional (\d+) Customer Reviews<\/a>/)?[1] ? 0

				# 	matches = @resource.safeMatch /<div id="productReviews">([\S\s]*?)<div id="brandLogo">/
				# 	matches = @matchAll matches[1], /<div class="review(?: first)?">([\S\s]*?)<\/ul>\s*<\/div>\s*<\/div>/
				# 	reviews = []
				# 	# for match in matches
				# 	for match in matches
				# 		id = match[1].match(/<div id="(review-\d*)"/)[1]
				# 		authorMatch = match[1].match /<li class="reviewAuthor" itemprop="author">([\S\s]*?)<span id="reviewRole" class="title"> - ([\S\s]*?)<\/span>/

				# 		review =
				# 			review:match[1].match(/<p class="reviewContent" itemprop="description">([\S\s]*?)<\/p>/)[1]
				# 			url:"#{@resource.url}##{id}"
				# 			rating:match[1].match(/<em>Overall:<\/em>\s*<span class="stars rating(\d)">/)[1]
				# 			title: "#{authorMatch[1]} - #{authorMatch[2]}"

				# 		reviews.push review
				# 		# console.log 'asdf', match[1]

				# 	@value reviews:reviews, url:"#{@resource.url}#productReviews", count:reviews.length + parseInt additionalReviews
				# 	# console.log matches


			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->


					switches = 
						# name: false
						styles: true
						# dimensions: true
						# brand: true
						# description: true
						# videoDescription: false
						# type: false
						# gender: false
						# category: false
						# subCategory: false


					value = @declarativeScraper 'scraper'

					# if switches.name
					# 	matches = @resource.match /<a href="[^"]*" class="link fn">([^<]*)/
					# 	value.name = matches[1]

					# styles
					if switches.styles
						styles = {}

						colorToStyle = {}

						currentColorId = @resource.match(/<option value="(\d*)" selected="selected">/)[1]

						matches = @resource.match /var styleIds = \{([^}]*)/
						matches = matches[1].match /'([^']*)':\s*(\d*)/g
						for match in matches
							m = match.match /'([^']*)':\s*(\d*)/
							colorId = m[1]
							styleId = m[2]
							styles[styleId] = 
								id:styleId
								color: id:colorId
								images:{}

							colorToStyle[colorId] = styleId


						value.currentStyle = colorToStyle[currentColorId]


						## swatches
						# pattern = /\.swatch-(\d*) span \{background-image:url\(([^)]*)\);\}/
						# matches = @resource.match new RegExp pattern.source, 'g'

						matches = @matchAll @resource, /<img src="([^"]*)" class="gae-click\*Product-Page\*PrImage\*Swatch" \/>/
						# for match in matches
						# 	[colorId,swatch] = match.match(pattern).slice(1)
						# 	styles[colorToStyle[colorId]].swatchUrl = swatch

						for match in matches
							url = match[1]
							styleId = /http:\/\/[^.]*.zassets.com\/images\/[a-z]*\/\d\/.*?\/(\d*)-[a-z]-\w*\.jpg/.exec(url)[1]
							styles[styleId].thumbUrl = url


						## colors
						matches = @resource.match /var colorNames = \{([^}]*)/
						matches = matches[1].match /'([^']*)':"([^"]*)"/g

						for match in matches
							m = match.match /'([^']*)':"([^"]*)"/
							colorId = m[1]
							colorName = m[2]
							styleId = colorToStyle[colorId]

							styles[styleId].color.name = colorName

						## images
						matches = @resource.match /pImgs\[(\d+)\]\['([^']*)'\]\['([^']*)'\] = (?:'([^']*)'|\{ filename: '([^']*)', width: '\d*', height: '\d*' \};)/g

						for match in matches
							m = match.match /pImgs\[(\d+)\]\['([^']*)'\]\['([^']*)'\] = (?:'([^']*)'|\{ filename: '([^']*)', width: '\d*', height: '\d*' \};)/
							# console.log m
							
							style = m[1]
							type = m[2]
							id = m[3]
							url = m[4] ? m[5]

							styles[style].images[id] ?= {}
							styles[style].images[id][type] = url

						value.styles = styles

					# # dimensions
					# if switches.dimensions
					# 	dimensions = {}
					# 	pattern = /<div id="dimension-([^"]*)" class="dimension">\s*<label class="([^"]*)">\s*([^:]*):/
					# 	matches = @resource.match new RegExp pattern.source, 'g'
					# 	for match in matches
					# 		[__,name,id,label] = match.match pattern
							
					# 		dimensions[name] = 
					# 			name:name
					# 			label:label

					# 		# single value
					# 		m = @resource.match new RegExp "<input type=\"hidden\" id=\"#{id}\" value=\"(\\d+)\" name=\"dimensionValues\" />\\s*<p class=\"note\">([^<]*)<\\/p>"
					# 		if m
					# 			[__,valueId,valueLabel] = m
					# 			dimensions[name].value =
					# 					id:valueId
					# 					label:valueLabel

					# 		# multi value
					# 		values = []
					# 		m = @resource.match new RegExp "<select id=\"#{id}\" class=\"btn secondary\" name=\"dimensionValues\">([\\S\\s]*?)</select>"
					# 		if m
					# 			optionMatches = matchAll m[1], /<option value="(\d*)">([^<]*)/
					# 			dimensions[name].values = _.map optionMatches, (i) -> id:i[1], label:i[2]

					# 	value.dimensions = dimensions

					# brand
					# if switches.brand
					# 	[__,pageUrl, logoUrl, name] = @resource.match /<h2 id="bLogo" class="brand">\s*<a href="([^"]*)" class="to-brand">\s*<img src="([^"]*)" alt="([^"]*)/
					# 	value.brand =
					# 		pageUrl:"http://www.zappos.com#{pageUrl}"
					# 		logoUrl:logoUrl
					# 		name:name


					# # description
					# if switches.description
					# 	matches = @resource.match /<span class="description"><ul(?: class="product-description")?>([\S\s]*?)<\/ul><\/span>/
					# 	description = matches[1]
					# 	# video description
					# 	matches = description.match /<li class="video">(.*?)<\/li>/
					# 	if matches
					# 		description = description.replace matches[0], ''

					# 	# measurements
					# 	matches = description.match /<li class="measurements">([\S\s]*?)\s*<\/ul>\s*<\/li>/
					# 	if matches
					# 		description = description.replace matches[0], ''

					# 		measurementMatches = matchAll matches[1], /<li>([^:]*): ([^<]*)<\/li>/
					# 		measurements = {}
					# 		for match in measurementMatches
					# 			measurements[match[1]] = match[2]
					# 		value.measurements = measurements


					# 		# measurement sample
					# 		matches = description.match /<li>Product measurements were taken using size ([^.]*)\. Please note that measurements may vary by size\.<\/li>/
					# 		if matches
					# 			description = description.replace matches[0], ''
					# 			value.measurementsSample = matches[1].split(', ')

					# 	matches = matchAll description, /<li>(.*?)<\/li>/m
					# 	descriptionItems = []
					# 	for match in matches
					# 		unless match[1] == '<a href="/c/measurements" target="_blank">View This Model\'s Measurements</a>'
					# 			descriptionItems.push match[1]

					# 	value.description = descriptionItems

					# 	# materials
					# 	if switches.materials
					# 		materialSample = 'polyester|cotton|polyamide|elastane|nylon|spandex|rayon|Lycra&reg;|spandex|viscose|recycled|polyester|linen|Tactel&reg;|nylon|acrylic|down|feather|polyurethane|cashmere|corduroy|denim|angora|wool|satin|taffeta|leather|twill|acetate|lycra|lyocell|tweed|canvas|ripstop|sheepskin|silk|velvet|chiffon|jersey|suede|velour|vinyl|tricot|fleece|modal|microfiber|mesh'
					# 		highest = 0
					# 		highestIndex = -1
					# 		for item, i in descriptionItems
					# 			if item.indexOf('%') != -1
					# 				matches = item.match materialSample, 'g'
					# 				if matches
					# 					if matches.length > highest
					# 						highestIndex = i
					# 						highest = matches.index

					# 		if highestIndex != -1
					# 			value.materials = descriptionItems[highestIndex]

					# # video description
					# if switches.videoDescription
					# 		matches = @resource.match /<source src="([^"]*)">/
					# 		if matches
					# 			value.videoDescription = matches[1]

					# # type
					# if switches.type
					# 	matches = @resource.match /var productTypeValue = '([^']*)';/
					# 	if matches
					# 		value.type = matches[1]
						
					
					# # gender
					# if switches.gender
					# 	matches = @resource.match /var productGender = "([^"]*)";/
					# 	if matches
					# 		value.gender = matches[1]

					# category
					# if switches.category
					# 	matches = @resource.match /category = "([^"]*)";/
					# 	if matches
					# 		value.category = matches[1]

					# # sub category
					# if switches.subCategory
					# 	matches = @resource.match /subCategory = "([^"]*)";/
					# 	if matches
					# 		value.subCategory = matches[1]


					@value value




