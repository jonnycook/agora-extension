require ['Agora', 'ChromeBackground'], (Agora, ChromeBackground) ->
	window.agora = agora = new Agora new ChromeBackground,
		localTest:true
		autoUpdate:false
		client:false
	console.debug 'go!'

props = ['title', 'price', 'image', 'rating', 'ratingCount', 'more', 'reviews']
# props = ['price']

scrapeProduct = (site, sid, json=false) ->
	agora.Site.site(site).productScraper agora.background, sid, (scraper) ->
		scraper.scrape props, (properties) ->
			console.debug if json then JSON.stringify properties else properties

images = (siteName, id) ->
	site = agora.Site.site(siteName)
	product = agora.modelManager.getModel('Product').getBySid siteName, id
	site.product agora.background, product, (siteProduct) ->
		siteProduct.images (images, currentStyle) ->
			console.debug images, currentStyle



scrapeTestProducts = (siteName, json=false) ->
	$.get "http://ext.agora.sh/ext/getTestProducts.php?site=#{siteName}", (response) ->
		products = JSON.parse response
		console.debug products
		testProducts = products[siteName] ? {}

		site = agora.Site.site(siteName)
		site.productScraperClass agora.background, (scraperClass) ->
			count = 0
			products = {}
			for sid,_ of testProducts
				++ count
				do (sid) ->
					scraper = new scraperClass site, sid, agora.background
					scraper.scrape props, (properties) ->
						-- count
						products[sid] = properties

						if !count
							console.debug if json then JSON.stringify products else products

testScraper = (siteName) ->
	$.get "http://ext.agora.sh/ext/getTestProducts.php?site=#{siteName}", (response) ->
		products = JSON.parse response
		testProducts = products[siteName] ? {}

		site = agora.Site.site(siteName)
		site.productScraperClass agora.background, (scraperClass) ->

			skips = {}
			if scraperClass.testing?.skipTest
				for prop in scraperClass.testing.skipTest
					parts = prop.split '.'
					skips[parts[0]] = parts.slice 1

			count = 0
			products = {}
			for sid,correctProperties of testProducts
				++ count
				do (sid, correctProperties) ->
					correctProperties = JSON.parse correctProperties
					scraper = new scraperClass site, sid, agora.background
					scraper.scrape props, (properties) ->
						failed = 0
						for name,value of correctProperties
							continue if name in ['rating', 'ratingCount', 'reviews']

							if s = skips[name]
								if !s.length
									continue
								delete value[s[0]]
								delete properties[name][s[0]]


							if JSON.stringify(value) != JSON.stringify properties[name]
								++ failed
								console.debug "mismatched #{sid} #{name} actual:#{JSON.stringify properties[name]} correct:#{JSON.stringify(value)} "
								console.debug properties[name], value

						if !failed
							console.debug "passed #{sid}"

uploadTestProduct = (site, sid) ->
	agora.Site.site(site).productScraper agora.background, sid, (scraper) ->
		scraper.scrape props, (properties) ->
			$.post 'http://ext.agora.sh/ext/uploadTestProduct.php', data:JSON.stringify(properties), site:site, sid:sid, ->
				console.debug 'done'


$ ->
	$('<input type="text" name="site" value="Uniqlo" />').appendTo 'body'
	siteName = -> $('[name=site]').val()
	$('<button>Scrape Test Products</button>').appendTo('body').click -> scrapeTestProducts siteName(), true
	$('<button>Test Scraper</button>').appendTo('body').click -> testScraper siteName()