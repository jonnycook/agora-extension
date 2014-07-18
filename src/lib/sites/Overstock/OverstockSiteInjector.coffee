define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class OverstockSiteInjector extends SiteInjector
		siteName: 'Overstock'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				initProduct = (el, sid) =>
					@initProductEl el, productSid:sid

				window.initProducts = initProducts = =>
					for img in $('img[src^="http://ak1.ostkcdn.com/images/products/"]')
						src = $(img).attr 'src'
						matches = /^http:\/\/ak1\.ostkcdn\.com\/images\/products\/(\d+)/.exec(src)
						if matches
							initProduct img, matches[1]
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000
