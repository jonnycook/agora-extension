define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class ToysRUsProductScraper extends ProductScraper
		@testProducts: [
			'13018810'
		]
		resources:
			productPage:
				url: -> "http://www.toysrus.com/product/index.jsp?productId=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<meta property="eb:saleprice" content="([^"]*)/), 1] 
					[new RegExp(/<meta property="eb:price" content="([^"]*)/), 1] 
				]

			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					link = /<input name=enh_0 type=hidden value="([^"]*)/.exec(@resource)[1]
					@value "http://www.toysrus.com" + link



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

						shipping: false


					value = {}

					if switches.description
						description = []
						mainDesc = @resource.match /<h3>Product Description<\/h3>([\S\s]*?)<div/
						if mainDesc
							description.push "<div>" + mainDesc[1]
						# altDescCheck = @resource.match /(http:\/\/content.webcollage.net\/toysrus\/smart-button)/
						# if altDescCheck
						# 	altDescUrl = "http://content.webcollage.net/toysrus/smart-button?ird=true&channel-product-id=#{@productSid}"
						# 	@execBlock ->
						# 		@get altDescUrl, (response)->
						# 			matches = response.match /html: "([\S\s]*?)};/
						# 			if matches
						# 				description.push matches[1].replace(/\}+$/gm,'').replace(/\"+$/gm,'').replace(/\\"+/gm,'"').replace(/\\\/+/gm,'/')
						# 			@done true
						# 			@value value
						# 		null
						value.description = description


					if switches.rating
						matches = @resource.match /var POWERREVIEWS=([\S\s]*?)<\/script>/
						if matches
							matches = matches[1].match /,s:([^,]*)/	
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /var POWERREVIEWS=([\S\s]*?)<\/script>/
						if matches
							matches = matches[1].match /,rc:([^,]*)/
							value.reviewCount = matches[1]


					if switches.originalPrice
						matches = @resource.match /<meta property="eb:price" content="([^"]*)/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = []
						matches = @resource.match /<div class="altImages([\S\s]*?)<div id="leftSide">/
						if matches
							imageMatches = matches[1].match /href="javascript:swapImage\('([^']*)/g
							if imageMatches
								for match in imageMatches
									image = match.match /href="javascript:swapImage\('([^']*)/
									images.push "http://www.toysrus.com" + image[1]
						altImageCheck = @resource.match /(http:\/\/content.webcollage.net\/toysrus\/smart-button)/
						if altImageCheck
							altImageUrl = "http://content.webcollage.net/toysrus/smart-button?ird=true&channel-product-id=#{@productSid}"
							@execBlock ->
								@get altImageUrl, (response)->
									matches = response.match /<div class=\\"wc-gallery-thumb\\"([\S\s]*?)<\\\/div>/g
									if matches
										for match in matches
											image = match.match(/wcobj=\\"([\S\s]*?)\\"/)[1]
											images.push image.replace(/\\"+/gm,'"').replace(/\\\/+/gm,'/')
									# images.push matches
									@done true
									@value value
								null
						if images.length <= 0
							url = "http://www.toysrus.com" + @resource.match(/<input name=enh_0 type=hidden value="([^"]*)/)[1]
							if url.match /([\S\s]*?)enh-z6\.jpg/
								images.push url.match(/([\S\s]*?)enh-z6\.jpg/)[1] + "dt.jpg"
							else
								images.push url.match(/([\S\s]*?)dt\.jpg/)[1] + "dt.jpg"
						value.images = images


					@value value
