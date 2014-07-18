fs = require 'fs'

console.log process.argv

siteName = process.argv[2]

dir = "src/lib/sites/#{siteName}"
fs.mkdirSync dir

fs.writeFileSync "#{dir}/research", ''


lcSiteName = siteName.toLowerCase()
fs.writeFileSync "#{dir}/config.coffee", """
excludedFeatures: ['offers', 'deals', 'reviews', 'rating']
hasProductClass:true
slug: '#{lcSiteName}'
hosts: ['www.#{lcSiteName}.com']
currency: 'dollar'
scraper:true
hasMore:false
icon: 'http://www.#{lcSiteName}.com/favicon.ico'
""".trim()

fs.writeFileSync "#{dir}/#{siteName}Product.coffee", """
define ['scraping/SiteProduct', 'util', 'underscore'], (SiteProduct, util, _) ->
	class #{siteName}Product extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = []
				cb {'':images}, ''
""".trim()

fs.writeFileSync "#{dir}/#{siteName}ProductScraper.coffee", (switch process.argv[3]
	when 'normal'
		"""
define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) ->

	class #{siteName}ProductScraper extends ProductScraper
		parseSid: (sid) -> {}

		resources:
			productPage:
				url: -> \"\"

		properties:
			title:
				resource: 'productPage'
				scraper: 
			# price:
			# 	resource: 'productPage'
			# 	scraper: 
			# image:
			# 	resource: 'productPage'
			# 	scraper: 
			# rating: 
			# 	resource: 'productPage'
			# 	scraper:
			# ratingCount: 
			# 	resource: 'productPage'
			# 	scraper: 
			# more:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->
			# 		more = @declarativeScraper 'scraper', 'more'

			# 		@value more
			# reviews:
			# 	resource: 'productPage'
			# 	scraper: ScriptedResourceScraper ->
					
"""
	when 'declarative'
		"""
define ['scraping/ProductScraper'], (ProductScraper) ->
	ProductScraper.declarativeProductScraper 'scraper',
		resources:
			productPage:
				url: -> \"\"
		scraper: 'scraper'
		resource: 'productPage'
""").trim()


fs.writeFileSync "#{dir}/#{siteName}SiteInjector.coffee", """
define -> d: ['DataDrivenSiteInjector'], c: ->
	class #{siteName}SiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a img'
			productSid: (href, a, img) ->

		productPage:
			test: -> false
			productSid: -> 0
			imgEl: ''
""".trim()
