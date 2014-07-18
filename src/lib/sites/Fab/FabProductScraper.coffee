define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class FabProductScraper extends ProductScraper
		@testProducts: [
			'452728'
		]
		resources:
			productPage:
				url: -> "http://fab.com/product/#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<h1 id="productTitle" itemprop="name">([^<]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[new RegExp(/<span[\s]+itemprop="price">[\s]*\$([^<]*)/), 1] # needs trimming
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:image" content="([^"]*)/), 1


			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						overview: true #done
						details: true #done
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done
						# scrape designer section?
						reviews: false # needs request header added manually

						shipping: false #done


					value = {}
					if switches.reviews
						ratUrl = "http://fab.com/product-review/get-top-reviews/#{@productSid}/"
						revs = []
						@execBlock ->
							@get ratUrl, (response)->
								value.reviews = response

								reviews = JSON.parse response
								# if reviews['data']['reviews']
								# 	for entry in reviews['data']['reviews']
								# 		revHash = {}
								# 		author = {}
								# 		author["name"] = entry['author']['screenName']
								# 		author["url"] = "http://www.sears.com/shc/s/PublicProfileView?requestType=public_profile&langId=-1&storeId=10153&key=" + entry['author']['extUserId']
								# 		revHash["author"] = author					
								# 		revHash["searsVerifiedPurchase"] = entry['author']['isBuyer']
								# 		revHash["title"] = entry['summary']
								# 		revHash["review"] = entry['content']
								# 		if entry['attribute_rating']
								# 			for rat in entry['attribute_rating']
								# 				if rat['attribute'] == "overall_rating" && rat['attribute_type'] == "numeric"
								# 					revHash["rating"] = rat['value']
								# 		revHash["time"] = entry['published_date']
										



								# 		revs.push revHash
								# 	value.reviews = revs
								@done true
								@value value
							null

					if switches.overview
						overview = []
						matches = @resource.match /itemprop="description">([\S\s]*?)<\/div>/
						overviewMatches = matches[1].match /<p>([\S\s]*?)<\/p>/g
						for match in overviewMatches
							text = match.match /<p>([\S\s]*?)<\/p>/
							overview.push text[1]
						value.overview = overview

					if switches.details
						details = []
						matches = @resource.match /<div class="desc">([\S\s]*?)<\/div>/

						parMatches = matches[1].match /<p>([\S\s]*?)<\/p>/g
						if parMatches
							paras = []
							for match in parMatches
								par = match.match(/<p>([\S\s]*?)<\/p>/)[1]
								paras.push par
							details.push paras

						firstListMatches = matches[1].match /<li>([\S\s]*?)<\/li>/g
						if firstListMatches
							firstList = []
							for match in firstListMatches
								entry = match.match(/<li><span[^<]+>([\S\s]*?)<\/span>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^<br\/>+|<br\/>+$/gm,'').replace(/^<br \/>+|<br \/>+$/gm,'')
								firstList.push entry
							details.push firstList

						newMatches = @resource.match /<ul class="tblList" id="tblListTgl">([\S\s]*?)<\/ul>/
						if newMatches
							secondListMatches = newMatches[1].match /<div class="productAttr">[^<]+<\/div>[\s]*?<div[^>]+>([^<]+)<\/div>/g
							secondList = {}
							for match in secondListMatches
								title = match.match(/<div class="productAttr">([^<]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
								content = match.match(/<div class="productAttr">[^<]+<\/div>[\s]*?<div[^>]+>([^<]+)<\/div>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^<br\/>+|<br\/>+$/gm,'')
								secondList[title] = content
							details.push secondList
						value.details = details

		

					if switches.author #could be converted into designer scrape
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




					if switches.rating
						matches = @resource.match /<meta itemprop="rating" content="([^"]+)/
						if matches
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /<meta itemprop="votes" content="([^"]+)/
						if matches
							value.reviewCount = matches[1]

					if switches.originalPrice
						matches = @resource.match /"original_price":"([\S\s]*?)",/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = []
						matches = @resource.match /<ul id="moreIndvProdImages"([\S\s]*?)<\/ul>/
						imageMatches = matches[1].match /src="([^"]+)/g
						for match in imageMatches
							image = match.match /src="([^"]+)/
							first = image[1].match(/\/\/(.*?)70x70/)[1]
							last = image[1].match(/70x70(.*)/)[1]
							middle = "610x610"
							image = first + middle + last
							images.push "http://" + image
						value.images = images

					if switches.shipping
						shipping = {}
						matches = @resource.match /<ul class="tblList" id="shippingDetails"([\S\s]*?)<\/ul>/
						shippingMatches = matches[1].match /<label>[^<]+<\/label>[\s]*?<span[^>]+>([\S\s]*?)<\/span>/g			
						for match in shippingMatches
							title = match.match(/<label>([^<]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
							content = match.match(/<label>[^<]+<\/label>[\s]*?<span[^>]+>([\S\s]*?)<\/span>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^<br\/>+|<br\/>+$/gm,'')
							shipping[title] = content
						value.shipping = shipping

					@value value
