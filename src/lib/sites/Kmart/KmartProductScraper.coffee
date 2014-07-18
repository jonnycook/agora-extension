define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class KmartProductScraper extends ProductScraper
		@testProducts: [

		]
		resources:
			productPage:
				url: -> "http://www.kmart.com/-/p-#{@productSid}"

			productData:
				type: 'json'
				url: -> "http://www.kmart.com/content/pdp/config/products/v1/products/#{@productSid}?site=kmart"

			priceData:
				type: 'json'
				url: ->
					number = @productSid.value
					if number[number.length - 1] == 'P'
						number = number.substr(0,number.length - 1)						

					"http://www.kmart.com/content/pdp/products/pricing/#{number}?variation=0&regionCode=0"

		properties:
			title:
				resource: 'productData'
				scraper: JsonResourceScraper (data) -> 
					data.data.product.seo.title.match(/([^-]+)-/)[1].trim()

			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					price = ''
					number = @productSid.value
					console.debug 'asdf'
					console.debug number
					if number[number.length - 1] == 'P'
						number = number.substr(0,number.length - 1)
					priceUrl = "http://www.kmart.com/content/pdp/products/pricing/" + number + "?variation=0&regionCode=0"
					@execBlock ->
						@get priceUrl, (response)->
							# console.debug response
							originalPrice = JSON.parse response
							if originalPrice['price-response']['item-response']['sell-price']['$']
								if originalPrice['price-response']['item-response']['sell-price']['$'] != "0.00"
									price = originalPrice['price-response']['item-response']['sell-price']['$']
								else
									altPriceUrl = "http://www.kmart.com/shc/s/ItemSavestoryAjax?storeId=10153&prdType=VARIATION&prdBeanType=ProductBean&ajaxFlow=true&partNumber=" + number + "P"
									@execBlock ->
										@get altPriceUrl, (response)->
											originalPrice = response.match /"prodDispPrice":"([^,]+|[^"]+)/
											if originalPrice
												price = originalPrice[1]
											@value price	
											@done true
										null
							@value price		
							@done true
						null
					@value price

			image:
				resource: 'productData'
				scraper: JsonResourceScraper (data) -> 
					if data.data.product.assets.imgs[0].vals[0].src.indexOf('?') == -1
						"#{data.data.product.assets.imgs[0].vals[0].src}?hei=623&wid=623&qlt=50,0&op_sharpen=1&op_usm=0.9,0.5,0,0"
					else
						data.data.product.assets.imgs[0].vals[0].src

			rating:
				resource: 'productData'
				scraper: ScriptedResourceScraper ->		
					rating = ''		
					ratUrl = "http://www.kmart.com/content/pdp/ratings/single/search/Kmart/#{@productSid}&targetType=product&limit=1&offset=0"
					@execBlock ->
						@get ratUrl, (response)->
							rating = JSON.parse response
							if rating['data']['overall_rating']
								rating = rating['data']['overall_rating']
							@value rating	
							@done true
						null
					@value rating

			ratingCount:
				resource: 'productData'
				scraper: ScriptedResourceScraper ->		
					ratingCount = ''		
					ratUrl = "http://www.kmart.com/content/pdp/ratings/single/search/Kmart/#{@productSid}&targetType=product&limit=1&offset=0"
					@execBlock ->
						@get ratUrl, (response)->
							ratingCount = JSON.parse response
							if ratingCount['data']['review_count']
								ratingCount = ratingCount['data']['review_count']
							@value ratingCount	
							@done true
						null
					@value ratingCount

			reviews:
				resource: 'productData'
				scraper: ScriptedResourceScraper ->		
					ratUrl = "http://www.kmart.com/content/pdp/ratings/single/search/Kmart/#{@productSid}&targetType=product&limit=10000&offset=0"
					revs = []
					@execBlock ->
						@get ratUrl, (response)->
							reviews = JSON.parse response
							if reviews['data']['reviews']
								for entry in reviews['data']['reviews']
									revHash = {}
									author = {}
									author["name"] = entry['author']['screenName']
									author["url"] = "http://www.kmart.com/shc/s/PublicProfileView?requestType=public_profile&langId=-1&storeId=10153&key=" + entry['author']['extUserId']
									revHash["author"] = author					
									revHash["kmartVerifiedPurchase"] = entry['author']['isBuyer']
									revHash["title"] = entry['summary']
									revHash["review"] = entry['content']
									if entry['attribute_rating']
										for rat in entry['attribute_rating']
											if rat['attribute'] == "overall_rating" && rat['attribute_type'] == "numeric"
												revHash["rating"] = rat['value']
									revHash["time"] = entry['published_date']
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
						description: true #done
						specifications: true #done
						originalPrice: true #done
						shipping: false #waiting - if we get user zip code in the future then we can do this. - notes: http://www.kmart.com/shc/s/FetchShipOptionsCmd?storeId=10153&langId=-1&fromPage=PDP&quantity=1&itemPartNumber=02073163000&zipCode=52556

					value = {}

					if switches.images
						imgUrl = "http://www.kmart.com/content/pdp/config/products/v1/products/#{@productSid}?site=kmart"
						# testArr = []
						@execBlock ->
							@get imgUrl, (response)->
								images = JSON.parse response
								if images['data']['product']['variants']
									if images['data']['product']['variants']['definingAttrs'] #if there are multiple colors on the same productSID
										imageArr = []
										for pocket in images['data']['product']['variants']['definingAttrs']
											if pocket['name'] == 'Color'
												for color in pocket['vals']
													variant = {}
													variantName = {}
													colorName = color['name']
													variant['primaryImg'] = color['primaryImg']['attrs']['src']
													variant['swatchImg'] = color['swatchImg']['attrs']['src']
													for altPocket in images['product']['variants']['sku']
														theColor = altPocket['name'].match(/Color:([^,]*|$)/)[1]
														if theColor == colorName
															if altPocket['alternateImg']
																for entry in altPocket['alternateImg']
																	variant['altImg'] = entry['src']
													variantName[colorName] = variant
													imageArr.push variantName
										value.images = imageArr
								else #if there is one color or only one on this SID
									imageArr = []
									for pocket in images['data']['product']['assets']['imgs']
										if pocket['type'] == 'P'
											for entry in pocket['vals']
												variant = {}
												variantName = {}
												variant['primaryImg'] = entry['src']
												# for altPocket in images['product']['variants']['sku']
												# 	theColor = altPocket['name'].match(/Color:([^,]*|$)/)[1]
												# 	if theColor == colorName
												# 		for entry in altPocket['alternateImg']
												# 			variant['altImg'] = entry['src']
												variantName["Main"] = variant
												imageArr.push variantName
										else if pocket['type'] == 'A'
											for entry in pocket['vals']
												variant = {}
												variantName = {}
												variant['primaryImg'] = entry['src']
												# for altPocket in images['product']['variants']['sku']
												# 	theColor = altPocket['name'].match(/Color:([^,]*|$)/)[1]
												# 	if theColor == colorName
												# 		for entry in altPocket['alternateImg']
												# 			variant['altImg'] = entry['src']
												variantName["Other"] = variant
												imageArr.push variantName												
									value.images = imageArr
								@done true
								@value value
							null

					# if switches.shipping
					# 	storeId = @resource.match(/window\.SHC\.Site\.storeId = '([^']+)/)
					# 	if !storeId
					# 		storeId = "10153"

					# 	priceUrl = "http://www.kmart.com/content/pdp/products/pricing/" + number + "?variation=0&regionCode=0"
					# 	@execBlock ->
					# 		@get priceUrl, (response)->
					# 			shipping = JSON.parse response
					# 			if shipping['price-response']['item-response']['regular-price']
					# 				value.shipping = shipping['price-response']['item-response']['regular-price']
					# 			@done true
					# 			@value value
					# 		null

					if switches.reviews
						ratUrl = "http://www.kmart.com/content/pdp/ratings/single/search/Kmart/#{@productSid}&targetType=product&limit=10000&offset=0"
						revs = []
						@execBlock ->
							@get ratUrl, (response)->
								reviews = JSON.parse response
								if reviews['data']['reviews']
									for entry in reviews['data']['reviews']
										revHash = {}
										author = {}
										author["name"] = entry['author']['screenName']
										author["url"] = "http://www.kmart.com/shc/s/PublicProfileView?requestType=public_profile&langId=-1&storeId=10153&key=" + entry['author']['extUserId']
										revHash["author"] = author					
										revHash["kmartVerifiedPurchase"] = entry['author']['isBuyer']
										revHash["title"] = entry['summary']
										revHash["review"] = entry['content']
										if entry['attribute_rating']
											for rat in entry['attribute_rating']
												if rat['attribute'] == "overall_rating" && rat['attribute_type'] == "numeric"
													revHash["rating"] = rat['value']
										revHash["time"] = entry['published_date']
										revs.push revHash
									value.reviews = revs
								@done true
								@value value
							null

					if switches.description
						descUrl = "http://www.kmart.com/content/pdp/config/products/v1/products/#{@productSid}?site=kmart"
						description = null
						@execBlock ->
							@get descUrl, (response)->
								description = JSON.parse response
								if description['data']['product']['desc'][0]['type'] == 'S'
									if description['data']['product']['desc'][1]['type'] == 'L'
										value.description = description['data']['product']['desc'][0]['val'] + description['data']['product']['desc'][1]['val']
									else
										value.description = description['data']['product']['desc'][0]['val']
								else if description['data']['product']['seo']['desc']
									value.description = description['data']['product']['seo']['desc']
								@done true
								@value value
							null

					if switches.specifications
						descUrl = "http://www.kmart.com/content/pdp/config/products/v1/products/#{@productSid}?site=kmart"
						specs = {}
						@execBlock ->
							@get descUrl, (response)->
								specifications = JSON.parse response
								if specifications['data']['product']['specs']
									for entry in specifications['data']['product']['specs']
										specHash = {}
										for thing in entry['attrs']
											specHash[thing['name']] = thing['val']
										specs[entry['grpName']] = specHash
									value.specifications = specs
								@done true
								@value value
							null

					if switches.originalPrice
						number = @productSid.value
						if number[number.length - 1] == 'P'
							number = number.substr(0,number.length - 1)
						priceUrl = "http://www.kmart.com/content/pdp/products/pricing/" + number + "?variation=0&regionCode=0"
						@execBlock ->
							@get priceUrl, (response)->
								originalPrice = JSON.parse response
								if originalPrice['price-response']['item-response']['regular-price']
									if originalPrice['price-response']['item-response']['regular-price'] != "0.00"
										value.originalPrice = originalPrice['price-response']['item-response']['regular-price']
									else
										altPriceUrl = "http://www.kmart.com/shc/s/ItemSavestoryAjax?storeId=10153&prdType=VARIATION&prdBeanType=ProductBean&ajaxFlow=true&partNumber=" + number + "P"
										@execBlock ->
											@get altPriceUrl, (response)->
												originalPrice = response.match /"prodRegPrice":([^,]+|[^"]+)/
												if originalPrice
													value.originalPrice = originalPrice[1]
												@done true
												@value value
											null	



								@done true
								@value value
							null	

					@value value
