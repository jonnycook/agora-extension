define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class CVSSiteInjector extends SiteInjector
		siteName: 'CVS'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				#for product images on search pages and other pages
				parseSid = (href) ->
					matches = /^http:\/\/www\.cvs\.com\/shop\/product-detail\/.*?\?skuId=([^&]+)/.exec href
					if matches
						matches[1]

				window.initProducts = initProducts = =>
					for img in $('a img')
						a = $(img).parents 'a'
						if a.attr('href') && a.attr('href')[0] != '#'
							href = a.prop 'href'
							sid = parseSid href

							if sid
								console.log sid, href
								@initProductEl img, productSid:sid
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000

				# for product image on the product page
				$ =>
					if $('.productImgGallery').length
						currentSid = -> /^http:\/\/www\.cvs\.com\/shop\/product-detail\/.*?\?skuId=([^&]+)/.exec(document.location.href)[1]
						@waitFor '.productImage img', => #img tag that is child of #viewL element
							@initProductEl $('.productImage img'), productSid:currentSid()