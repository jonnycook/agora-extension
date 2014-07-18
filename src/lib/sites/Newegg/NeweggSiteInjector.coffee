define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class NeweggSiteInjector extends SiteInjector
		siteName: 'Newegg'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				parseSid = (href) ->
					matches = /^http:\/\/www\.newegg\.com\/Product\/Product\.aspx\?Item=(.*)$/.exec href
					if matches
						matches[1]

				window.initProducts = initProducts = =>
					for img in $('a img')
						a = $(img).parents 'a'
						if a.attr('href') && a.attr('href')[0] != '#'
							href = a.prop 'href'
							sid = parseSid href

							if sid
								@initProductEl img, {productSid:sid}, initOverlay: (overlay) -> overlay.autoFixPosition()
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000

				# $ =>
				# 	if $('meta[name="twitter:card"]').attr('value') == 'Product'
				# 		currentSid = -> $('meta[itemprop="productID"]').attr 'content'
				# 		console.debug $('#imageZoomer')
				# 		@initProductEl $('#imageZoomer'), productSid:currentSid(),
				# 			initOverlay: (overlay) ->
				# 				overlay.addAlwaysShow 'productPage'
				# 				overlay.autoFixPosition()
				# 				overlay.el.css 'zIndex', 100000
