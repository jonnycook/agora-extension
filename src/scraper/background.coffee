require ['Agora', '../scraper/ScraperBackground'], (Agora, ScraperBackground) ->
	window.background = background = new ScraperBackground client:false
	window.agora = agora = new Agora background,
		localTest:true
		autoUpdate:env.autoUpdate
		client:false
		onLoaded: ->
			# scrapeProduct 'AmericanApparel', 'rsac339-lamefuchsia'

# props = ['title', 'price', 'image', 'rating', 'ratingCount', 'more', 'reviews']
props = ['price']


scrapeProduct = (site, sid, json=false) ->
	lastProduct = site:site, sid:sid
	agora.Site.site(site).productScraper agora.background, sid, (scraper) ->
		scraper.scrape props, (properties) ->
			for name,value of properties
				console.log "#{name} = #{value}"


scrapeProducts = (cb, products) ->
	for product in products
		do (product) ->
			agora.Site.site(product.siteName).productScraper agora.background, product.productSid, (scraper) ->
				scraper.scrape ['price'], (properties) ->
					background.httpRequest cb,
						method:'post'
						data:
							product:product
							prices:
								listing:properties.price*100
						cb: (response) ->
							console.log response
