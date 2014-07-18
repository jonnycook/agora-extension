define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class JCrewProductScraper extends ProductScraper
		version: 2
		resources:
			productPage:
				# url: -> "https://www.jcrew.com/womens_category/sweaters/-/PRDOVR~#{@productSid}/.jsp"
				url: -> "https://www.jcrew.com/browse/single_product_detail.jsp?prd_id=#{@productSid}"


			productDetails:
				url: -> "https://www.jcrew.com/browse2/ajax/product_details_ajax.jsp?prodCode=#{@productSid}&color_name="

			reviewData:
				url: -> "https://jcrew.ugc.bazaarvoice.com/1706-en_us/#{@productSid}/reviews.djs?format=embeddedhtml"

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
						@getResource 'productDetails', (resource) ->
							colorMappingsMatch = @matchAll resource, /"color":"([^"]*)","fullydomqty":false,"colordisplayname":"([^"]*)"/

							colorMappings = {}
							for match in colorMappingsMatch
								colorMappings[match[1]] = match[2]
							more = {}

							match = /<section id="color1" class="color-row last-row">([\S\s]*?)<\/section>/.exec(resource)[1]

							matches = @matchAll match, /<a id="([^"]*)">\s*<img data-imgurl="([^"]*)" src="([^"]*)" class="product-detail-images" data-productcode="[^"]*" data-index="" \/>/

							colorImages = {}
							colors = []
							for match in matches
								colorImages[colorMappings[match[1]]] = match[2]
								colors.push id:match[1], swatch:match[3], name:colorMappings[match[1]]


							match = /<section id="sizes" class="sizes">([\S\s]*?)<\/section>/.exec(resource)[1]
							sizes = @matchAll match, /<span>([^<]*)<\/span>/, 1

							more.colors = colors
							more.colorImages = colorImages
							more.sizes = sizes



							more.color = /<span class="color-name">\s*(.*?)\s*<\/span>/.exec(resource)?[1]

							@value more
							@done true
						null

					@value more

			rating: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/NoReviewText\\">There are no reviews for this product/, 0, -> 0]
					[/alt=\\"(.*?) \/ 5\\"/, 1]
				]

			ratingCount: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/NoReviewText\\">There are no reviews for this product/, 0, -> 0]
					[/BVRRBuyAgainPrefix\\">Based on (\d*)/, 1]
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
					