define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class KohlsSiteInjector extends SiteInjector
		siteName: 'Kohls'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				initProduct = (el, sid) =>
					@initProductEl el, productSid:sid, false

				window.initProducts = initProducts = =>
					for img in $('a img[src^="http://media.kohls.com.edgesuite.net/is/image/kohls/"]')
						src = $(img).attr 'src'
						matches = /http:\/\/media\.kohls\.com\.edgesuite\.net\/is\/image\/kohls\/(\d+)/i.exec(src)
						if matches
							initProduct img, matches[1]
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000
