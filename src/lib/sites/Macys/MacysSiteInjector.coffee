define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class MacysSiteInjector extends SiteInjector
		siteName: 'Macys'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				parseSid = (href) ->
					matches = /^http:\/\/[^.]*\.macys\.com\/shop\/product\/[^?]*\?ID=(\d*)/.exec href
					if matches
						matches[1]

				window.initProducts = initProducts = =>
					for img in $('a img')
						a = $(img).parents 'a'
						if a.attr('href') && a.attr('href')[0] != '#'
							href = a.prop 'href'
							sid = parseSid href
							if sid
								@initProductEl img, productSid:sid
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000

				$ =>
					if $('meta[name="twitter:card"]').attr('value') == 'Product'
						currentSid = -> $('meta[itemprop="productID"]').attr 'content'

						@initProductEl $('#imageZoomer'), productSid:currentSid(),
							initOverlay: (overlay) ->
								overlay.addAlwaysShow 'productPage'
								overlay.autoFixPosition()
								overlay.el.css 'zIndex', 100000
