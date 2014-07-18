define -> -> 
	positionForAboveCentered = (p, sateliteEl, contEl) ->
		margin = 10
		distance = sateliteEl.data('args')?.distance ? 10

		top = if sateliteEl.data('args')?.position == 'below'
			p.top + distance
		else
			p.top - sateliteEl.height() - distance

		left: Math.max margin, Math.min(p.left - sateliteEl.width()/2, contEl.width()-sateliteEl.width() - margin)
		top: top

	center = (el, frameEl) ->
		top = if frameEl.data('args')?.position == 'below'
			el.offset().top + el.height()
		else
			el.offset().top

		left:el.offset().left + el.outerWidth()/2
		top:top

	relativeToScreen = (position) ->
		left: position.left
		top: position.top - window.scrollY
		
	positioned = (pos, position = 'absolute') ->
		position: position
		left: pos.left
		top: pos.top
		
	class Frame2
		@center: center
		@wrapInFrame: (el, args = {}) ->
			args.type ?= 'hover'
			frameEl = null

			close = ->
				Frame2.close frameEl

			switch args.type
				when 'ds'
					pos = args.pos ? 'top'
					frameEl = $(
						"<table class='-agora v-frame #{pos}'>
							<tr><td class='tl'></td><td class='t'></td><td class='tr'></td></tr>
							<tr><td class='l'></td><td class='c'><div class='client'></div></td><td class='r'></td></tr>
							<tr><td class='bl'></td><td class='b'></td><td class='br'></td></tr>
						</table>"
					)
				when 'hover'
					frameEl = $(
						"<div class='-agora v-frame'>
							<div class='client' />
						</div>"
					)
				when 'balloon'
					frameEl = $(
						'<div class="-agora v-frame">
							<span class="-string" />
							<div class="client" />
						</div>'
					)
					if args.color == 'dark'
						frameEl.addClass 'dark'
				when 'tooltip'
					frameEl = $(
						'<div class="-agora v-frame">
							<span class="-arrow" />
							<div class="client" />
						</div>'
					)
				when 'fullscreen'
					frameEl = $(
						"<div class='-agora v-frame'>
							<div class='client' />
						</div>"
					).scroll (e) -> e.stopPropagation()

					# frameEl.click close
					# el.click (e) -> e.stopPropagation()

			frameEl.addClass args.type

			frameEl.data 'args', args

			if args.close
				frameEl.append $('<a href="#" class="close" />').click ->
					close()
					false

				util.tooltip frameEl.find('.close'), 'close'


			clientEl = frameEl.find('.client')
			if args.scroll
				clientEl.css overflow:'auto'

			frameEl.data 'client', clientEl

			clientEl.width args.width if args.width
			clientEl.height args.height if args.height

			clientEl.append(el).end()

			frameEl

		@updatePositionClass: (frameEl) ->
			frameEl.removeClass frameEl.data('position') if frameEl.data('position')
			frameEl.addClass frameEl.data('args').position

			frameEl.data 'position', frameEl.data('args').position


		@fixFrameAt: (position, frameEl, contEl=$ window) ->
			@updatePositionClass frameEl
			frameEl.css position:'absolute'
			frameEl.css positioned(relativeToScreen(positionForAboveCentered(position, frameEl, contEl)), 'fixed')

			if frameEl.hasClass 'ds'
				p = Math.max(15, Math.min(position.left - frameEl.offset().left, frameEl.width() - 15))
				w = 634
				aw = 8
				bp = (w - aw)/2 + p
				
				frameEl.find('.b').css backgroundPosition:"#{bp}px 0"

			else if frameEl.hasClass('balloon')
				p = Math.max(15, Math.min(position.left - frameEl.offset().left, frameEl.width() - 15))
				# w = 14
				# aw = 14
				# bp = (w - aw)/2 + p
				
				frameEl.find('.-string').css left:p
			else if frameEl.hasClass('tooltip')
				p = Math.max(2, Math.min(position.left - frameEl.offset().left, frameEl.width() - 2))
				w = 14
				aw = 14
				bp = (w - aw)/2 + p
				
				frameEl.find('.-arrow').css left:p


		@positionFrameAboveAndCentered: (anchorEl, frameEl, contEl=$ window) ->
			@updatePositionClass frameEl

			frameEl.css position:'absolute'
			frameEl.css positioned(positionForAboveCentered(center(anchorEl, frameEl), frameEl, contEl))
			
			if frameEl.hasClass 'ds'
				p = (anchorEl.offset().left + anchorEl.outerWidth()/2) - frameEl.offset().left
				w = 634
				aw = 8
				bp = (w - aw)/2 + p
				
				frameEl.find('.b').css backgroundPosition:"#{bp}px 0"
			else if frameEl.hasClass('balloon')
				p = Math.max(2, Math.min((anchorEl.offset().left + anchorEl.outerWidth()/2) - frameEl.offset().left, frameEl.width() - 2))
				# w = 14
				# aw = 14
				# bp = (w - aw)/2 + p
				
				frameEl.find('.-string').css left:p

			else if frameEl.hasClass('tooltip')
				p = Math.max(2, Math.min((anchorEl.offset().left + anchorEl.outerWidth()/2) - frameEl.offset().left, frameEl.width() - 2))
				
				frameEl.find('.-arrow').css left:p

		@fixFrameAboveAndCentered: (anchorEl, frameEl, contEl=null) ->
			@fixFrameAt center(anchorEl, frameEl), frameEl, contEl

		@setFrameAboveAndCentered: (anchorEl, frameEl, contEl=null) ->
			el = anchorEl
			while el.get(0) != document.body
				if el.css('position') == 'fixed'
					@fixFrameAboveAndCentered anchorEl, frameEl, contEl
					return
				el = el.offsetParent()

			@positionFrameAboveAndCentered anchorEl, frameEl, contEl

		@fixAtEl: (anchorEl, frameEl) ->
			@fixFrameAt center(anchorEl), frameEl, $(window)

		@positionInCenterOfScreen: (frameEl) ->
			frameEl.css
				position: 'absolute'

			resize = ->
				if frameEl.data('args').resize
					[width, height] = frameEl.data('args').resize? $(window).width(), $(window).height()
					frameEl.data('client').width(width).height(height).triggerHandler 'resize'
				frameEl.css
					left: ($(window).width() - frameEl.width())/2
					top: ($(window).height() - frameEl.height())/2 + scrollY
				true

			resizeTimerId = null
			$(window).resize ->
				if frameEl.parent().get(0)
					clearTimeout resizeTimerId
					resizeTimerId = setTimeout resize, 10
				else
					$(window).unbind 'resize', arguments.callee

			resize()
			setTimeout resize, 10

		@close: (frameEl, animate=true) ->
			return unless $.contains(document, frameEl.get(0)) 
			if frameEl.data('args').type == 'fullscreen'
				$(document.body).removeClass '-agora-modelOpen'
				# $(document.body).children(':not(.-agora)').css '-webkit-filter', ''
				$('.-agora-fullscreenOverlay').remove()
				delete @currentFullscreenFrameEl


			# console.debug 'frame closing'
			frameEl.unbind()

			if animate
				frameEl.fadeOut 200, ->
					frameEl.data('args')?.onClose?()
					frameEl.data('args')?.close?()
					frameEl.remove()
					# console.debug 'frame closed'
			else
				frameEl.data('args')?.onClose?()
				frameEl.data('args')?.close?()
				frameEl.remove()

		@show: (frameEl) ->
			if frameEl.data('args').type == 'fullscreen'
				if @currentFullscreenFrameEl
					@close @currentFullscreenFrameEl
				@currentFullscreenFrameEl = frameEl
				resize = ->
					frameEl.data('client').triggerHandler 'resize'
					true

				resizeTimerId = null
				Q(window).resize ->
					if frameEl.parent().get(0)
						clearTimeout resizeTimerId
						resizeTimerId = setTimeout resize, 10
					else
						$(window).unbind 'resize', arguments.callee

				resize()

				Q(document.body).addClass '-agora-modelOpen'
				# $(document.body).children(':not(.-agora)').css '-webkit-filter', 'blur(10px)'

			frameEl.css(opacity:0).animate(opacity:1, 100)

		@frame: (el, args=null) ->
			frame = new Frame2
			frame.args = args ? {}
			frame.el = Frame2.wrapInFrame el, frame.args
			frame.el.data 'frame', frame
			frame

		@frameFixedAbove: (anchorEl, el, args=null) ->
			frame = Frame2.frame el, args
			frame.showFixedAbove anchorEl
			frame

		@showPositionedAbove: (anchorEl, el, args=null) ->
			frame = Frame2.frame el, args
			frame.showPositionedAbove anchorEl
			frame

		@frameAbove: (anchorEl, el, args=null) ->
			frame = Frame2.frame el, args
			if args?.parent
				frame.el.appendTo args.parent
			frame.showAbove anchorEl
			frame

		@frameAround: (anchorEl, el, args=null) ->
			frame = Frame2.frame el, args
			frame.showAround anchorEl
			frame


		shown: -> @el.parent().length
		showFixedAbove: (el) ->
			@el.appendTo document.body unless @shown()
			@update = => Frame2.fixFrameAboveAndCentered el, @el
			@update()
			Frame2.show @el

		showPositionedAbove: (el) ->
			@el.appendTo document.body unless @shown()
			Frame2.positionFrameAboveAndCentered el, @el
			Frame2.show @el

		showAbove: (el) ->
			@el.appendTo document.body unless @shown()
			@update = => Frame2.setFrameAboveAndCentered el, @el
			@update()
			Frame2.show @el

		showAround: (el) ->
			@args.position ?= 'above'
			@showAbove el

			if @args.position == 'above'
				if @el.offset().top < $(window).scrollTop()
					@args.position = 'below'
					@showAbove el			

			# else if @args.position == 'below'
			# 	if @el.offset().top + @el.height() > $('body').height()
			# 		@args.position = 'above'

		show: ->
			@el.appendTo document.body unless @shown()
			Frame2.show @el

		close: (animate=true) ->
			Frame2.close @el, animate

