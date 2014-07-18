define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore', 'util'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _, util) ->

	class NordstromProductScraper extends ProductScraper
		parseSid: (sid) ->
			[id, color] = sid.split '-'
			id:id, color:color

		resources:
			productPage:
				url: -> 
					url = "http://shop.nordstrom.com/s/#{@productSid.id}"
					if @productSid.color
						url += "?fashionColor=#{@productSid.color}"
					url

			reviewData:
				url: -> "http://nordstrom.ugc.bazaarvoice.com/4094redes/#{@productSid.id}/reviews.djs?format=embeddedhtml"

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

					match = /window.PageParameters=(\{[\S\s]*?\});/.exec(@resource)[1]

					colorMap = {}
					for color in more.colors
						colorMap[color.id] = color.name

					matches = _.unique @matchAll match, /"colorId":"([^"]*)","thumbnail":"([^"]*)"/, 0
					colorImages = {}
					for match in matches
						match = match.match /"colorId":"([^"]*)","thumbnail":"([^"]*)"/
						if colorMap[match[1]]
							color = util.ucfirst colorMap[match[1]]
							colorImages[color] = match[2]

					more.colorImages = colorImages

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
					