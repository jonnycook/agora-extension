define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class TargetSiteInjector extends SiteInjector
		siteName: 'Target'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				initProduct = (el, sid) =>
					@initProductEl el, productSid:sid, false

				window.initProducts = initProducts = =>
					for img in $('img')
						src = $(img).attr 'src'
						matches = /http:\/\/img\d+\.targetimg\d+\.com\/wcsstore\/TargetSAS\/\/?img\/p\/\d+\/\d+\/(\d+)(?:_\d+)?(?:_\d+x\d+)?\.jpg/i.exec(src)
						if matches
							initProduct img, matches[1]
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000
