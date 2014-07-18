define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class UniqloProductScraper extends ProductScraper
		@testProducts: {"086831-22":{"image":"http://uniqlo.scene7.com/is/image/UNIQLO/goods_22_086831?$pdp-medium$","rating":"5","ratingCount":"1","title":"WOMEN SUPIMA COTTON TANK TOP","price":"9.90","more":{"description":"This tank top is made of soft Supima&reg; cotton in a shapely, feminine silhouette. Great for layering or wearing alone, this tank is available in a wide range of colors.","materials":["94% cotton, 6% spandex","Machine wash cold","Imported"],"sizes":["XS","S","M","L","XL","XXL"]}},"075819-68":{"image":"http://uniqlo.scene7.com/is/image/UNIQLO/goods_68_075819?$pdp-medium$","rating":0,"ratingCount":0,"title":"WOMEN COLOR RIB SLEEVELESS TOP","price":"5.90","more":{"description":"This ribbed tank top offers a great fit in modern, minimalist style. Ideal for layering.","materials":["50% rayon, 50% cotton","Machine wash cold, gentle cycle","Imported"],"sizes":["XS","S","M","L","XL"]}}, "075481-09":{}} 

		parseSid: (sid) ->
			parts = sid.split('-') 
			id: parts[0]
			color: parts[1] ? '00'
			size: parts[2] ? '000'
			length: parts[0] ? '000'

		resources:
			productData:
				url: -> "http://www.uniqlo.com/us/store/gcx/getProductInfo.do?format=json&product_cd=#{@productSid.id}"
			reviewData:
				url: -> "http://uniqloenus.ugc.bazaarvoice.com/5311-en_us/#{@productSid.id}/reviews.djs?format=embeddedhtml"

		properties:
			title:
				resource: 'productData'
				scraper: JsonResourceScraper (data) -> data.goods_name.trim()
			price:
				resource: 'productData'
				scraper: JsonResourceScraper (data) -> data.first_price

			image: (cb) -> cb "http://uniqlo.scene7.com/is/image/UNIQLO/goods_#{@productSid.color}_#{@productSid.id}?$pdp-medium$"

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

			more:
				resource: 'productData'
				scraper: JsonResourceScraper (data) ->
					more = {}

					if data.dtl_exp
						more.description = data.dtl_exp.trim()

					more.materials = @matchAll data.material_info, /<li>([\S\s]*?)<\/li>/, 1

					more.sizes = _.map data.size_info_list, (obj) -> obj.size_nm

					if data.goods_sub_image_list
						more.images = _.map data.goods_sub_image_list.split(';'), (i) -> "http://uniqlo.scene7.com/is/image/UNIQLO/goods_#{i}"
					else
						more.images = []

					more.colors = _.map data.color_info_list, (obj) -> name:obj.color_nm, id:obj.color_cd

					more

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
					