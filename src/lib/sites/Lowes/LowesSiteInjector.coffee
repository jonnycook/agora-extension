define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class LowesSiteInjector extends SiteInjector
		siteName: 'Lowes'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				#for product images on search pages and other pages
				parseSid = (href) ->
					matches = /^http:\/\/www\.walgreens\.com\/store\/c\/.*?\/ID=prod([^-]+)/.exec href
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
					if $('#viewL').length
						currentSid = -> /^http:\/\/www\.walgreens\.com\/store\/c\/.*?\/ID=prod([^-]+)/.exec(document.location.href)[1]
						@waitFor '#viewL img', => #img tag that is child of #viewL element
							@initProductEl $('#viewL img'), productSid:currentSid()