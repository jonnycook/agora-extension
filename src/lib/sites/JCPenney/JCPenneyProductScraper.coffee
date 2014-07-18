define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class JCPenneyProductScraper extends ProductScraper
		@testProducts: [
			'204617362'
		]

		parseSid: (sid) ->
			[id, color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: ->
					url = "http://www.jcpenney.com/prod.jump?ppId=#{@productSid.id}"
					if @productSid.color
						url += "&selectedSKUId=#{@productSid.color}"
					url





		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<span class='gallery_page_price[^>]+([\s\S]*?)<\/span>/), 1]
					[new RegExp(/jcpPRODUCTPRESENTATIONSjcp = 'pp5003810419@\$(\S*)@1';/), 1]
					[new RegExp(/<span class='[^']*' itemprop="price">\s*<a href="[^"]*" class="[^"]*" style='[^']*'>\s*\$(\S*)\s*sale/), 1]
					[new RegExp(/<span class='[^']*' style="[^"]*" itemprop="price">\s*\$(\S*)\s*sale/), 1]
					[new RegExp(/<span class='gallery_page_price flt_wdt comparisonPrice'[^>]*>\s*\$([\s\S]*?)\s*sale\s*<\/span>/), 1, (value) -> value.split(/\s+/).join ' ']
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
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done
						promo: true #done
						options: true #done
						shipping: false


					value = {}

					if switches.overview
						overview = []
						matches = @resource.match(/<div id="longCopyCont"([\S\s]*?)<\/div>[\S\s]*?<\/div>/)[1] + @resource.match(/<div id="longCopyCont"[\S\s]*?<\/div>([\S\s]*?)<\/div>/)[1]

						overviewMatches = matches.match /<p([\S\s]*?)<\/p>/g
						for match in overviewMatches
							text = match.match /<p[^>]*>([\S\s]*?)<\/p>/
							overview.push text[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

						lists = {}
						ulMatches = matches.match /<ul([\S\s]*?)<\/ul>/g
						if ulMatches
							for ulMatch in ulMatches
								liMatches = ulMatch.match /<li([\S\s]*?)<\/li>/g
								for match in liMatches
									col = match.match /(:)/
									if col
										title = match.match(/<li>([^:]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
										content = match.match(/:([^<]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")							
										lists[title] = content
									else
										title = match.match(/<li>([^<]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
										lists[title] = null									
							overview.push lists
						value.overview = overview



					if switches.options
						options = []
						matches = @resource.match /<div class="sku_detail">([\S\s]*?)<\/fieldset>/

						sizeMatches = matches[1].match /<li id="size"([\S\s]*?)<\/li>/g
						if sizeMatches
							sizes = {}
							for match in sizeMatches
								code = match.match(/<a id='([^']+)/)[1]
								size = match.match(/<a[^>]+>([\S\s]*?)<\/a>/)[1]
								sizes[size] = code
							options.push sizes

						colorMatches = matches[1].match /<a class="swatch"([\S\s]*?)<\/a>/g
						if colorMatches
							colors = {}
							for match in colorMatches
								code = {}
								name = match.match(/alt="([^"]*)/)[1]
								code["image"] = "http://s7d9.scene7.com/is/image/JCPenney/" + match.match(/onmouseover="updateRender\('([^']*)/)[1] + "?wid=500&hei=500&fmt=jpg&op_usm=.4,.8,0,0&resmode=sharp2" 
								code["swatch"] = match.match(/src="([^"]*)/)[1]
								code["number"] = match.match(/<a class="swatch" href='([^']*)/)[1]
								colors[name] = code

							options.push colors						


						value.options = options





					if switches.rating
						rating = []
						ratingID = @resource.match(/reviewId:"([^"]*)/)[1]
						ratingURL = "http://jcpenney.ugc.bazaarvoice.com/1573-en_us/" + ratingID + "/reviews.djs?format=embeddedhtml"
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
						ratingID = @resource.match(/reviewId:"([^"]*)/)[1]
						ratingURL = "http://jcpenney.ugc.bazaarvoice.com/1573-en_us/" + ratingID + "/reviews.djs?format=embeddedhtml"
						@execBlock ->
							@get ratingURL, (response)->
								match = response.match /<span class=\\"BVRRNumber\\">([^<]*)/
								if match
									reviewCount.push match[1]
								@done true
								@value value
							null
						value.reviewCount = reviewCount

					if switches.promo
						matches = @resource.match /<span id="promoDetails">([\S\s]*?)<\/span>/
						if matches
							promo = @resource.match /<span >([\S\s]*?)<\/span>|<span >([\S\s]*?)<\/span>/
							value.promo = promo[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")



					if switches.originalPrice
						matches = @resource.match /var priceType='Sale';/
						if matches
							matches = @resource.match /<span class='pp_page_price([\S\s]*?)<\/span>/
							originalPrice = matches[1].match /\$([\S\s]*?)original/
							value.originalPrice = originalPrice[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

					if switches.images
						images = []
						matches = @resource.match /var imageName = "([^"]*)/
						imageMatches = matches[1].split(',')
						if imageMatches
							for match in imageMatches
								image = "http://s7d9.scene7.com/is/image/JCPenney/" + match + "?wid=500&hei=500&fmt=jpg&op_usm=.4,.8,0,0&resmode=sharp2"
								images.push image
							value.images = images


					@value value
