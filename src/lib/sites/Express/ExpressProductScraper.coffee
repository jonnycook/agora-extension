define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) ->

	class ExpressProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://www.express.com/catalog/product_detail.jsp?productId=#{@productSid}&categoryId=cat1040005"

			reviewData:
				url: -> "http://express.ugc.bazaarvoice.com/6549/#{@productSid}/reviews.djs?format=embeddedhtml"

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
					@execBlock ->
						@post 'http://www.express.com/catalog/gadgets/color_size_gadget.jsp', productId:@productSid.value, categoryId:'cat1040005', (response) ->
							more.color = response.match(/<span class="selectedColor">([^<]*)/)?[1]

							colors = []
							colorMatches = @matchAll response, /<img class="cat-pro-swatch[^"]*" src="([^"]*)" width="51" height="34" alt="([^"]*)" \/>/
							for colorMatch in colorMatches
								colors.push
									id:colorMatch[1].match(/([^\/]*)_s\?/)[1]
									name:colorMatch[2]
									swatch:"http:#{colorMatch[1]}"

							more.colors = colors

							more.sizes = @matchAll response, /<option class="availableSize" value="([^"]*)/, 1

							images = {}
							more.images = images
							for color in more.colors
								do (color) =>
									@execBlock ->
										@get "http://images.express.com/is/image/expressfashion/#{color.id}?req=set,json", (response) ->
											obj = JSON.parse response.match(/^s7jsonResponse\((.*?),""\);$/)[1]
											images[color.name] = _.map obj.set.item, (i) -> "http://images.express.com/is/image/#{i.i.n}"
											@value more
											@done true
										null
							@value more
							@done()
						null
					@value more


			rating: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/Be the first to<\\\/span>/, 0, -> 0]
					[/BVRRRatingOverall_Rating_Summary_1.*?alt=\\"([.\d]*) out of 5\\"/, 1]
				]

			ratingCount: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/Be the first to<\\\/span>/, 0, -> 0]
					[/Read all <span class=\\"BVRRNumber\\">([\d,]*)<\\\/span> review/, 1]
				]

			reviews:
				resource: 'reviewData'
				scraper: ScriptedResourceScraper ->
					reviewsText = @resource.match(/BVRRDisplayContentBodyID([\S\s]*)/)?[1]

					if reviewsText
						titleMatches = @matchAll reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1

						contentMatches = @matchAll reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1

						ratingsMatches = @matchAll reviewsText, /title=\\"(\d+) out of 5\\"/, 1

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
					