define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class KateSpadeProductScraper extends ProductScraper
		version:2
		parseSid: (sid) ->
			[sku, color, size] = sid.split '_'
			sku:sku
			color:color
			size:size

		resources:
			productPage:
				url: -> 
					url = "http://www.katespade.com/-/#{@productSid.sku},en_US,pd.html?"
					if @productSid.color
						url += "dwvar_#{@productSid.sku}_color=#{@productSid.color}&"
					if @productSid.size
						url += "dwvar_#{@productSid.sku}_size=#{@productSid.size}"
					url

			reviewData:
				url: -> "http://katespade.ugc.bazaarvoice.com/5036-en_us/#{@productSid.sku}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					if @productSid.color
						str = "#{@productSid.sku}_#{@productSid.color}"
						@value "http://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/KateSpade/#{str}?op_sharpen=0&resMode=sharp2&wid=467&fmt=jpg"
					else 
						@value @declarativeScraper 'scraper', 'image'

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					images = {}
					more.images = images
					for color in more.colors
						do (color) =>
							@execBlock ->
								@get "https://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/KateSpade/#{@productSid.sku}_#{color.id}_is?req=set,json,UTF-8", (response) ->
									# console.debug response
									obj = JSON.parse response.match(/^s7jsonResponse\((.*?),""\);$/)[1]
									images[color.name] = _.map obj.set.item, (i) -> "https://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/#{i.i.n}"
									@value more
									@done true
								null

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
					