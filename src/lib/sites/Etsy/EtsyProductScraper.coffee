define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, _) ->
	class EtsyProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://www.etsy.com/listing/#{@productSid}"

		properties:

			title:
				resource: 'productPage'
				scraper: PatternResourceScraper /<span itemprop="name">([^<]*)<\/span>/, 1

			price:
				resource: 'productPage'
				scraper: PatternResourceScraper /<meta property="etsymarketplace:price_value" content="([^"]+)/, 1
				#was grabbing the first shipping price, fixed
			image:
				resource: 'productPage'
				scraper: ScriptedResourceScraper -> 
					matches = @resource.match /<li id="image-0"([\S\s]*?)<\/li>/
					image = matches[1].match /src='([^']*)'/
					@value image[1]

			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->

					switches = 
						images: true
						description: true
						about: false #aint no sirs here
						style: false 
						occasion: false
						who: false
						tags: true
						materials: true
						date: false
						shipping: false
						seller: false
						options: true 
						category: false


					value = {}


					if switches.images
						images = []
						matches = @resource.match /<div id="image-main">([\S\s]*?)<\/div>/

						imageMatches = matches[1].match /<li ([^>]*)>/g
						# console.log imageMatches

						for match in imageMatches
							fullUrl = match.match(/data-full-image-href="([^"]*)"/)[1]
							largeUrl = match.match(/data-large-image-href="([^"]*)"/)[1]
							images.push fullUrl:fullUrl, largeUrl:largeUrl
						value.images = images
						# console.log images

					if switches.description
						description = @resource.match /<div id="description-text">([\S\s]*?)<\/div>/
						value.description = description[1].replace(/\s+/g, " ").replace(/^\s+|\s+$/g, "")
						# class has space after it, design of the regex needs to be more flexible... and powerful

					if switches.about
						about = @resource.match /<h3>About this item<\/h3>\s*<p>([\S\s]*?)<\/p>/
						value.about = about[1].replace(/\s+/g, " ").replace(/^\s+|\s+$/g, "")

					if switches.style
						style = @resource.match /<h3>Style<\/h3>\s*<p>([\S\s]*?)<\/p>/
						value.style = style[1]

					if switches.occasion
						occasion = @resource.match /<h3>Occasion<\/h3>\s*<p>([\S\s]*?)<\/p>/
						value.occasion = occasion[1]		
										
					if switches.who
						who = @resource.match /<h3>Who it\&\#8217\;s for<\/h3>\s*<p>([\S\s]*?)<\/p>/
						value.who = who[1]

					if switches.tags
						tags = []
						matches = @resource.match /<div id="tags"([\S\s]*?)<\/div>/
						if matches
							tagMatches = matches[1].match /<a href="[^"]*">([^<]*)<\/a>/g
							for match in tagMatches
								tag = match.match(/<a href="[^"]*">([^<]*)<\/a>/)[1]
								tags.push tag
							value.tags = tags

					if switches.materials
						materials = []
						matches = @resource.match /<div id="item-overview">([\S\s]*?)<\/div>/
						materialMatches = matches[1].match /<li>Materials: ([\S\s]*?)<\/li>/
						if materialMatches
							materialMatches = materialMatches[1].match(/<span[^>]*>([\S\s]*?)<\/span>/)
							value.materials = materialMatches[1].split(", ")

					if switches.date
						date = @resource.match /<li>Listed on ([\S\s]*?)<\/li>/
						value.date = date[1]

					if switches.shipping
						shipping = 
							from: @resource.match(/<li>Ships [\S\s]*? from ([^<]*)<\/li>/)[1]

						shipping.rates = {}

						matches = @resource.match /<div class="section" id="item-shipping">([\S\s]*?)<\/div>/
						console.log matches[1]
						toMatches = matches[1].match /<td class="ship-to">([^<]*)<\/td>\s*<td class="ship-cost">\s*<span class="currency-symbol">[^<]*<\/span><span class="currency-value">([^<]*)<\/span>\s*<span class="currency-code">[^<]*<\/span>\s*<\/td>\s*<td class="ship-with">\s*<span class="currency-symbol">[^<]*<\/span>\s*<span class="currency-value">([^<]*)<\/span>/g
						for match in toMatches
							rowMatches = match.match /<td class="ship-to">([^<]*)<\/td>\s*<td class="ship-cost">\s*<span class="currency-symbol">[^<]*<\/span><span class="currency-value">([^<]*)<\/span>\s*<span class="currency-code">[^<]*<\/span>\s*<\/td>\s*<td class="ship-with">\s*<span class="currency-symbol">[^<]*<\/span>\s*<span class="currency-value">([^<]*)<\/span>/
							to = match.match(/<td class="ship-to">([^<]*)<\/td>/)[1].replace(/\s+/g, " ").replace(/^\s+|\s+$/g, "")
							single = match.match(/<span class="currency-value">([^<]*)<\/span>/)[1]
							combined = rowMatches[3]

							shipping.rates[to] = 
								single:single
								combined:combined

						value.shipping = shipping

					if switches.seller
						seller = @resource.match /<input type="hidden" value="([^"]*)" name="shopname" \/>/
						value.seller = seller[1]

					if switches.options
						options = {} # create a hash called options
						matches = @resource.match /<div class="item-variation-options clear">([\S\s]*?)<div id="item-overview">/ # find the options container div
						optionNameMatches = matches[1].match /<div class="item-variation-option clear">([\S\s]*?)<\/div>/g # find all the options
						if optionNameMatches
							for match in optionNameMatches # for each instance of a match of an option
								optionName = match.match /<label class="[^"]*">([^<]*)<\/label>/ # save the option name
								variationMatches = [] #create an array for the variations
								variations = match.match /<option[\s]*value[^>]*>([^<]*)<\/option>/g
								for vari in variations
									clean = vari.match(/<option[\s]*value[^>]*>([^<]*)<\/option>/)[1].trim()
									variationMatches.push clean
								options[optionName[1]] = variationMatches
							value.options = options
							console.log options.Size
							console.log options.Color

					if switches.category # grabs the final element from the nav/breadcrumbs
						first = @resource.match /<ul id="breadcrumbs" class="clear">([\S\s]*?)<\/ul>/
						matches = first[1].match /<a href="[^"]*">([\S\s]*?)<\/a>/g
						for match in matches
							category = match.match /<a href="[^"]*">([\S\s]*?)<\/a>/
						value.category = category[1]

					@value value