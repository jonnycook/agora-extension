define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore', 'ext/AmazonProductScraper'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, DeclarativeResourceScraper, _, AmazonProductScraperExt) ->

	class AmazonProductScraper extends ProductScraper
		@productSid: (url, cb) ->

		@testProducts: [
			'B00C66C950'
			'B00EIRFYS4'
			'B00GK9HH4C'
		]

		@testing:
			skipTest: ['more.reviews']

		version: 5
	
		resources:
			offerListing: #new ResourceFetcher
				url: ->	"http://www.amazon.com/gp/offer-listing/#{@productSid}/ref=olp_sort_p?ie=UTF8&shipPromoFilter=0&sort=price&me=&seller=&condition=new"
				
			offerListingPricePlusShipping:
				url: -> "http://www.amazon.com/gp/offer-listing/#{@productSid}/ref=olp_sort_p?ie=UTF8&shipPromoFilter=0&sort=sip&me=&seller=&condition=new"
				
			productPage:
				url: -> "http://www.amazon.com/gp/product/#{@productSid}/?psc=1"

		properties:
			rating: 
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'rating'

			ratingCount: 
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'ratingCount'

			title: #new PropertyScraper
				resource: 'offerListing'
				scraper: ScriptedResourceScraper ->
					@try
						1: ->
							matches = @resource.match /<span id="btAsinTitle">([^<]*)<\/span>/
							if matches
								@value matches[1]
								true
							else
								false
						2: ->
							matches = @resource.match /<h1 class="producttitle\s*">\s*([\s\S]*?)\s*?<\/h1>/
							if matches
								@value matches[1]
								true
							else
								false
						3: ->
							matches = @resource.match /<h1 class='a-spacing-none'>\s*([^<]*?)<\h1/
							if matches
								@value matches[1].trim().replace /\s+/g, ' '
								true
							else
								false
						4: ->
							matches = @resource.match /New offers for\s*<\/span>\s*<\/div>\s*(.*?)<\/h1>/
							if matches
								@value matches[1].trim().replace /\s+/g, ' '
								true
							else
								false
			
			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					@try
						buyNewPrice: ->
							matches = @resource.match /<span class="bb_price">\s*\$([^<])\s*</
							if matches
								@value matches[1]
								true
							else
								false
						priceLarge: ->
							matches = @resource.match /class="priceLarge">\$([^<]*)</
							if matches
								@value matches[1]
								true
							else
								false

						wirelessPriceFromPrice: ->
							#http://www.amazon.com/gp/product/B007UO9HW6/ref=s9_al_gw_g107_ir03?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-4&pf_rd_r=042AEEF23N094ZJ2CK3N&pf_rd_t=101&pf_rd_p=1420280282&pf_rd_i=507846
							matches = @resource.match /id="wirelessPriceFromPrice"[^>]*>\$([^<]*)</
							if matches
								@value matches[1]
								true
							else
								false

						1: ->
							matches = @resource.match '<span class="a-color-price a-size-large">\\$([^<]*)</span>'
							if matches
								@value matches[1]
								true
							else
								false

						2: ->
							matches = @resource.match '<span id="priceblock_ourprice" class="a-size-medium a-color-price">\\$([^<]*)</span>'
							if matches
								@value matches[1]
								true
							else
								false

						3: ->
							matches = @resource.match '<span class="a-size-medium a-color-price offer-price a-text-normal">\\$([^<]*)</span>'
							if matches
								@value matches[1]
								true
							else
								false

						4: ->
							matches = @resource.match '<span id="current-price" style="display: inline">&#36;([^<]*)</span>'
							if matches
								@value matches[1]
								true
							else
								false

						5: ->
							matches = @resource.match /<span id="priceblock_saleprice" class="a-size-medium a-color-price">\$([^<]*)<\/span>/
							if matches
								@value matches[1]
								true
							else
								false

						6: ->
							matches = @resource.safeMatch /<span id="actualPriceValue"><b class="priceLarge">\$([^<]*)<\/b>/
							if matches
								@value matches[1]
								true
							else
								false



			image:
				resource: 'productPage' 
				scraper: ScriptedResourceScraper ->
					@try
						1: ->							
							matches = @resource.match /thumb_0_inner[\S\s]*?(http:\/\/ecx.images-amazon.com\/.*?\.jpg)/
							if matches
								image = matches[1]
								image = image.substr(0, image.length - 5) + '0_.jpg'
								@value image
								true
							else
								false
						2: ->
							matches = @resource.match '<img.*?(http[^"]+)" id="prodImage"'
							if matches
								@value matches[1]
								true
							else
								false
						3: ->
							matches = @resource.match 'id="main-image" src="http([^"]*)"'
							# console.log @resource.value
							if matches
								@value  'http' + matches[1] # the "'http' +" fixes an issue where the image turns into a string of chinese characters when it is passed to the content script
								true
							else
								false
						4: ->
							matches = @resource.match 'src="([^"]+)"\\s*id="original-main-image"'
							if matches
								@value matches[1]
								true
							else
								false

						5: ->
							matches = @resource.match 'var imageHashMain = \\["([^"]*)"'
							if matches
								@value matches[1]
								true
							else
								false

						6: ->
							matches = @resource.match 'src="([^"]+)" id="prodImage"'
							if matches
								image = matches[1]
								image = image.replace /\d+(_\.\w+)^/, '300$1'
								@value image
								true
							else
								false

						7: ->
							matches = @resource.match 'class="imgTagWrapper">\\s*<img src=\'([^\']*)'
							if matches
								image = matches[1]
								@value image
								true
							else
								false

						8: ->
							matches = @resource.match '<img alt="" src="[^"]*" data-old-hires="([^"]+)"'
							if matches
								image = matches[1].replace /^(http:\/\/ecx\.images-amazon\.com\/images\/.\/[^.]*\._)[^_]*(_\.jpg)$/, '$1UX500$2'
								@value image
								true
							else
								false

						9: ->
							matches = @resource.match /data-a-dynamic-image="\{&quot;([^&]*)/
							if matches
								image = matches[1]
								@value image
								true
							else
								false


						10: ->
							matches = @resource.match '<img id="imgBlkFront" src="(http://ecx\.images-amazon\.com/images/I/[^.]*)'
							if matches
								image = matches[1] + '.jpg'
								@value image
								true
							else
								false



						11: ->
							matches = @resource.match /<div id="imgTagWrapperId" class="imgTagWrapper">\s*<img alt="" src="([^"]*)/
							if matches
								image = matches[1] + '.jpg'
								@value image
								true
							else
								false

						12: ->
							matches = @resource.match /<td id="fbt_x_img">\s*<img src="(http:\/\/ecx\.images-amazon\.com\/images\/I\/[^.]*)/
							if matches
								image = matches[1] + '.jpg'
								@value image
								true
							else
								false



			more: 
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# tryMatches = (@resource, patterns...) ->
					# 	for pattern,i in patterns
					# 		match = @resource[if i == patterns.length - 1 then 'safeMatch' else 'match'] pattern[0]
					# 		if match
					# 			return match[pattern[1]]

					switches = 
						images: true
						features: true
						details: true
						description: true
						category: true

					more = {}
					if switches.images
						# chrome

						matches = @resource.match /data\["colorImages"\] = ([^;]*);/
						if matches
							if matches[1] == '{}'
								matches = @resource.match /var data = \{\s*'colorImages': \{ 'initial': ([\S\s]*?)\},\s*'colorToAsin':/
								more.images = initial:JSON.parse matches[1]
								more.currentStyle = 'initial'
							else
								more.images = JSON.parse matches[1]
								more.currentStyle = @resource.safeMatch('data\\["landingAsinColor"\\] = \'([^\']*)\'')[1]
						else
							# node
							matches = @resource.match /var def = colorImages \? colorImages\[data\.defaultColor\] : \[\];\s*colorImages = ([^;]*);/
							if matches
								more.images = JSON.parse matches[1]
								more.currentStyle = @resource.match(/selected_variations\["color_name"\]='([^']*)';/)?[1]


						if !more.currentStyle
							variationsMatch = @resource.match(/<table class="variations"([\S\s]*?)<\/table>/)?[1]
							if variationsMatch
								selectedVarations = @matchAll variationsMatch, /<div id=\S* class="variationSelected">\s*<b class="variationDefault">[^<]*<\/b>\s*<b class="variationLabel">([^<]*)<\/b>/, 1
								more.currentStyle = selectedVarations.join ' '

							# more.currentStyle = @resource.match(/<div id=selected_platform_for_display class="variationSelected">\s*<b class="variationDefault">Platform:\s*<\/b>\s*<b class="variationLabel">([^<]*)/)?[1]



					if switches.features
						matches = @resource.match(/<div id="feature-bullets"[^>]*>([\S\s]*?)<\/div>\s*<\/div>/)?[1]
						if matches
							matches = @matchAll matches, /<li><span[^>]*>([\S\s]*?)<\/span>/
							features = []
							for match in matches
								features.push match[1]
							more.features = features

					if switches.details
						matches = @resource.match(/<div id="detailBullets_feature_div">([\S\s]*?)<\/ul>/)
						if matches
							matches = @matchAll matches[1], /<li><span class="a-list-item">([\S\s]*?)<\/span><\/li>/
							more.details = {}
							# console.log matches

							for match in matches
								# console.log match[1]

								detailMatches = match[1].safeMatch /<span class="a-text-bold">([^:]*):\s*<\/span>\s*<span>([\S\s]*?)<\/span>/
								more.details[detailMatches[1]] = detailMatches[2]

					if switches.description
						more.description = @resource.match(/<div id="productDescription" class="a-section a-spacing-small">\s*([\S\s]*?)\s*<\/div>/)?[1]

					if switches.category
						matches = @resource.match /<h2 class="a-spacing-mini">Look for Similar Items by Category<\/h2>\s*<p>([\S\s]*?)<\/p>/
						if matches
							matches = @matchAll matches[1], /<a class="a-link-normal" href="[^"]*">([^<]*)<\/a>/
							more.category = _.map matches, (o) -> o[1]
					
					AmazonProductScraperExt.more.call @, switches, more

					@value more

			reviews:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					reviews = []
					reviewsUrl = null
					count = 0

					matches = @resource.match /<div id='revMHRL' class='mb30'>([\S\s]*?)<div id="revF" style="margin: 0 0 30px 25px;">/
					if matches
						reviewMatches = @matchAll(matches[1], /<div id="rev-[^-]*-[^>]*>([\S\s]*?)<\/div>  <\/div><\/div>/)

						for [__,reviewMatch] in reviewMatches
							rating = parseInt reviewMatch.match(/<span>(.*?) out of 5 stars<\/span>/)[1]
							time = reviewMatch.match(/<span class="inlineblock txtsmall">([^<]*)/)[1]
							[__,url,title] = reviewMatch.match /<a href="([^"]*)" class="txtlarge gl3 gr4 reviewTitle valignMiddle"><strong>([^<]*)/

							review = reviewMatch.match(/<div class="drkgry">\s*([\S\s]*?)<\/div>/)[1].trim()
							review = review.replace 'display:none', ''

							[__, commentsUrl, commentsCount] = reviewMatch.match /<a href="([^"]*?)" class="noTextDecoration">(?:(\d+) )?Comments?<\/a>/

							[__, helpfulCount, helpfulTotal] = reviewMatch.match(/<div class="gry txtsmall hlp">(\d+) of (\d+) people found the following review helpful<\/div>/) ? []

							amazonVerifiedPurchase = if reviewMatch.match /<span class="orange strong avp">Amazon Verified Purchase<\/span>/ then true else false

							# [__, authorUrl, authorName] = reviewMatch.match /<span class="a-color-secondary">\s*By\s*<\/span>\s*<a href="([^"]*)" class="noTextDecoration">([^<]*)/

							# sometimes not there
							[__, authorUrl, authorName] = reviewMatch.match /<span class="gry">By<\/span>\s*<a href="([^"]*)" class="noTextDecoration">([^<]*)/

							badgeMatches = @matchAll reviewMatch, /<span class='c7yBadge[^']*'>([^<]*)<\/span>/
							badges = []
							for badgeMatch in badgeMatches
								badges.push badgeMatch[1]

							reviews.push rating:rating, url:url, title:title, time:time, review:review, author:{url:"http://www.amazon.com#{authorUrl}", name:authorName, badges:badges}, helpfulCount:helpfulCount, helpfulTotal:helpfulTotal, amazonVerifiedPurchase:amazonVerifiedPurchase, comments:{url:commentsUrl, count:commentsCount ? 0}

						[__,reviewsUrl, count] = @resource.match /<a id="seeAllReviewsUrl" href="([^"]*)" class="txtlarge noTextDecoration">\s*<strong>\s*See all ([\d,]+) customer reviews \(newest first\)/

					else
						matches = @resource.match /<div id="revMHRL" class="a-section">([\S\s]*?)<div id="revF" class="a-section">/
						if matches
							reviewMatches = @matchAll(matches[1], /<div id="rev-[^-]*-[^>]*>([\S\s]*?)Was this review helpful to you?/)
							for [__,reviewMatch] in reviewMatches
								rating = parseInt reviewMatch.match(/title="(.*?) out of 5 stars"/)[1]

								matches = reviewMatch.match(/<span class="a-color-secondary"> on ([^<]*)/)
								time = if matches
									matches[1]
								else 
									reviewMatch.match(/<\/span>\s*on\s*([^<]*)<\/span>/)[1]


								[__,url,title] = reviewMatch.match /<a class="a-link-normal a-text-normal a-color-base" href="([^"]*)"><span class="a-size-base a-text-bold">([^<]*)/

								review = reviewMatch.match(/<div class="a-section">([\S\s]*?)<\/div>/)[1].trim()

								[__, commentsCount, commentsUrl] = reviewMatch.match /<a class="a-link-normal comment-link" title="(\d*)" href="([^"]*)">/

								[__, helpfulCount, helpfulTotal] = reviewMatch.match(/<span class="a-size-small a-color-secondary">(\d*) of (\d*) people found the following review helpful<\/span>/) ? []

								amazonVerifiedPurchase = if reviewMatch.match /<span class="a-size-mini a-color-state a-text-bold">\s*Amazon Verified Purchase\s*<\/span>/ then true else false
								authorUrl = authorName = null

								matches = reviewMatch.match /<span class="a-color-secondary">\s*By\s*<\/span>\s*<a href="([^"]*)" class="noTextDecoration">([^<]*)<\/a>/
								if matches
									[__, authorUrl, authorName] = matches
								else
									authorName = 'A Customer'

								# badgeMatches = @matchAll reviewMatch, /<span class='c7yBadge[^']*'>([^<]*)<\/span>/
								# badges = []
								# for badgeMatch in badgeMatches
								# 	badges.push badgeMatch[1]

								reviews.push rating:rating, url:url, title:title, time:time, review:review, author:{url:"http://www.amazon.com#{authorUrl}" if authorUrl, name:authorName}, helpfulCount:helpfulCount, helpfulTotal:helpfulTotal, amazonVerifiedPurchase:amazonVerifiedPurchase, comments:{url:commentsUrl, count:commentsCount ? 0}

							matches = @resource.match /<a href="([^"]*)">([\d,]*) customer reviews<\/a>/
							if matches
								reviewsUrl = matches[1]
								count = matches[2]
							else 
								matches = @resource.match /<a class="a-link-emphasis a-text-bold" href="([^"]*)">\s*See all ([\d,]*) customer reviews \(newest first\)\s*<\/a>/
								if matches
									reviewsUrl = matches[1]
									count = matches[2]
								else
									matches = @resource.match /<a class="a-link-emphasis a-nowrap" href="([^"]*)">See the customer review<\/a>/
									if matches
										count = 1
										reviewsUrl = matches[1]
									else
										# http://www.amazon.com/gp/product/B00B4PBJ14
										matches = @resource.match /<a class="a-link-emphasis a-nowrap" href="([^"]*)">See both customer reviews \(newest first\)<\/a>/
										if matches
											count = 2
											reviewsUrl = matches[1]
					@value reviews:reviews, url:reviewsUrl, count:count

