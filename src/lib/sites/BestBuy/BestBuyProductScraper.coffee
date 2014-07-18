define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, _) ->
	class BestBuyProductScraper extends ProductScraper

		parseSid: (sid) ->
			[sku, id] = sid.split '-'
			sku:sku, id:id

		resources:
			productPage:
				url: ->
					"http://www.bestbuy.com/site/asdf/#{@productSid.sku}.p?id=#{@productSid.id}&skuId=#{@productSid.sku}"

			specificationsTab:
				url: -> 
					skuId = @productSid.split('-')[1]
					"http://www.bestbuy.com/site/asdf/#{@productSid.sku}.p;template=_specificationsTab"

		properties:

			pageType:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					type = @resource.match /<div class="[^"]*bbtabs[^"]*">([\S\s]*?)<\/div>/

			title:
				resource: 'productPage'
				scraper: PatternResourceScraper /<div id="sku-title" itemprop="name">\s*<h1>([^<]*)<\/h1>/, 1

			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					
					@value @resource.match(/<div class="item-price"><span class="denominator">[\S\s]*?<\/span>([^<]*)<\/div>/)?[1] ? false


			
			image:
				resource: 'productPage'
				scraper: PatternResourceScraper /<meta property="og:image" content="([^"]*)/, 1

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						description: true #done
						specifications: true #done
						images: true #done
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done
						features: true #done
						model: true #done
						shipping: true #done
						included: true #done

					value = {}

					if switches.description
						matches = @resource.match /<div id="long-description" itemprop="description">([\S\s]*?)<\/div>/
						if matches
							value.description = matches[1]

					if switches.included
						included = []
						matches = @resource.match /<div id="included-items">([\S\s]*?)<\/div>/
						if matches
							includeMatches = matches[1].match /<li>([\S\s]*?)<\/li>/g
							for match in includeMatches
								include = match.match /<li>([\S\s]*?)<\/li>/
								included.push include[1]
							value.included = included

					if switches.shipping
						if matches = @resource.match /<span class="free-shipping-sub-message">([\S\s]*?)<\/span>/
							if (matches[1] == "on orders $25 and up")
								value.shipping = "25andup"
							else
								value.shipping = "other"
						else
							value.shipping = "free"

					if switches.model
						matches = @resource.match /<span id="model-value" itemprop="model">([\S\s]*?)<\/span>/
						if matches
							value.model = matches[1]

					if switches.features
						features = {}
						matches = @resource.match /<div id="features">([\S\s]*?)<div id="carousel-wrap"/
						if matches
							featureMatches = matches[1].match /<div class="feature">([\S\s]*?)<\/div>/g
							for match in featureMatches
								if match.match(/<h4>([\S\s]*?)<\/h4>/)
									title = match.match(/<h4>([\S\s]*?)<\/h4>/)[1]
									desc = match.match(/<p>([\S\s]*?)<\/p>/)[1]
									features[title] = desc
							value.features = features



					if switches.originalPrice
						matches = @resource.match /<div class="regular-price">Regular Price[\S\s]*?\$([\S\s]*?)<\/div>/
						if matches
							value.originalPrice = matches[1]




					if switches.rating
						matches = @resource.match /<span class="average-score" itemprop="ratingValue">([\S\s]*?)<\/span>/
						if matches
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /<a href="#" class="tab-link" data-tab-link="reviews">\(([\S\s]*?) customer review/
						if matches
							value.reviewCount = matches[1]


					if switches.images
						images = {}
						matches = @resource.match /data-gallery-images=[\s]*"([^"]*)/
						if matches
							imageMatches = matches[1].match /\{([^\}]*)\}/g
							if imageMatches
								for match in imageMatches
									check = match.match /&quot;altText&quot;:&quot;([\S\s]*?)&quot;,/
									if check
										altText = match.match(/&quot;altText&quot;:&quot;([\S\s]*?)&quot;,/)[1]
										height = match.match /&quot;height&quot;:([\S\s]*?),/
										width = match.match /&quot;width&quot;:([\S\s]*?),/
										url = match.match /&quot;path&quot;:&quot;([\S\s]*?)&quot;,/
										url = "http://pisces.bbystatic.com/image2/#{url[1]};canvasHeight=#{height[1]};canvasWidth=#{width[1]}"
										images[altText] = url
								if !check
									images["main"] = @resource.match(/<meta property="og:image" content="([^"]*)/)[1]	
								value.images = images

					if switches.specifications
						specifications = {}
						@execBlock ->
							@getResource 'specificationsTab', (resource) ->
								matches = resource.match /<tbody>([\S\s]*?)<\/tbody>/
								specMatches = matches[1].match /<tr>([\S\s]*?)<\/tr>/g
								for match in specMatches
									name = match.match(/<th[^>]*>([\S\s]*?)<\/th>/)[1]
									details = match.match(/<td>([\S\s]*?)<\/td>/)[1]
									desc = match.match(/<td>([\S\s]*?)<\/td>/g)[1] #finds the second td tags
									desc = desc.match(/<td>([\S\s]*?)<\/td>/)[1] #clips out the td tags
									specifications[name] = details:details, desc:desc
								value.specifications = specifications
								@value value
								@done true
							null
					@value value
