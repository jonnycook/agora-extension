define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, _) ->

	matchAll = (string, pattern) ->
		matches = string.match new RegExp (if _.isString pattern then pattern else pattern.source), 'g'
		if matches
			for match in matches
				match.match pattern
		else
			[]

	unescape = (string) ->
		map = 
			'&#58;': ':'
			'&#47;': '/'

		for from,to of map

			string = string.replace new RegExp(from, 'g'), to

		string



	class NeweggProductScraper extends ProductScraper
		resources:
			productPage:
				url: -> "http://www.newegg.com/Product/Product.aspx?Item=#{@productSid}"
			detailsPage:
				url: -> "http://www.newegg.com/LandingPage/ItemInfo4ProductDetail2013.aspx?Item=#{@productSid}&v2=2012"
			relationPage:
				url: -> "http://content.newegg.com/Common/Ajax/RelationItemInfo.aspx?item=#{@productSid}&type=Newegg&v2=2012"

		properties:
			title:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/"imageTitle":"([^"]*)/), 1

			price:
				resource: 'detailsPage'
				scraper: ScriptedResourceScraper ->
					matches = @resource.match /"finalPrice":"([^"]*)"/
					if matches
						@value matches[1]
					else
						matches = @resource.match /<li class=\\"price-current \\" itemprop=\\"price\\" content=\\"([^\\]*)\\"/
						@value matches[1]

			image:
				resource: 'productPage'
				scraper: PatternResourceScraper new RegExp(/<img id="mainSlide[^"]*" onload="[^"]*" title="[^"]*" alt="[^"]*" src="([^"]*)/), 1

			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->
			# 		value = {}

			# 		switches = 
			# 			images: true
			# 			shortTitle: true
			# 			details: true
			# 			overview: true
			# 			description: true
			# 			rating: true
			# 			ratingCount: true
			# 			category: true
			# 			brand: true
			# 			returnPolicy: true
			# 			originalPrice: true
			# 			manufacturerWarranty: true
			# 			manufacturerContanctInfo: true
			# 			shipping: true
			# 			warrantyOptions: true
			# 			rebate: true

			# 		if switches.images
			# 			images = []
			# 			matches = @resource.match /"imageType":"([^"]*)"/
			# 			if matches[1] == 'Normal'
			# 				[__, baseUrl] = @resource.match /imgGalleryConfig.BaseUrlForNonS7="([^"]*)";/

			# 				matches = @resource.match /"imageNameList":"([^"]*)"/
			# 				imageMatches = matches[1].split ','
			# 				for image in imageMatches
			# 					images.push "#{baseUrl}#{image}"

			# 			else if matches[1] == 'Scene7'
			# 				[__, baseUrl] = @resource.match /imgGalleryConfig.BaseUrlForS7="([^"]*)";/
			# 				[__, imageFolder] = @resource.match /imgGalleryConfig.ImageFolder="([^"]*)";/

			# 				matches = @resource.match /"imageSetImageList":"([^"]*)"/
			# 				imageMatches = matches[1].split ','
			# 				for image in imageMatches
			# 					images.push "#{baseUrl}#{imageFolder}#{image}?$S640$"

			# 			value.images = images

			# 		if switches.shortTitle
			# 			matches = @resource.match /<span id="DetailShortTitle">([^<]*)/
			# 			if matches
			# 				value.shortTitle = matches[1]

			# 		if switches.details
			# 			details = {}

			# 			[__, detailsMatch] = @resource.match /<div id="Specs" class="[^"]*">([\S\s]*?)<\/div>/
			# 			matches = matchAll detailsMatch, /<fieldset>(.*?)<\/fieldset>/
			# 			for match in matches
			# 				[__, title] = match[1].match /<h3 class="specTitle">([^"]*)<\/h3>/
			# 				details[title] = {}
			# 				entryMatches = matchAll match[1], /<dl><dt>([^<]*)<\/dt><dd>([\S\s]*?)<\/dd><\/dl>/
			# 				for entryMatch in entryMatches
			# 					details[title][entryMatch[1]] = entryMatch[2]

			# 			value.details = details


			# 		if switches.overview
			# 			overview = {}

			# 			matches = @resource.match /<div id="Overview_Content"([\S\s]*?)<\/div>\s*<!-- \/section -->/
			# 			if matches
			# 				overviewContent = matches[1]

			# 				# introduction
			# 				matches = overviewContent.match /<div([\S\s]*?)<span class="clearL"><\/span>/
			# 				if matches
			# 					introduction = []
			# 					matches = matchAll matches[1], /<p>\s*([\S\s]*?)\s*<\/p>/
			# 					for match in matches
			# 						if match[1].indexOf('http://content.webcollage.net/newegg/smart-button') != -1
			# 							overview.hasWebCollage = true
			# 						else if match[1] != '&nbsp;'
			# 							introduction.push match[1]

			# 					overview.introduction = introduction

			# 				# highlights
			# 				matches = overviewContent.match /<ul class="grpFeatures" id="hightlights">([\S\s]*?)<\/ul>/
			# 				if matches
			# 					highlights = []
			# 					matches = matchAll matches[1], /<li>\s*<span class="content">\s*<img src="([^"]*)" alt="newegg"  style="width:75px;"\/>\s*<em class="title">([^<]*)<\/em>\s*([^<]*)\s*<\/span>\s*<\/li>/

			# 					for match in matches
			# 						highlights.push
			# 							image:match[1]
			# 							title:match[2]
			# 							content:match[3].trim()

			# 					overview.highlights = highlights

			# 			value.overview = overview

			# 		if switches.description
			# 			[__, descriptionMatch] = @resource.match /<ul id="grpBullet_([\S\s]*)<\/ul>/
			# 			itemMatches = matchAll descriptionMatch, /<li class="item">\s*([^<]*)<\/li>/
			# 			description = []
			# 			for itemMatch in itemMatches
			# 				description.push itemMatch[1].trim()

			# 			value.description = description

			# 		if switches.rating
			# 			matches = @resource.match /<span itemprop="ratingValue" content="(\d*)"><\/span>/
			# 			if matches
			# 				value.rating = matches[1]

			# 		if switches.ratingCount
			# 			matches = @resource.match /<span itemprop="ratingCount">([^<]*)<\/span>/
			# 			if matches
			# 				value.ratingCount = matches[1]

			# 		if switches.category || switches.brand
			# 			[__, block] = @resource.match /<div id="bcaBreadcrumbTop">([\S\s]*?)<\/div>/
			# 			breadcrumbMatches = matchAll block, /<dd><a href="[^"]*" title="([^"]*)"/

			# 			if switches.category
			# 				category = []
			# 				for breadcrumb in breadcrumbMatches.slice(1, -1)
			# 					category.push breadcrumb[1]
			# 				value.category = category

			# 			# brand
			# 			if switches.brand
			# 				value.brand = name:breadcrumbMatches[breadcrumbMatches.length - 1][1]

			# 		if switches.brand
			# 			matches = @resource.match /<img class="logo" alt="[^"]*" title="[^"]*" src="([^"]*)" \/>/
			# 			if matches
			# 				value.brand.logo = matches[1]


			# 		if switches.returnPolicy
			# 			@execBlock ->
			# 				@getResource 'relationPage', (resource) ->
			# 					matches = resource.match /<h3>Return Policies(.*?)\|/
			# 					if matches
			# 						policy = {}

			# 						policyMatch = matches[1].match /<p>(.*?)<\\\/p>/
			# 						if policyMatch
			# 							if policyMatch[1].indexOf('Newegg.com\'s') != -1
			# 								policy.newegg = true

			# 							policyLinkMatch = policyMatch[1].match /<a href=\\"(.*?)\\" target=\\"_blank\\" title=\\"Return Policy\(new window\)\\">(.*?)<\\\/a>/
			# 							policy.url = policyLinkMatch[1].replace(/\\/g, '')
			# 							policy.name = policyLinkMatch[2]

			# 						detailMatches = matchAll matches[1], /<LI>([^<]*)<\\\/LI>/
			# 						if detailMatches.length
			# 							detailList = _.map detailMatches, (match) -> match[1]
			# 							details = {}
			# 							for detail in detailList
			# 								parts = detail.split(': ')
			# 								details[parts[0]] = parts[1]

			# 							policy.details = details

			# 						value.returnPolicy = policy

			# 					@value value
			# 					@done true
			# 				null

			# 		if switches.originalPrice
			# 			@execBlock ->
			# 				@getResource 'detailsPage', (resource) ->
			# 					matches = resource.match /<li class=\\"price-was \\" >\\u000d\\u000a\\u0009\\u0009\$([^\\]*)\\u000d\\u000a\\u0009<\/li>/
			# 					if matches
			# 						value.originalPrice = matches[1]
			# 						@value value
			# 					@done true
			# 				null

			# 		if switches.manufacturerWarranty
			# 			matches = @resource.match /<div id="MfrWarranty"([\S\s]*?)<\/div>/
			# 			if matches
			# 				manufacturerWarranty = {}
			# 				matches = matchAll matches[1], /<li>([^<]*)<\/li>/
			# 				for match in matches
			# 					parts = match[1].split ':&nbsp;'
			# 					manufacturerWarranty[parts[0]] = parts[1]

			# 				value.manufacturerWarranty = manufacturerWarranty

			# 		if switches.manufacturerContanctInfo
			# 			matches = @resource.match /<div id="MfrContact"([\S\s]*?)<\/div>/
			# 			if matches
			# 				manufacturerContanctInfo = {}
			# 				matches = matchAll matches[1], /<li>([\S\s]*?)<\/li>/
			# 				for match in matches
			# 					item = match[1]
			# 					if !manufacturerContanctInfo.productPage && m = item.match /<a href="([^"]*)" target="_blank" title="Manufacturer Product Page\(new window\)">Manufacturer Product Page<\/a>/
			# 						manufacturerContanctInfo.productPage = unescape m[1]

			# 					if !manufacturerContanctInfo.phone && m = item.match /Support Phone: ([^<]*)/
			# 						manufacturerContanctInfo.phone = m[1]

			# 					if !manufacturerContanctInfo.website && m = item.match /Website: <a href="([^"]*)"/
			# 						manufacturerContanctInfo.website = unescape m[1]

			# 					if !manufacturerContanctInfo.supportWebsite && m = item.match /<a href="([^"]*)" target="_blank" title="Support Website\(new window\)">Support Website<\/a>/
			# 						manufacturerContanctInfo.supportWebsite = unescape m[1]

			# 				value.manufacturerContanctInfo = manufacturerContanctInfo

			# 		# shipping
			# 		if switches.shipping
			# 			@execBlock ->
			# 				@getResource 'detailsPage', (resource) ->
			# 					shipping = null
			# 					if resource.match /<span class=\\"message\\">Free Shipping<\/span>/
			# 						shipping = 'free'
			# 					else
			# 						matches = resource.match /<li class=\\"price-ship\\">\$(\S*) Shipping/
			# 						if matches
			# 							shipping = matches[1]
			# 						else
			# 							shipping = null

			# 					value.shipping = shipping
			# 					@value value
			# 					@done true
			# 				null

			# 		if switches.warrantyOptions
			# 			@execBlock ->
			# 				@getResource 'relationPage', (resource) ->
			# 					matches = resource.match /<li class=\\"nav_(\d*)\\"><a href=\\"javascript:void\(0\);\\" onclick=\\"Biz\.Product\.CrossTable\.switchNav\(this\);\\">Warranties & Services/
			# 					if matches
			# 						warranties = []
			# 						index = matches[1]
			# 						matches = matchAll resource, "<div id=\\\\\"addon#{index}_\\d*\\\\\"(.*?)<script"
									
			# 						for match in matches
			# 							warranty = {}
			# 							warranty.image = match[1].match(/src=\\"([^"]*)/)[1].replace(/\\/g, '')#.substr(0, -1)
			# 							warranty.description = match[1].match(/<span class=\\"descText\\" id=\\"Span2\\">([^<]*)<\\\/span>/)[1]

			# 							warranty.features = _.map matchAll(match[1], /<li>&nbsp;([^<]*)<\\\/li>/), (match) -> match[1]

			# 							priceMatches = match[1].match /\$<strong>(\d*)<\\\/strong><sup>\.(\d*)<\\\/sup>/
			# 							warranty.price = "#{priceMatches[1]}.#{priceMatches[2]}"
										
			# 							warranties.push warranty

			# 						value.warrantyOptions = warranties
			# 						@value value

			# 					@done true
			# 				null


			# 		if switches.rebate
			# 			@execBlock ->
			# 				@getResource 'relationPage', (resource) ->
			# 					matches = resource.match /<div class=\\"priceNoteRebate\\">Receive a \$(\S*) prepaid card by mail from ([^!]*)! Expires on (\S*) <span class=\\"note\\"><a class=\\"atnIcon icnPdf\\" title=\\"Requires Adobe Reader\\" href=\\"([^"]*)">/
			# 					if matches
			# 						value.rebate =
			# 							amount: matches[1]
			# 							issuer: matches[2]
			# 							expires: matches[3].replace /\\/g, ''
			# 							form: matches[4].replace /\\/g, ''

			# 						@value value
			# 					@done true
			# 				null



			# 		@value value

