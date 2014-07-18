define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class Forever21ProductScraper extends ProductScraper
		@testProducts: [
			135898
			941783012
		]

		@test: 
			title: ['2000109887']
			image: ['2000109887']
			price:
				0: ['2018732251']
				1: ['2000109887']

		resources:
			productPage:
				url: -> "http://www.forever21.com/Product/Product.aspx?category=sweater&ProductID=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper /<meta property="og:title" content="([^"]*)" \/>/, 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper [
					[/<span itemprop="price"><p class="was-now-price">Was:<s>[^<]*<\/s><br \/>Now:\$([^<]*)/, 1]
					[/<p class="product-price">\$([^<]*)<\/p>/, 1]
				]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper /<img id="ctl00_MainContent_productImage" class="[^"]*" title="[^"]*" src="([^"]*)/, 1

			# rating:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->
			# 		b = (Co) ->
			# 			Cn = 0
			# 			Cm = undefined
			# 			Cm = 0
			# 			while Cm < Co.length
			# 				Cl = Co.charCodeAt(Cm)
			# 				Cl = Cl * Math.abs(255 - Cl)
			# 				Cn += Cl
			# 				Cm++
			# 			Cn = Cn % 1023
			# 			Cn = Cn + ""
			# 			Cp = 4
			# 			Ck = Cn.split("")
			# 			Cm = 0
			# 			while Cm < Cp - Cn.length
			# 				Ck.unshift "0"
			# 				Cm++
			# 			Cn = Ck.join("")
			# 			Cn = Cn.substring(0, Cp / 2) + "/" + Cn.substring(Cp / 2, Cp)
			# 			Cn
			# 		url = "http://www.forever21.com/images/pwr/content/#{b @productSid}/contents.js"

			# 		/"p2030187343":\{"reviews":\{"review_ratings":[^"]*"review_count":(\d*),"avg":"([^"]*)"\}/.exec @resource



			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->

					overview = /<span id="product_overview" style="[^"]*" class="productFontColor">([\S\s]*)<\/span>/.exec(@resource)[1]

					description = overview.match(/<p>([\S\s]*?)(?:DETAILS:)?<\/p>/)[1]

					featuresMatch = overview.match(/<ul>([\S\s]*)<\/ul>/)[1]

					features = @matchAll featuresMatch, /<li>\s*([\S\s]*?)\s*<\/l?i>/, 1

					modelInfoMatch = overview.match(/Model Info:&nbsp;([^<]*)/)[1]
					modelInfoParts = modelInfoMatch.split(' | ')

					modelInfo = {}

					for modelInfoPart in modelInfoParts
						[key,value] = modelInfoPart.split ': '
						modelInfo[key] = value

					sizeMatch = /<select name="[^"]*" id="ctl00_MainContent_ddlSize" class="input" onchange="[^"]*" style="[^"]*">([\S\s]*?)<\/select>/.exec(@resource)[1]

					sizeMatches = @matchAll sizeMatch, /<option value="[^"]+">([^<]*)/, 1

						
					more =
						description:description
						features:features
						modelInfo:modelInfo
						sizes:sizeMatches


					@value more



