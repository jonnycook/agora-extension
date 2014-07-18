define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class CVSProductScraper extends ProductScraper
		@testProducts: [
			'681325'
		]
		resources:
			productPage:
				url: -> "http://www.cvs.com/shop/product-detail/-?skuId=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: new PatternResourceScraper new RegExp(/<h1 class="prodName">([^<]*)/), 1

			price:
				resource: 'productPage'
				scraper: new PatternResourceScraper [
					[new RegExp(/data-salePrice="\$([^"]*)/), 1] 
					[new RegExp(/<span itemprop="price">[\s]+\$([^<]*)/), 1]
				]

			image:
				resource: 'productPage'
				scraper: new PatternResourceScraper new RegExp(/<img itemprop="image" src="([^"]*)/), 1 #relative links

			more:
				resource: 'productPage'
				scraper: new ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						overview: false #done
						rating: false #BAZAAR VOICE
						reviewCount: false #BAZAAR VOICE
						originalPrice: true #done

					value = {}


					if switches.overview
						overview = []
						matches = @resource.match /<div class="productIngredients" id="prodDesc"([\S\s]*?)<\/div>/
						overviewMatches = matches[1].match /<p([\S\s]*?)<\/p>/g
						for match in overviewMatches
							text = match.match /<p([\S\s]*?)<\/p>/
							overview.push text[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")

						specs = {}
						specMatches = matches[1].match /<li([^<]+)/g
						if specMatches
							for match in specMatches
								col = match.match /(:)/
								if col
									title = match.match(/<li>([^:]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
									content = match.match(/:([^<]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")							
									specs[title] = content
								else
									title = match.match(/<li>([^<]+)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")
									specs[title] = null									
							overview.push specs
						value.overview = overview	

					if switches.originalPrice
						matches = @resource.match /<div class="priceStrike">([\S\s]*?)<\/div>/
						if matches
							price = matches[1]
							value.originalPrice = price.match(/\$([\S\s]*)/)[1].replace(/^\s+|\s+$/gm,'').replace(/\n\r/g, " ")


					@value value									