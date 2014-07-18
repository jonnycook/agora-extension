define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper'
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class WetSealProductScraper extends ProductScraper
		parseSid: (sid) ->
			[sku, color, size] = sid.split '_'
			sku:sku
			color:color
			size:size

		resources:
			productPage:
				url: -> 
					url = "http://www.wetseal.com/#{@productSid.sku}.html?"
					if @productSid.color
						url += "dwvar_#{@productSid.sku}_color=#{@productSid.color}&"
					if @productSid.size
						url += "dwvar_#{@productSid.sku}_size=#{@productSid.size}"
					url

			variationPage: url: -> "http://www.wetseal.com/on/demandware.store/Sites-wetseal-Site/default/Product-Variation?pid=#{@productSid.sku}&dwvar_#{@productSid.sku}_color=#{@productSid.color}&format=ajax"

			reviewData:	url: -> "http://wetseal.ugc.bazaarvoice.com/9031-en_us/#{@productSid.sku}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image', (value) -> value.replace '&amp;', '&'

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					images = {}
					more.images = images

					matches = /<h2>Alternate Views<\/h2>\s*<ul>([\S\s]*?)<\/ul>/.exec @resource
					images[@productSid.color] = @matchAll @resource, /lgimg='\{"url":"([^"]*)/, 1

					for color in more.colors
						continue if color.id == ''
						do (color) =>
							@execBlock ->
								@get "http://www.wetseal.com/on/demandware.store/Sites-wetseal-Site/default/Product-Variation?pid=#{@productSid.sku}&dwvar_#{@productSid.sku}_color=#{color.id}&format=ajax", (response) ->
									matches = /<h2>Alternate Views<\/h2>\s*<ul>([\S\s]*?)<\/ul>/.exec response
									images[color.id] = @matchAll matches[1], /lgimg='\{"url":"([^"]*)/, 1
									@value more
									@done true
								null

					@value more

			rating: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/>Be the first to<\\\/span>/, 0, -> 0]
					[/<span class=\\"BVRRNumber BVRRRatingRangeNumber\\">(\d*)<\\\/span>/, 1]
				]

			ratingCount: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/>Be the first to<\\\/span>/, 0, -> 0]
					[/<span class=\\"BVRRCount BVRRNonZeroCount\\">Read <span class=\\"BVRRNumber\\">([^<]*)/, 1]
				]

			reviews:
				resource: 'reviewData'
				scraper: ScriptedResourceScraper ->
					reviewsText = @resource.match(/BVRRDisplayContentBodyID([\S\s]*)/)?[1]

					if reviewsText
						titleMatches = @matchAll reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1

						contentMatches = @matchAll reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1

						ratingsMatches = @matchAll reviewsText, /alt=\\"(\d*) out of 5\\"/, 1

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
