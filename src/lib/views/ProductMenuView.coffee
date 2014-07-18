define ['View', 'Site', 'Formatter', 'util'], (View, Site, Formatter, util) ->
	class ProductMenuView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (@product) =>
				site = Site.site product._get 'siteName'

				@data =
					features: site.features
					lastFeeling:util.lastFeeling @ctx, product
					lastArgument:util.lastArgument @ctx, product

				done()

		@client: ->
			class ProductMenuView extends View
				type: 'ProductMenu'
				init: (el, opts={}) ->
					@public = opts.public
					@el = el
					html = '
						<div class="item priceComparison"><a href="#">See more prices</a></div>
						<div class="item coupons"><a href="#">See coupons and deals</a></div>
						<div class="item reviews"><a href="#">Reviews</a></div>
						<div class="item watch"><a href="#">Watch</a></div>
							'

					if !@public
							html += '<div class="item feelings"><a href="#">Feelings</a></div>
							<!--<div class="item arguments"><a href="#">Arguments</a></div>-->
							<div class="item attachments"><a href="#">Clipped content</a></div>'

					@el.html html

					@el.addClass 'v-productMenu'

					@orientation = opts.orientation

					if opts.orientation == 'horizontal'
						@el.addClass 'horizontal'

					el = @el

					makePopup = if opts.orientation == 'horizontal'
						num = 0
						(triggerEl, viewName, popupOpts={}) =>
							util.popupTrigger triggerEl,
								createPopup: (cb, close) =>
									view = @createView viewName
									view.represent @args, =>
										view.close = (esc) ->
											# if esc
												# funcs.unpin()
												close()
												console.debug 'poop'
												opts.removeEl? frame.el

										position = if triggerEl.offset().top - $(window).scrollTop() < ($(window).height())/3 then 'below' else 'above'
										# position = 'below'

										updateFrame = ->
											adjust = if util.isFixed(triggerEl) then $(window).scrollTop() else 0

											if position == 'above'
												if frame.el.offset().top < $(window).scrollTop()
													pos = frame.el.offset().top + frame.el.height()
													height = pos - ($(window).scrollTop() + 40)
													frame.el.find('.cont').css height:height

													frame.el.css top:pos - frame.el.height() - adjust
											else if position == 'below'
												if frame.el.offset().top + frame.el.height() > $(window).scrollTop() + $(window).height()
													height = $(window).scrollTop() + $(window).height() - frame.el.offset().top - 40
													frame.el.find('.cont').css height:height


										frame = Frame.frameAbove triggerEl, view.el, type:'balloon', color:'dark', position:position, onClose: ->
											view.destruct()
											view = null
										# frame.el.css marginTop:-17
										# view.close = close

										updateFrame()

										view.sizeChanged = ->
											frame.update()
											updateFrame()
											# frame.update()

										opts.addEl? frame.el
										cb frame.el
										tracking.page view.path()
										view.shown()
										# view.sizeChanged = updatePos
									opts.pinSidebar?()
									triggerEl.addClass 'active'
									num++
									null
								onClose: (el) ->
									opts.removeEl? el
									opts.unpinSidebar?() unless --num
									console.debug 'closed',
									el.data('frame')?.close?()
									triggerEl.removeClass 'active'

					else
						num = 0
						(triggerEl, viewName, popupOpts={}) =>
							util.popoutTrigger triggerEl,
								side:'left'
								anchor:popupOpts.anchor
								el: (cb, funcs) =>
									++ num
									view = @createView viewName
									view.represent @args, =>
										view.close = (esc) ->
											if esc
												funcs.unpin()
												-- num
												if !num
													opts.unpinSidebar?()
												close()

										tracking.page view.path()
										view.shown()

										[updatePos, close] = cb view.el, -> view.destruct()
										view.sizeChanged = updatePos

					makePopup @el.find('.priceComparison'), 'OffersView', anchor:'top'
					makePopup @el.find('.coupons'), 'CouponsView', anchor:'top'
					makePopup @el.find('.reviews'), 'ReviewsView', anchor:'top'
					makePopup @el.find('.watch'), 'ProductWatchView', anchor:'top'

					makePopup @el.find('.feelings'), 'AddFeelingView'
					makePopup @el.find('.arguments'), 'AddArgumentView'
					makePopup @el.find('.attachments'), 'DataView'

				shown: ->
					setTimeout (=>
						size = @el.width()/@el.find('.item').length

						if @orientation == 'horizontal'
							w = 0
							for el in @el.find('.item')
								margin = (size - $(el).width())/2
								w += margin*2 + $(el).width()
								$(el).css marginLeft:margin, marginRight:margin
					), 0
					
				onData: (data) ->
					if !_.contains data.features, 'offers'
						@el.find('.priceComparison').remove()

					if !_.contains data.features, 'deals'
						@el.find('.coupons').remove()

					if !_.contains data.features, 'reviews'
						@el.find('.reviews').remove()

					if !_.contains data.features, 'priceWatch'
						@el.find('.watch').remove()
					
					setTimeout (=>
						size = @el.width()/@el.find('.item').length

						if @orientation == 'horizontal'
							w = 0
							for el in @el.find('.item')
								margin = (size - $(el).width())/2
								w += margin*2 + $(el).width()
								$(el).css marginLeft:margin, marginRight:margin
					), 0
							
					lastEmotion = null
					updateForLastFeeling = =>
						if lastEmotion
							@el.find('.feelings').removeClass lastEmotion

						if data.lastFeeling.get()
							emotionClass = util.emotionClass data.lastFeeling.get().positive, data.lastFeeling.get().negative
							@el.find('.feelings').addClass emotionClass
							lastEmotion = emotionClass
						else
							lastEmotion = null

					data.lastFeeling.observe updateForLastFeeling
					updateForLastFeeling()

					lastArgument = null
					updateForLastArgument = =>
						if lastArgument
							@el.find('.arguments').removeClass lastArgument

						if data.lastArgument.get()
							positionClass = util.positionClass data.lastArgument.get().for, data.lastArgument.get().against
							@el.find('.arguments').addClass positionClass
							lastArgument = positionClass
						else
							lastArgument = null

					data.lastArgument.observe updateForLastArgument
					updateForLastArgument()