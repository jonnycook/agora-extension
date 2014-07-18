define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) ->

	class LLBeanProductScraper extends ProductScraper
		parseSid: (sid) ->
			[id,color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: ->
					url = "http://www.llbean.com/llb/shop/#{@productSid.id}"
					if @productSid.color
						url += "?attrValue_0=#{@productSid.color}"
					url

			reviewData:
				requires: 'productPage'
				url: (resource) ->
					reviewId = resource.match(/"reviewId" : "([^"]*)"/)[1]
					"http://llbean.ugc.bazaarvoice.com/1138jspdp-en_us/#{reviewId}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					prices = @matchAll @resource, /(?:toOrderItemPrice|toOrderItemSalePrice)[\S\s]*?\$([\d.]*)/, 1
					if prices.length > 1
						min = Math.min.apply Math, prices
						max = Math.max.apply Math, prices
						@value "#{min} - $#{max}"
					else
						@value prices[0]

			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image'

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					matches = @matchAll @resource, /"attributeArrays"[\S\s]*?"attributeDescriptions": \[[^\]]*\]/, 0

					properties = {}
					for match in matches
						obj = JSON.parse "{#{match}}"
						
						for values,i in obj.attributeArrays
							name = obj.attributeDescriptions[i]
							properties[name] ?= []
							properties[name] = properties[name].concat values
							
					for name,values of properties
						properties[name] = _.unique values

					if properties.Size
						more.sizes = properties.Size
						delete properties.Size

					if properties['Color/Style']
						more.colors = properties['Color/Style']
						delete properties['Color/Style']

					more.properties = properties


					colorMatches = @matchAll @resource, /"colorNames":(\[[^\]]*\]),/, 1
					imageMatches = @matchAll @resource, /"mainImagesZoomPath":(\[[^\]]*\]),/, 1
					images = {}
					for colorMatch,i in colorMatches
						colors = JSON.parse colorMatch
						imgs = JSON.parse imageMatches[i]
						for color,i in colors
							images[color] = imgs[i]
					more.colorImages = images
		

					images = []
					matches = @matchAll @resource, /name="([^"]*)"\s*src="([^"]*)"/
					for match in matches
						if match[1] != 'main'
							images.push "http:#{match[2]}"
					more.images = images

					@value more

			rating: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/Write the first review<\\\/a>/, 0, -> 0]
					[/alt=\\"(.*?) \/ 5\\"/, 1]
				]

			ratingCount: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/Write the first review<\\\/a>/, 0, -> 0]
					[/<span class=\\"BVRRNumber\\">(\d+)/, 1]
				]

			reviews:
				resource: 'reviewData'
				scraper: ScriptedResourceScraper ->
					reviewsText = @resource.match(/BVRRDisplayContentBodyID([\S\s]*)/)?[1]

					if reviewsText
						titleMatches = @matchAll reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1

						contentMatches = @matchAll reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1

						ratingsMatches = @matchAll reviewsText, /title=\\"(\d+) \/ 5\\"/, 1

						authorMatches = @matchAll reviewsText, /<span class=\\"BVRRNickname\\">([^<]*?) <\\\/span>/, 1

						dateMatches = @matchAll reviewsText, /<span class=\\"BVRRValue BVRRReviewDate\\">([^<]*)<\\\/span>/, 1

						reviews = for titleMatch,i in titleMatches
							title:titleMatch
							content:contentMatches[i]
							rating:ratingsMatches[i]
							author:authorMatches[i]
							date:dateMatches[i]

						@value reviews
					else
						@value []
					