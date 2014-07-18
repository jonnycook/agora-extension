define -> d: ['View', 'views/ProductPreviewView'], c: ->
	class ProductOverlayView extends View
		type: 'ProductOverlay'
		@clear: (el) ->
			# if el.data('overlay')
				# el.data('overlay').destruct()
			el.parent().find('bdo.-agora.-agora-productBadge').remove()

		constructor: (contentScript, productData, imgEl, opts={}) ->
			super
			imgEl = $ imgEl

			positionEl = attachEl = null
			
			if opts.positionEl && opts.attachEl
				positionEl = opts.positionEl
				attachEl = opts.attachEl

			else
				positionEl = imgEl
				attachEl = imgEl.parent()
			@showPreview = true

			{hovering:hovering, extra:extraOverlayElements, position:position} = opts

			positionStyle = null
			badgeEl = null
			# imgEl = @
			
			productPreviewView = null
			frameEl = null


			offsetParentEl = null


			if attachEl.css("position") isnt "static" or attachEl.get(0) is document.body
				offsetParentEl = attachEl

			else
				parents = attachEl.parents()
				i = 0

				while i < parents.length
					parent = $(parents.get(i))
					if parent.css("position") isnt "static" or parent.get(0) is document.body
						# parent.css "position", "relative"  if parent.css("position") is "static"
						offsetParentEl = parent
						break
					++i

			@el = badgeEl = $ '<bdo class="-agora -agora-productBadge" />'
			badgeEl.click =>
				popup.close()
				popup.cancelOpen()
				frameEl = util.openProductPreview productData, @
				tracking.page '/ProductOveray/ProductPortal'
				tracking.event 'ProductOverlay', 'click'
				false

			Q(attachEl).data 'overlay', @

			# positionStyle = parentEl.css 'position'
			# if positionStyle == 'static'
			# 	parentEl.css 'position', 'relative'
			Q(attachEl).append badgeEl


			badgeEl.css
				position: 'absolute'

			@updatePosition = updatePosition = =>
				margin = positionEl.width()*.05

				left = positionEl.offset().left - offsetParentEl.offset().left
				top = positionEl.offset().top - offsetParentEl.offset().top
				if position == 'topRight'
					badgeEl.css
						left: (left + positionEl.width()) - badgeEl.width() - margin
						top: top + margin
				if position == 'topLeft'
					badgeEl.css
						left: left + margin
						top: top + margin

			badgeEl.css(opacity:0)

			updatePosition()

			@test = =>
				if !badgeEl.parents('body').length
					@destruct()
					false
				true

			@showBadge = =>
				return unless @test()
				unless @showing
					# console.debug 'showing ', badgeEl
					updatePosition()
					badgeEl.stop().css(opacity:0).animate opacity:1, 200
					@showing = true

			@hideBadge = =>
				return unless @test()
				@showing = false
				badgeEl.stop().animate opacity:0, 200, =>
					# badgeEl.remove()
					# attachEl.css 'position', positionStyle
			

			count = 0

			up = =>
				if !count
					show()
				++ count
				# console.debug 'up', count


			down = =>
				if count > 0
					-- count
					if !count
						hide()
					# console.debug 'down', count


			# imgEl.mouseover -> console.debug attachEl


			if hovering
				count++

			if hovering
				@showBadge()
				@active = true

			hideTimer = null
			initiateHide = =>
				clearTimeout hideTimer
				hideTimer = setTimeout hide, 10

			cancelHide = =>
				clearTimeout hideTimer

			hide = =>
				@active = false
				unless @_alwaysShow
					@hideBadge()

			show = =>
				# if @active
					# cancelHide()
				# else
					@showBadge()
					@active = true

			Q(attachEl).mouseenter up
			Q(attachEl).mouseleave down

			@onDestruct = ->
				attachEl.unbind('mouseenter', up).unbind('mouseleave', down)
				@el.remove()
				attachEl.removeData 'overlay'

			if extraOverlayElements
				for el in extraOverlayElements
					Q(el).mouseenter(up).mouseleave(down)

			popup = util.popupTrigger2 @el,
				delay:500
				createPopup: (cb, close, addEl) =>
					return false if !Agora.settings.showPreview.get() || !@showPreview
					productPopupView = @createView 'ProductPopupView', unconstrainedPictureHeight:true

					productPopupView.represent @args, =>
						frame = Frame.frameAbove @el, productPopupView.el, type:'balloon', position:(if @el.offset().top - $(window).scrollTop() < ($(window).height())/3 then 'below' else 'above'), onClose: ->
							productPopupView.destruct()
							productPopupView = null
						# frame.el.css marginTop:-17
						productPopupView.close = close
						productPopupView.sizeChanged = ->
							frame.update()
						productPopupView.addEl = addEl

						frame.el.mouseenter cancelHide

						up()
						tracking.event 'popup', 'appear', 'ProductPopup'
						tracking.page "#{@path()}/#{productPopupView.pathElement()}"

						cb frame.el
					null
				onClose: (el, animate) =>
					el.data('frame')?.close? animate
					# initiateHide()# unless @active
					down()


		autoFixPosition: ->
			setInterval (=> @updatePosition()), 1000

		alwaysShow: (alwaysShow) ->
			if alwaysShow != @_alwaysShow
				@_alwaysShow = alwaysShow

				if alwaysShow
					if !@showing
						@showBadge()
				else
					unless @active
						@hideBadge()


		addAlwaysShow: (reason) ->
			@alwaysShowReasons ?= {}
			@alwaysShowReasons[reason] = true

			if _.keys(@alwaysShowReasons).length
				@alwaysShow true

		removeAlwaysShow: (reason) ->
			@alwaysShowReasons ?= {}
			delete @alwaysShowReasons[reason]

			if !_.keys(@alwaysShowReasons).length
				@alwaysShow false


		onData: (data) ->
			# @el.attr 'productSid', data.productSid
			onProp = (prop, func) ->
				func prop.get()
				prop.observe (mutation) ->
					func prop.get(), mutation

			onProp data.bagged, (bagged) =>
				if bagged
					@el.addClass 'added'
					@addAlwaysShow 'added'
				else
					@el.removeClass 'added'
					@removeAlwaysShow 'added'

			onProp data.status, (status) =>
				if status == 2
					@el.addClass 'error'
				else
					@el.removeClass 'error'


			lastEmotion = null
			updateForLastFeeling = =>
				if lastEmotion
					@el.removeClass lastEmotion

				if data.lastFeeling.get()
					emotionClass = util.emotionClass data.lastFeeling.get().positive, data.lastFeeling.get().negative
					@el.addClass emotionClass
					lastEmotion = emotionClass
					@addAlwaysShow 'emotion'
				else
					lastEmotion = null
					@removeAlwaysShow 'emotion'

			data.lastFeeling.observe updateForLastFeeling
			updateForLastFeeling()


			lastArgument = null
			updateForLastArgument = =>
				if lastArgument
					@el.removeClass lastArgument

				if data.lastArgument.get()
					positionClass = util.positionClass data.lastArgument.get().for, data.lastArgument.get().against
					@el.addClass positionClass
					lastArgument = positionClass
					@addAlwaysShow 'argument'

				else
					lastArgument = null
					@removeAlwaysShow 'argument'


			data.lastArgument.observe updateForLastArgument
			updateForLastArgument()
		destruct: ->
			super
			@onDestruct()
