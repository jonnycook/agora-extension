define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class CostcoProductScraper extends ProductScraper
		@testProducts: [
			'11625662'
		]
		resources:
			productPage:
				url: -> "http://www.costco.com/-.product.#{@productSid}.html"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper /<title>([^<]*)/, 1

			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					matches = @resource.match /<input type="hidden" name="price"[\s]*value="\$([^"]*)/
					# console.debug 'asdf'
					if matches[1] != '0.00'
						# console.debug 'asdf'
						@value matches[1]
					else
						multiprice = @resource.match /<head>([\S\s]*?)<\/head>/
						multipriceMatches = multiprice[1].match /"price" : process\("([^"]+)/g
						prices = []
						for match in multipriceMatches
							price = match.match /"price" : process\("([^"]+)/
							prices.push parseFloat atob price[1]
						max = Math.max.apply(Math,prices)
						min = Math.min.apply(Math,prices)
						@value min + " - $" + max

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<img id="Image1" src="([^"]*)/), 1

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true
						features: true
						details: true  #done
						specifications: true #done
						shipping: true #done
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done

					value = {}

					if switches.rating
						matches = @resource.match /<meta itemprop="ratingValue" content="([^"]+)/
						if matches
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /<meta itemprop="reviewCount" content="([^"]+)/
						if matches
							value.reviewCount = matches[1]


					if switches.features
						matches = @resource.match /<div class="features">([\S\s]*?)<\/div>/
						value.features = matches[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

					if switches.details
						matches = @resource.match /<div id="product-tab1"([\S\s]*?)<div id="product-tab2"/
						value.details = "<div id=\"product-tab1\"" + matches[1]

					if switches.images
						images = []
						xmtUrl = @resource.match(/src="(http:\/\/images\.costco\.com\/image\/media\/[\S\s]*?\.xmt)"/)[1]
						@execBlock ->
							@get xmtUrl, (response)->
								matches = response.match /image: '([^']*)/g
								for match in matches
									num = match.match /image: '([^']*)/
									images.push "http://images.costco.com/image/media/350-" + num[1] + ".jpg"
								@done true
								@value value
							null
						value.images = images

					if switches.specifications
						specifications = {}
						matches = @resource.match /<div id="product-tab2"([\S\s]*?)<div id="product-tab3"/
						specMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						for match in specMatches
							title = match.match(/<span class="bold">([\S\s]*?):<\/span>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
							content = match.match(/<\/span>([\S\s]*?)<\/li>/)[1].replace(/^<br\/>+|<br\/>+$/gm,'').replace(/\n\r/g, " ").replace(/^\s+|\s+$/gm,'')
							specifications[title] = content
						value.specifications = specifications

					if switches.shipping
						matches = @resource.match /<div id="product-tab3"([\S\s]*?)<div id="product-tab4"/
						value.shipping = "<div id=\"product-tab3\"" + matches[1]


					if switches.originalPrice
						matches = @resource.match /<div class="online-price">([\S\s]*?)<\/div>/
						if matches
							price = matches[1].match /<span class="currency">\$([\S\s]*?)<\/span>/
							value.originalPrice = price[1]

					@value value