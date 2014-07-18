define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) ->

	class VictoriasSecretProductScraper extends ProductScraper
		@testProducts: [
			'165629'
		]
		resources:
			productPage:
				url: -> "http://www.victoriassecret.com/panties/bikinis/-?ProductID=#{@productSid}"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<meta property="og:title" content="([^"]*)/), 1

			price:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					firstMatches = @resource.match /<div class="price">([\S\s]*?)<div class="more">/
					matches = firstMatches[1].match /<p>([\S\s]*)/
					dashMatches = matches[1].match /([\S\s]*?)<a/
					if !dashMatches
						dashMatches = matches[1].match /([\S\s]*?)<\/p/
					if !dashMatches
						dashMatches = matches[1].match /([\S\s]*?)<div class="more"/
					if !dashMatches
						dashMatches = matches[1].match /([\S\s]*?)<br/													
					dash = dashMatches[1].match /(-)/
					orig = matches[1].match /(Sale)/
					orMatch = matches[1].match /( or )/
					if dash && orig && !(orMatch)
						prices = []
						priceMatches = matches[1].match /Sale \$([^<]+)/g
						for match in priceMatches
							prices.push match.match(/Sale \$([^<]+)/)[1]
						price = prices[0] + " - $" + prices[1]
					else if dash && orMatch && !(orig)
						prices = []
						priceMatches = matches[1].match /\$([^\.]+.\d\d)/g
						for match in priceMatches
							prices.push match.match(/\$([^\.]+.\d\d)/)[1]
						special = matches[1].match(/or([\S\s]*)<\//)
						special = special[1].match(/>([^<]+)/)
						price = prices[0] + " - $" + prices[1] + " or " + special[1]
					else if !(dash) && orMatch && !(orig)
						priceMatch = matches[1].match /\$([^\.]+.\d\d)/
						special = matches[1].match(/or([\S\s]*)<\//)
						special = special[1].match(/>([^<]+)/)
						price = priceMatch[1] + " or " + special[1]
					else if orig && !(dash) && !(orMatch)
						priceMatches = matches[1].match /Sale \$([^<]+)/
						price = priceMatches[1]
					else if !(orig) && !(dash) && !(orMatch)
						priceMatches = matches[1].match /\$([^<]+)/
						price = priceMatches[1]
					else if !(orig) && dash && !(orMatch)
						priceMatches = matches[1].match /\$([^<]+)/
						price = priceMatches[1].trim()					
					@value price

			# image:
			# 	resource: 'productPage'
			# 	scraper: PatternResourceScraper new RegExp(//), 1

			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					link = /<meta property="og:image" content="([^"]*)/.exec(@resource)[1]
					link = "https://dm.victoriassecret.com/product/404x539/" + link.match(/https:\/\/dm\.victoriassecret\.com\/product\/[^\/]+\/([\S\s]*)/)[1]
					@value link

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					# console.log @resource
					switches = 
						images: true #done
						description: true #done
						originalPrice: true #done

						shipping: false


					value = {}

					if switches.description
						matches = @resource.match /<div id="description">([\S\s]*?)<\/div>/
						value.description = matches[1] + "</div>"

					if switches.details
						matches = @resource.match /<span class="info-tooltip-display">([\S\s]*?)<\/span>/
						value.details = matches[1]


					if switches.originalPrice
						firstMatches = @resource.match /<div class="price">([\S\s]*?)<div class="more">/
						matches = firstMatches[1].match /<p>([\S\s]*)/
						dashMatches = matches[1].match /([\S\s]*?)<a/
						if !dashMatches
							dashMatches = matches[1].match /([\S\s]*?)<\/p/
						if !dashMatches
							dashMatches = matches[1].match /([\S\s]*?)<div class="more"/
						if !dashMatches
							dashMatches = matches[1].match /([\S\s]*?)<br/													
						dash = dashMatches[1].match /(-)/
						orig = matches[1].match /(Sale)/
						orMatch = matches[1].match /( or )/
						if dash && orig && !(orMatch)
							prices = []
							priceMatches = matches[1].match /Orig\. \$([^<]+)/g
							for match in priceMatches
								prices.push match.match(/Orig\. \$([^<]+)/)[1]
							price = prices[0] + " - $" + prices[1]
						else if dash && orMatch && !(orig)
							price = null
						else if !(dash) && orMatch && !(orig)
							price = null
						else if orig && !(dash) && !(orMatch)
							priceMatches = matches[1].match /Orig\. \$([^<]+)/
							price = priceMatches[1]
						else if !(orig) && !(dash) && !(orMatch)
							price = null
						value.originalPrice = price


					if switches.images
						images = {}
						colors = {}

						matches = @resource.match /<div class="swap">([\S\s]*?)<\/div>/
						codes = matches[1].match /<span[\s]*?data-alt-image="([^<]*)/g
						if codes
							for code in codes
								name = code.match(/>([\S\s]*)/)[1]
								code = code.match(/data-alt-image="([^"]*)/)[1]
								colors[name] = "https://dm.victoriassecret.com/product/404x539/" + code + ".jpg"
						images["colors"] = colors


						alternate = []
						matches = @resource.match /<div class="product-image-group">([\S\s]*?)<\/section>/
						matches = matches[1].match /<li([\S\s]*?)<\/li>/g
						if matches
							for match in matches
								match = match.match /src="([^"]+)/
								if match
									alternate.push "http:" + match[1]
							images["alternate"] = alternate

						# viewMatches = matches[1].match /<img([\S\s]*?)<\/span>/g
						# for match in viewMatches
						# 	image = match.match /src="([^"]*)/
						# 	image = image[1].replace(/63x84+/gm,'404x539') 
						# 	name = match.match /<span>([^<]*)/
						# 	views[name[1]] = "http:" + image
						# images["views"] = views

						# matches = @resource.match /<section class="swatches([\S\s]*?)<\/section>/
						# colorMatches = matches[1].match /<a([\S\s]*?)<\/a>/g
						# for match in colorMatches
						# 	pics = {}
							
						# 	image = match.match /data-alt-image="([^"]*)/
						# 	if image
						# 		image = "http://dm.victoriassecret.com/product/404x539/" + image[1] + ".jpg"
						# 	else 
						# 		image = null # image not available"
						# 	pics["image"] = image

						# 	swatch = match.match /src="([^"]*)/
						# 	pics["swatch"] = "http:" + swatch[1]

						# 	name = match.match /<span[^>]*>([^<]*)<\/span>/
						# 	colors[name[1]] = pics

						# images["colors"] = colors

						value.images = images


					@value value
