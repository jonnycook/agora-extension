define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class SixPMProductScraper extends ProductScraper
		@productSid: (background, url, cb) ->
			background.httpRequest url,
				cb: (response) ->
					matches = /<span id="sku" class="sku id">SKU: #(\d*)<\/span>/.exec response
					
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


		parseSid: (sid) ->
			[id, color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: -> "http://www.6pm.com/viewProduct.do?productId=#{@productSid.id}&colorId=#{@productSid.color}"

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
					value = more
					styles = {}

					colorToStyle = {}

					currentColorId = @resource.match(/<option value="(\d*)" selected="selected">/)?[1]
					if !currentColorId
						currentColorId = @resource.match(/<input type="hidden" id="color" value="(\d*)" name="colorId/)[1]

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


					@value more
