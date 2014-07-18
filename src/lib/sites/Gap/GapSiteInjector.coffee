define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class GapSiteInjector extends SiteInjector
		siteName: 'Gap'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				window.initProducts = initProducts = =>
					for img in $('a img')
						a = $(img).parents 'a'
						href = a.prop 'href'

						if a.attr('href')[0] != '#' && /^http:\/\/www.gap.com\/browse\/product\.do/.exec href
							matches = /pid=(\d+)/.exec href
							if matches
								@initProductEl img, productSid:matches[1]
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000

				if /^http:\/\/www.gap.com\/browse\/product\.do/.exec document.location.href
					currentSid = -> /pid=(\d+)/.exec(document.location.href)[1]

					$('body').delegate '#dragLayer', 'mouseover', =>
						$('#dragLayer').unbind '.agora'
						down = false
						event = null
						$('#dragLayer')
							.bind 'mousedown.agora', (e) ->
								down = true
								$('html').disableSelection()
								e.preventDefault()
								event = e
								true
							.bind 'mouseup.agora', ->
								down = false
								true
							.bind 'mousemove.agora', (e) =>
								if down
									down = false
									selector = '#product_image'
									# @clearProductEl el for el in $ selector
									# @products $(selector), productSid:currentSid()

									setTimeout (->
										$('#dragLayer').hide()

										$(selector).trigger event
										# $(selector).trigger e

										$('html').one 'mouseup', ->
											$('html').enableSelection()
											$('#dragLayer').show()

									), 100

					@waitFor '#product_image', (el) =>
						@initProductEl el, productSid:currentSid(),
							extraOverlayElements: $('#dragLayer')
							initOverlay: (overlay) ->
								overlay.el.css('z-index', 10000)
