define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class EbaySiteInjector extends SiteInjector
		siteName: 'Ebay'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				window.initProducts = initProducts = =>
					for img in $('a img')
						src = $(img).attr 'src'
						if /^http:\/\/thumbs\d*.ebaystatic\.com/.exec(src) || /^http:\/\/i\.ebayimg\.com/.exec src
							a = $(img).parents 'a'
							href = a.prop 'href'

							matches = /http:\/\/www\.ebay\.com\/itm\/[^\/]+\/(\d+)/.exec href
							if matches
								@initProductEl img, productSid:matches[1]
							else
								matches = /http:\/\/www\.ebay\.com\/itm\/ws\/eBayISAPI\.dll\?ViewItem&item=(\d+)/.exec href
								if matches
									@initProductEl img, productSid:matches[1]
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000


				if $('#Body').attr('itemtype') == 'http://schema.org/Product'
					@waitFor '#icImg', (el) =>
						@initProductEl el, productSid:$('#vi-accrd-itm-det-hldr').text().match(/Item number:(\d+)/)[1]
