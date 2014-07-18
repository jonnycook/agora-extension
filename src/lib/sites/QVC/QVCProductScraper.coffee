define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class QVCProductScraper extends ProductScraper
		@testProducts: [
			'E249454'
		]
		parseSid: (sid) ->
			[id, color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: ->
					url = "http://www.qvc.com/.product.#{@productSid.id}.html"
					if @productSid.color
						url += "?itemId=#{@productSid.color}"
					url

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<p id="parProductDetailPrice">\$([\S\s]*?)<\/p>/), 1] # has the cents in a span
				]

			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					matches = @resource.match /var arrSizeValues = new Array([\S\s]*?)<\/script>/
					shortId = matches[1].match(new RegExp("#{@productSid.color}:[^:]*:[^:]*:([^:]*)", 'i'))[1].toLowerCase()
					url = "http://images.qvc.com/is/image/" + @resource.match(/<meta property="og:image" content="http:\/\/images.qvc.com\/is\/image\/([^\.]*)/)[1] + "_" + shortId + ".102?$uslarge$"
					@value url

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						description: false #done
						rating: false #done
						ratingCount: false #done
						originalPrice: false #done
						colors: true
						shipping: false


					value = {}

					if switches.colors
						matches = @resource.match /var arrSizeValues = new Array([\S\s]*?)<\/script>/
						colorMatches = @matchAll matches[1], /arrSizeValues\[.*?\]\[.*?\]="(.*?)"/, 1
						value.colors = []
						for match in colorMatches
							matches = match.match /^([^:]*):[^:]*:[^:]*:([^:]*):[^:]*:([^:]*)$/
							value.colors.push({
								longId:matches[1],
								shortId:matches[2],
								name:matches[3]
							})

					if switches.description
						matches = @resource.match /<div id="divProductDetailDescriptionAreaDisplay1"([\S\s]*?)<div id="divProductDetailDescriptionAreaDisplay2"/
						value.description = "<div" + matches[1]

					if switches.rating
						matches = @resource.match /var avgRating = '([^']*)/
						if matches
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /var productReviews = '([^']*)/
						if matches
							value.reviewCount = matches[1]


					if switches.originalPrice
						matches = @resource.match /<span class="spanStrike">\$([\S\s]*?)<\/span>/
						if matches
							value.originalPrice = matches[1]
						else
							matches = @resource.match /product_price:\['([^']*)/
							if matches
								value.originalPrice = matches[1]						

					if switches.images
						images = {}


						colorMatches = @resource.match /colorImages\[[^\]]*\] = "([^"]*)/g
						if colorMatches
							colorPics = {}
							for match in colorMatches
								pic = match.match /colorImages\[[^\]]*\] = "([^"]*)/
								id = match.match(new RegExp("#{@productSid.id}_([^\.]*)", 'i'))
								# id = match.match /_([^\.]*)/
								colorPics[id[1]] = pic[1]
							images["colorPics"] = colorPics
						imageMatches = @resource.match /viewImages\[[^\]]*\] = "([^"]*)/g
						if imageMatches
							pics = []
							for match in imageMatches
								pic = match.match /viewImages\[[^\]]*\] = "([^"]*)/
								# id = match.match(new RegExp("#{@productSid.id}\.([^\?]*)", 'i'))
								pics.push pic[1]
							images["pics"] = pics
						value.images = images


					@value value
