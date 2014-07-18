define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) ->

	class BloomingdalesProductScraper extends ProductScraper
		version:3
		parseSid: (sid) ->
			[id, variant] = sid.split '-'
			id:id, variant:variant

		resources:
			productPage:
				url: ->
					url = "http://www1.bloomingdales.com/shop/product/?ID=#{@productSid.id}"
					if @productSid.variant
						url += "&upc_ID=#{@productSid.variant}"
					url

			reviewData:
				url: -> "http://bloomingdales.ugc.bazaarvoice.com/7130aa/#{@productSid.id}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					color = if @productSid.variant
						regExp = new RegExp("\"upcID\": #{@productSid.variant}, \"inStoreEligible\": [^,]*, \"color\": \"([^\"]*)\"")
						regExp.exec(@resource)[1]
					else
						/BLOOMIES.pdp.primaryColor = "([^"]*)";/.exec(@resource)[1]
					matches = /BLOOMIES.pdp.primaryImages\[\d*\] = (\{[\S\s]*?\})/.exec @resource
					primaryImages = JSON.parse matches[1].replace /'/g, '"'
					@value "http://images.bloomingdales.com/is/image/BLM/products/#{primaryImages[color]}?wid=325&qlt=90,0&layer=comp&op_sharpen=0&resMode=sharp2&op_usm=0.7,1.0,0.5,0&fmt=jpeg"

			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					matches = /BLOOMIES.pdp.primaryImages\[\d*\] = (\{[\S\s]*?\})/.exec @resource
					primaryImages = JSON.parse matches[1].replace /'/g, '"'

					matches = /BLOOMIES.pdp.additionalImages\[\d*\] = (\{[\S\s]*?\})/.exec @resource
					additionalImages = JSON.parse matches[1].replace /'/g, '"'

					images = {}
					for color,image of primaryImages
						images[color] = [image].concat additionalImages[color].split ','

					more.images = images

					if @productSid.variant
						regExp = new RegExp("\"upcID\": #{@productSid.variant}, \"inStoreEligible\": [^,]*, \"color\": \"([^\"]*)\"")
						more.color = regExp.exec(@resource)[1]
					else
						more.color = /BLOOMIES.pdp.primaryColor = "([^"]*)";/.exec(@resource)[1]

					@value more

			rating: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/write a review<\\\/a>/, 0, -> 0]
					[/alt=\\"(.*?) \/ 5\\"/, 1]
				]

			ratingCount: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/write a review<\\\/a>/, 0, -> 0]
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
					