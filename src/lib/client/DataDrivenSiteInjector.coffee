define -> d: ['SiteInjector'], c: ->
	doHandleOverlay = (overlayEl, image, hide=false) ->
		$(overlayEl).unbind '.agora'
		down = false
		event = null
		Q(overlayEl)
			.bind 'mousedown.agora', (e) ->
				down = true
				Q('html').disableSelection()
				e.preventDefault()
				event = e
				true
			.bind 'mouseup.agora', ->
				down = false
				true
			.bind 'mousemove.agora', (e) ->
				if down
					down = false
					# setTimeout (=>
					Q(@).hide() if hide
					image.trigger event
					setTimeout (=> image.trigger event), 100
					$('html').one 'mouseup', =>
						$('html').enableSelection()
						$(@).show() if hide
					# ), 100

	handleOverlay = (overlayEl, image, hide=false) ->
		Q('body').delegate overlayEl, 'mouseover', ->
			doHandleOverlay overlayEl, image($ @), hide
			# down = false
			# event = null
			# Q(overlayEl)
			# 	.bind 'mousedown.agora', (e) ->
			# 		down = true
			# 		Q('html').disableSelection()
			# 		e.preventDefault()
			# 		event = e
			# 		true
			# 	.bind 'mouseup.agora', ->
			# 		down = false
			# 		true
			# 	.bind 'mousemove.agora', (e) ->
			# 		if down
			# 			down = false
			# 			# setTimeout (=>
			# 			Q(@).hide() if hide
			# 			$(image $ @).trigger event
			# 			setTimeout (=> $(image $ @).trigger event), 100
			# 			$('html').one 'mouseup', =>
			# 				$('html').enableSelection()
			# 				$(@).show() if hide
			# 			# ), 100

	class DataDrivenSiteInjector extends SiteInjector
		@productListing:
			# image: 'a img'
			testProductLink: (a) -> true
			productSid: (href) -> @parseUrl href

			productData: (href, a, img) ->
				productSid = @productListing.productSid.call @, href, a, img
				if productSid
					productSid:productSid


		@productPage:
			productSid: -> throw new Error 'unimplemented'
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			waitFor: 'body'
			imgEl: null
			productSid: (href) -> @parseUrl document.location.href


		constructor: ->
			super
			if !_.isFunction @productListing
				@productListing = _.extend _.clone(DataDrivenSiteInjector.productListing), @productListing
			@productPage = _.extend _.clone(DataDrivenSiteInjector.productPage), @productPage


		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				Q(@shoppingBarView.el).appendTo document.body
				@shoppingBarView.represent()

				
				if _.isFunction @productListing
					@productListing.call @
				else
					@productListing.image ?= @productListing.imgSelector

					@productListing.init.call @ if @productListing.init
					if @productListing.mode == 2
						if @productListing.overlay
							handleOverlay @productListing.overlay, @productListing.overlayImage

						doInitProducts = (selector, params) =>
							for el in $(selector)
								img = if params.image && params.image != selector
									params.image $ el
								else
									el

								a = if params.anchor
									params.anchor $ el
								else
									$(img).parents 'a'

								href = a.prop 'href'

								productData = params.productData.call @, href, a, $(img), $ el

								if productData
									positionEl = if params.positionA
										a
									else if params.position
										params.position $ el
									else
										img

									if params.anchorProxy
										doHandleOverlay a, img

									@initProductEl img, productData, overlay:false

									if params.forcePositioned
										Q(a).css 'position', 'relative'

									@attachOverlay
										positionEl:$ positionEl
										attachEl:a
										productData:productData
										overlayZIndex:9999
										position:params.overlayPosition

						window.initProducts = initProducts = =>
							@productListing.custom?()
							if @productListing.selectors
								for selector, params of @productListing.selectors
									doInitProducts selector, params
							else
								doInitProducts @productListing.image, @productListing

								
						$ initProducts
						Q(window).load initProducts
						Q.setInterval initProducts, 2000

						if @productListing.image
							that = @
							Q('body').delegate @productListing.image, 'mouseenter', ->
								img = @
								a = $(img).parents 'a'
								href = a.prop 'href'
								productData = that.productListing.productData.call that, href, a, $(img)
								if productData
									that.initProductEl @, productData, overlay:false
					else
						window.initProducts = initProducts = =>
							for img in $(@productListing.image)
								a = $(img).parents 'a'
								href = a.prop 'href'

								# if @productListing.testProductLink a, $(img)
								productSid = @productListing.productSid.call @, href, a, $(img)
								if productSid
									if @productListing.container && $(img).parents(@productListing.container).length
										contEl = $(img).parents(@productListing.container)
										@initProductEl contEl, {productSid:productSid}, image:false, overlayZIndex:@productListing.overlayZIndex, overlayPosition:@productListing.overlayPosition
										for imgEl in a.find('img')
											@initProductEl imgEl, {productSid:productSid}, overlay:false
									else
										@initProductEl img, {productSid:productSid}, overlayPosition:@productListing.overlayPosition
								
						$ initProducts
						$(window).load initProducts

						Q.setInterval initProducts, 2000

				$ =>
					if @productPage?.test?()
						console.debug 'product page'
						@productPage.initPage.call @ if @productPage.initPage
						if @productPage.mode == 2
							if @productPage.overlay
								@productPage.hideOverlay ?= true
								overlay = @productPage.overlay
								# console.debug $(overlay)

								# $(overlay).get(0).addEventListener 'onmousemove', (-> console.debug 'asdf'), false

								Q('body').delegate overlay, 'mouseover', =>
									$(overlay).unbind '.agora'
									down = false
									event = null

									Q(overlay)
										.bind 'mousedown.agora', (e) ->
											down = true
											Q('html').disableSelection()
											e.preventDefault()
											event = e
											true
										.bind 'mouseup.agora', ->
											down = false
											true
										.bind 'mousemove.agora', (e) =>
											if down
												down = false
												selector = @productPage.image
												for el in $ selector
													@clearProductEl el
													@initProductEl el, {productSid:@productPage.productSid.call(@), variant:@productPage.variant}, overlay:false

												# @clearProductEl el for el in $ selector
												# @products $(selector), productSid:currentSid()

												setTimeout (=>
													Q(overlay).hide() if @productPage.hideOverlay

													console.debug $(selector)
													$(selector).trigger event
													# $(selector).trigger e

													$('html').one 'mouseup', =>
														$('html').enableSelection()
														$(overlay).show() if @productPage.hideOverlay

												), 100

							if @productPage.image
								that = @
								lastProductSid = null
								Q('body').delegate @productPage.image, 'mouseenter', ->
									img = @
									productSid = that.productPage.productSid.call that
									# if productSid != lastProductSid
									that.clearProductEl @
									that.initProductEl @, {productSid:productSid, variant:that.productPage.variant}, overlay:false

							update = =>
								console.debug @productPage.productSid.call @
								@removeOverlay $(@productPage.attach)
								@attachOverlay
									attachEl: $(@productPage.attach)
									positionEl: $(@productPage.position ?  @productPage.image)
									productData: {productSid:@productPage.productSid.call @}
									overlayZIndex: @productPage.zIndex ? 9999
									init: (overlay) -> overlay.addAlwaysShow 'productPage'

							@waitFor @productPage.attach, =>
								lastProductSid = null
								Q.setInterval (=>
									productSid = @productPage.productSid.call @
									if productSid && productSid != lastProductSid
										lastProductSid = productSid
										update()
										# if productSid != lastProductSid
								), 500
						else
							if @productPage.overlayEl
								overlayEl = @productPage.overlayEl
								# console.debug $(overlayEl)

								# $(overlayEl).get(0).addEventListener 'onmousemove', (-> console.debug 'asdf'), false

								Q('body').delegate overlayEl, 'mouseover', =>
									$(overlayEl).unbind '.agora'
									down = false
									event = null
									Q(overlayEl)
										.bind 'mousedown.agora', (e) ->
											down = true
											Q('html').disableSelection()
											e.preventDefault()
											event = e
											true
										.bind 'mouseup.agora', ->
											down = false
											true
										.bind 'mousemove.agora', (e) =>
											if down
												down = false
												selector = @productPage.imgEl
												# @clearProductEl el for el in $ selector
												# @products $(selector), productSid:currentSid()

												setTimeout (->
													Q(overlayEl).hide()

													$(selector).trigger event
													# $(selector).trigger e

													$('html').one 'mouseup', ->
														$('html').enableSelection()
														$(overlayEl).show()

												), 100


							update = =>
								console.debug @productPage.productSid.call @
								if @productPage.initProduct
									@productPage.initProduct.call @
								else
									el = @productPage.imgEl
									@clearProductEl el
									@initProductEl el, {productSid:@productPage.productSid.call @}, overlayZIndex:@productPage.overlayZIndex ? 1000, initOverlay: (overlay) ->
										overlay.addAlwaysShow 'productPage'
									# extraOverlayElements: $('#dragLayer')
									# initOverlay: (overlay) ->
										# overlay.el.css('z-index', 10000)

							@waitFor @productPage.waitFor ? @productPage.imgEl, =>
								lastProductSid = null
								Q.setInterval (=>
									productSid = @productPage.productSid.call @
									if productSid && productSid != lastProductSid
										lastProductSid = productSid
										update()
								), 1000
