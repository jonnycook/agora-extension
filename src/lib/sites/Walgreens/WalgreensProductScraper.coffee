define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class WalgreensProductScraper extends ProductScraper
		@testProducts: [
			'6051381'
		]
		resources:
			productPage:
				url: -> "http://www.walgreens.com/store/c/-/ID=prod#{@productSid}-product"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content='([^']*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<span id="vpdSinglePrice">\$([^<]*)/), 1]
					[new RegExp(/id='sale_amount' itemprop="price">\$([^<]*)/), 1]
					[new RegExp(/id='price_amount' itemprop="price">\$([^<]*)/), 1]
					[new RegExp(/id='sale_amount' itemprop="price">([^<]*)/), 1]
					[new RegExp(/id='sale_amount' itemprop="price">([^<]*)/), 1]
					[new RegExp(/id="txt24px">([^<]*)/), 1] #priced per store
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper(new RegExp(/<meta property="og:image" content='http:\/\/www\.walgreens\.com\/\/pics\.drugstore\.com\/prodimg\/([^\/]*)/), 1).config
					map: (value) -> "http://pics.drugstore.com/prodimg/#{value}/500.jpg"

					 #can be replaced with 450.jpg or 500.jpg at least, probably more

			rating:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->		
					matches = @resource.match /<span itemprop="ratingValue" style="display:none">([^<]*)/
					if matches
						@value matches[1]

			ratingCount:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->		
					matches = @resource.match /<span itemprop="reviewCount"[^>]*>([^<]*)/
					if matches
						@value matches[1]

			reviews:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->		
					ratUrl = "http://reviews.walgreens.com/2001/prod#{@productSid}/-/reviews.htm"
					revs = []
					@execBlock ->
						@get ratUrl, (response)->
							reviews = response.match /<div id="BVRRDisplayContentReviewID([\S\s]*?)BVRRSSeparatorContentBodyBottom/g
							if reviews
								for entry in reviews
									isReview = entry.match /class="BVRRValue BVRRReviewTitle">([^<]*)/
									if isReview
										if isReview[1].length != 0
											revHash = {}
											revHash["author"] = entry.match(/class="BVRRNickname">([^<]+)/)[1]				
											revHash["title"] = entry.match(/class="BVRRValue BVRRReviewTitle">([^<]+)/)[1]
											revHash["review"] = entry.match(/class="BVRRReviewText">([\S\s]*?)<\/span>/)[1]
											rating = entry.match /BVRRRatingNumber">([\S\s]*?)<\/span>/
											if rating
												if rating[1].length != 0
													revHash["rating"] = rating[1]
											revHash["time"] = entry.match(/BVRRReviewDate">([\S\s]*?)<\/span>/)[1]
											revs.push revHash
							@value revs	
							@done true
						null
					@value revs

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						overview: true #done
						description: true #done
						ingredients: true #done
						uses: true #done
						warnings: true #done
						originalPrice: true #done

						shipping: false # site wide FREE on orders of $25 or more


					value = {}

					if switches.overview
						overview = []
						matches = @resource.match /<strong>Overview:<\/strong>([\S\s]*?)<\/div>/
						value.overview = matches[1]

					if switches.description
						description = []
						altDescCheck = @resource.match /(<script type="text\/javascript" src="http:\/\/content.webcollage.net\/walgreens\/smart-button">)/
						if altDescCheck
							altDescUrl = "http://content.webcollage.net/walgreens/smart-button?ird=true&channel-product-id=prod#{@productSid}"
							@execBlock ->
								@get altDescUrl, (response)->
									matches = response.match /html: "([\S\s]*?)};/
									description.push matches[1].replace(/\}+$/gm,'').replace(/\"+$/gm,'').replace(/\\"+/gm,'"').replace(/\\\/+/gm,'/')
									@done true
									@value value
								null
							value.description = description[0]
						else
							desc = @resource.match /<div class="description-list[^>]*>([\S\s]*?)<!-- EO-10598 description tab content ends here -->/
							if desc
								description.push "<div><div>" + desc[1]
								value.description = description[0]

					if switches.ingredients
						ingredients = @resource.match /<div id="ingredients-content" class="tabContainer">([\S\s]*?)<\/noscript>/
						if ingredients
							value.ingredients = ingredients[1]

					if switches.warnings
						warnings = @resource.match /<div id="warnings-content" class="tabContainer">([\S\s]*?)<div id="tab-ingredients"/
						if warnings
							value.warnings = warnings[1]

					if switches.uses
						uses = @resource.match /<div id="uses-content" class="tabContainer">([\S\s]*?)<div id="shipping-content"/
						if uses
							value.uses = uses[1]









					if switches.isbn
						matches = @resource.match /<div class="product-details([\S\s]*?)<\/section>/
						isbn = matches[1].match /<span>ISBN-13:<\/span>([\S\s]*?)<\/li>/
						value.isbn = isbn[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")		

					if switches.author
						author = {}
						authorNames = []
						matches = @resource.match /<ul class="contributors([\S\s]*?)<\/ul>/
						authorMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						count = 0

						for item in authorMatches
							if count > 0
								name = item.match(/<li([\S\s]*?)<\/li>/)[1]
								authorNames.push name.replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
							count++
						author["names"] = authorNames

						authorBio = []
						bioMatch = @resource.match /<div class="basic-info([\S\s]*?)<\/section>/
						bioMatches = bioMatch[1].match /<p>([\S\s]*?)<\/p>/g
						for match in bioMatches
							par = match.match(/<p>([\S\s]*?)<\/p>/)[1]
							authorBio.push par
						author["bio"] = authorBio
						# imageMatch = @resource.match(/<div id="product-commentary-meet-the-author-1"([\S\s]*?)<\/section>/)
						# image = imageMatch[1].safeMatch(/src="([^"]+)/)[1] #Author Image only exists on some pages, make this conditional
						# if image
						# 	author["authorImage"] = image
						value.author = author

					if switches.editorialReviews
						editorialReviews = {}
						matches = @resource.safeMatch /<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/
						erMatches = matches[1].match /<article class="simple-html">([\S\s]*?)<\/article>/g
						for match in erMatches
							from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1]
							content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^<br \/>+|<br \/>+$/gm,'')
							editorialReviews[from] = content
						value.editorialReviews = editorialReviews

					if switches.originalPrice
						matches = @resource.match /class="strike_thru[^>]+>\$([^<]+)/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = []
						matches = @resource.match /<div class="view_thumb_image"([\S\s]*?)<\/div>/
						imageMatches = matches[1].match /href="javascript:changeImage\('([^']+)/g
						for match in imageMatches
							image = match.match /href="javascript:changeImage\('([^']+)/
							images.push "http:" + image[1]
						value.images = images


					@value value
