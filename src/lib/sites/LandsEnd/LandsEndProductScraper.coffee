define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) ->

	class LandsEndProductScraper extends ProductScraper
		version:1
		parseSid: (sid) ->
			[id, style] = sid.split '-'
			id:id, style:style

		@productSid: (background, url, cb, retrievalId) ->
			background.httpRequest url,
				cb: (response) ->
					id = response.match(/<span id="mobileItemNumber_(\d*)">/)?[1]
					if id
						cb "#{id}-#{retrievalId}"
					else
						cb()

		resources:
			productPage:
				url: -> "http://www.landsend.com/pp/StylePage-#{@productSid.style}_AL.html"

			reviewData:
				url: -> "http://landsend.ugc.bazaarvoice.com/2008-en_us/#{@productSid.id}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					regExp = new RegExp "Style(\\d*)\.number = #{@productSid.style}"
					style = regExp.exec(@resource)[1]
					regExp = new RegExp "Style#{style}.longName = \"([^\"]*)\";"
					@value regExp.exec(@resource)[1]
			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					matches = /<span class='pp-was-price'>\$[^<]*<\/span>\s*<span>\s*NOW \$([^<]*)/.exec @resource
					if matches
						@value matches[1]
					else
						matches = /<p id="productPrice_\d*" class="pp-summary-price" >\s*<span>\$([^<]*)<\/span>\s*- \$([^<]*?)\s*<\/p>/.exec @resource
						if matches
							@value "#{matches[1]} - $#{matches[2]}"
						else 
							matches = /<p id="productPrice_\d*" class="pp-summary-price"\s*>\s*\$([\d.]*)/.exec @resource
							if matches
								@value matches[1]




			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image'

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'

					more.sizes = _.unique @matchAll @resource, /<a href="#" id="sizeId_\d*_\d*_([^"]*)/, 1

					colorMatches = @matchAll @resource, /<a id="colorId_\d*_\d*_([^"]*)"[^>]*>\s*<span>([^<]*)/
					colors = {}
					for colorMatch in colorMatches
						colors[colorMatch[1]] = colorMatch[2]

					more.colors = for id,name of colors
						name:name
						id:id

					propertyMatches = @matchAll @resource, /id="featureWrapper_([\S\s]*?)End of pp-sel/, 1

					properties = {}
					for propertyMatch in propertyMatches
						name = propertyMatch.match(/<h3 class="pp-selector-label">\s*([^<]*)/)[1].trim()
						properties[name] ?= []
						valueMatches = @matchAll propertyMatch, /<span class="pp-accessibility-text"><\/span>\s*([\S\s]*?)\s*<\/a>/, 1
						properties[name] = _.unique properties[name].concat(valueMatches)
					

					mainImages = _.unique @matchAll @resource, /<img class="default" src="([^?]*)/, 1
					order = []
					for image,i in mainImages
						order.push image.match(/_([^_]*)_[^_]*$/)[1]
					order = _.unique order

					imageMatches = _.unique @matchAll @resource, /ProductImage\d*\.fileName = "(\d*_[^_]*_[^_]*_([^"]*))"/, 1
					imageMap = {}
					for imageMatch in imageMatches
						[__, id, color] = imageMatch.match(/_([^_]*)_([^_]*)$/)
						imageMap[color] ?= {}
						imageMap[color][id] = imageMatch

					images = {}
					for color in more.colors
						images[color.id] = for imageId in order							
							"http://s7.landsend.com/is/image/LandsEnd/#{imageMap[color.id][imageId]}"

					more.images = images


					more.properties = properties
	

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
					