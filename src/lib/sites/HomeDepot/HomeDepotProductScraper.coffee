define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class HomeDepotProductScraper extends ProductScraper
		@testProducts: [
			'204617362'
		]
		resources:
			productPage:
				url: -> "http://www.homedepot.com/p/#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<span id="ajaxPrice" class="pReg" itemprop="price">\s*\$([^<]*)/), 1

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
						specifications: true #done
						rating: true #done
						ratingCount: true #done
						originalPrice: true #done

						shipping: false #ship to store free, ship to home not sure


					value = {}

					if switches.overview
						overview = []
						matches = @resource.match /<div class="main_description([\S\s]*?)<\/div>/
						overviewMatches = matches[1].match /<p[^>]+>([\S\s]*?)<\/p>/g # all pages I've seen have the desc inside <span itemprop="description"> if we want to strip that out
						for match in overviewMatches
							text = match.match /<p[^>]+>([\S\s]*?)<\/p>/
							overview.push text[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

						features = []
						specMatches = matches[1].match /<li>([\S\s]*?)<\/li>/g
						if specMatches
							for match in specMatches
								feature = match.match(/<li>([\S\s]*?)<\/li>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
								features.push feature
							overview.push features
						value.overview = overview


					if switches.specifications
						matches = @resource.match /<div id="specifications"([\S\s]*?)<\/table>/
						specs = {}
						specMatches = matches[1].match /<tr([\S\s]*?)<\/tr>|<tr([\S\s]*?)<\/tbody>/g
						for match in specMatches
							full = match.match /<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>/
							if full
								title = match.match(/<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm,'')
								content = match.match(/<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm,'')						
								specs[title] = content
								title = match.match(/<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm,'')
								content = match.match(/<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm,'')							
								specs[title] = content							
							else
								title = match.match(/<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm,'')
								content = match.match(/<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm,'')						
								specs[title] = content
						value.specifications = specs






					if switches.details
						details = []
						matches = @resource.match /<div class="product-details([\S\s]*?)<\/section>/
						detailMatches = matches[1].match /<li([\S\s]*?)<\/li>/g
						for match in detailMatches
							title = match.match(/<span>([\S\s]*?)<\/span>/)[1]
							content = match.match(/<\/span>([\S\s]*?)<\/li>/)[1]
							text = title + content
							details.push text.replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ") #trim spaces and returns etc - .trim() stopped working 
						value.details = details

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

					if switches.rating
						matches = @resource.match /<meta itemprop="ratingValue" content="([^"]+)/
						if matches
							value.rating = matches[1]

					if switches.reviewCount
						matches = @resource.match /<meta itemprop="reviewCount" content="([^"]+)/
						if matches
							value.reviewCount = matches[1]

					if switches.editorialReviews
						editorialReviews = {}
						matches = @resource.safeMatch /<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/
						erMatches = matches[1].match /<article class="simple-html">([\S\s]*?)<\/article>/g
						for match in erMatches
							from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1]
							content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
							editorialReviews[from] = content
						value.editorialReviews = editorialReviews

					if switches.originalPrice
						matches = @resource.match /<span id="ajaxPriceStrikeThru">[\s]*\$([^<]+)/
						if matches
							value.originalPrice = matches[1]

					if switches.images
						images = {}
						matches = @resource.match /PRODUCT_INLINE_PLAYER_JSON([^<]+)/
						imageMatches = matches[1].match /"height":"1000","width":"1000","mediaUrl":"([^\{]+)/g
						for match in imageMatches
							image = match.match(/"height":"1000","width":"1000","mediaUrl":"([^"]+)/)[1]
							alt = match.match /\}],"([^"]+)/
							if alt
								images[alt[1]] = image
							else
								images["other"] = image
						value.images = images


					@value value
