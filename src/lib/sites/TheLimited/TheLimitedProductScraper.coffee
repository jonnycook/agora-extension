define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class TheLimitedProductScraper extends ProductScraper
		parseSid: (sid) -> 
			[sku, color, size] = sid.split '-'
			sku:sku, color:color, size:size

		resources:
			productPage:
				url: -> "http://www.thelimited.com/product/-/#{@productSid.sku}.html?dwvar_#{@productSid.sku}_colorCode=#{@productSid.color}&dwvar_#{@productSid.sku}_size=#{@productSid.size ? ''}"

			reviewData:
				url: -> "http://thelimited.ugc.bazaarvoice.com/9023/#{@productSid.sku}/reviews.djs?format=embeddedhtml"

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
					@value @resource.match("\\\"([^\\\"]*?/medium/\\d*_#{@productSid.color}_1\\.jpg)")[1]


			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					data = /app.ProductCache = new app\.ProductController\(([\S\s]*?)\);/.exec(@resource)[1]

					colorsMatch = data.match(/\{"id" : "colorCode", "name" : "Color",([\S\s]*?)\{"id" : "size", "name" : "Size",/)[1]
					colors = @matchAll colorsMatch, /\{"val" :"([^"]*)"([\S\s]*?\]\s*\}\s*\})/
					images = {}
					for color in colors
						imgs = []
						data = color[2].match(/"images"\s*:\s*(\{[\S\s]*?\})\s*\}/)[1]
						obj = JSON.parse data	
						
						images[color[1]] =
							swatch:obj.swatch.url
							swatch2:obj.swatch2.url
							small:_.map obj.small, (i) -> i.url
							medium:_.map obj.medium, (i) -> i.url
							large:_.map obj.large, (i) -> i.url
							xlarge:_.map obj.xlarge, (i) -> i.url

					more.images = images

					for color in more.colors
						if parseInt(color.id) == parseInt(@productSid.color)
							more.color = color.name
	
					@value more

			rating:
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/BVRRRatingSummaryLinkWriteFirstID/, 0, -> 0]
					[/alt=\\"([\d.]*) out of 5\\"/, 1]
				]

			ratingCount: 
				resource: 'reviewData'
				scraper: PatternResourceScraper [
					[/BVRRRatingSummaryLinkWriteFirstID/, 0, -> 0]
					[/<span class=\\"BVRRNumber\\">(\d+)/, 1]
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
					
