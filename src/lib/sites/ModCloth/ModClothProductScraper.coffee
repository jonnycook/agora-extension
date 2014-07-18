define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class ModClothProductScraper extends ProductScraper
		parseSid: (sid) ->
			[sku, name] = sid.split ':'
			sku:sku, name:name

		resources:
			mainProductPage:
				url: -> "http://www.modcloth.com/shop/-/#{@productSid.name}"
			productPage:
				url: -> "http://www.modcloth.com/storefront/products/#{@productSid.sku}/product_quickview"
			reviewsPage:
				url: -> "http://www.modcloth.com/storefront/reviews/view_more/#{@productSid.sku}?place=0"

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

			ratingCount:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'ratingCount'

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'
					@execBlock ->
						@getResource 'mainProductPage', (resource) ->
							images = @declarativeScraper 'images', 'images', resource
							more.images = images
							@value more
							@done true
						null

					@value more



			rating:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					rating = @resource.match(/<li class='current-rating' style='width:(\d*)px'>/)?[1]
					if rating?
						@value rating/20

			reviews:
				resource: 'reviewsPage'
				scraper: ScriptedResourceScraper ->
					html = JSON.parse(@resource).html

					reviewMatches = @matchAll html, /<div class="review_wrapper user-review">([\S\s]*?<div class="review_datetime">[\S\s]*?<)/, 1

					reviews = for reviewMatch in reviewMatches
						comment = reviewMatch.match(/<div class="review_comment">\s*([\S\s]*?)\s*<\/div>/)[1]	
						author = reviewMatch.match(/<div class="review_info_name">\s*([\S\s]*?)\s*</)[1]
						date = reviewMatch.match(/<div class="review_datetime">\s*([\S\s]*?)\s*</)[1]
						rating = reviewMatch.match(/<div class='is-(\d*)-star/)[1]
						
						comment:comment
						author:author
						date:date
						rating:rating

					@value reviews

