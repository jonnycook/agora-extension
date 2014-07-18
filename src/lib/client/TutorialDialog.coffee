define -> -> class TutorialDialog 
	constructor: (@steps, @step) ->
		@pointerEl = $ '<div class="-agora tutorialPointer"><span class="frame" /><span class="frameNoArrow" /><span class="logo" /></div>'
		@frameEl = $ '<div class="-agora tutorialDialog">
				<div class="steps" />
				<div class="cont" />
				<div class="audioControls"><a href="#" class="replay" /><a href="#" class="mute" /></div>
			</div>'
		# @frameEl.append content


		if @steps
			for i in [1..steps]
				@frameEl.find('.steps').append $('<span class="step" />')#.addClass (if i <= step then 'filled' else '')


		@frameEl.css position:'absolute'
		@frameEl.appendTo document.body

		@pointerEl.css position:'absolute'
		@pointerEl.appendTo document.body

		@pointerEl.hide()
		@frameEl.hide()

		@distance = 50

		@currentStep = step
		@setMuted = (muted) =>
			@muted = muted
			if @muted
				@frameEl.addClass "muted"
			else
				@frameEl.removeClass "muted"
			@audio.muted = @muted if @audio
			chrome.storage.local.set tutorial:
				muted: @muted

			return

		chrome.storage.local.get "tutorial", (data) =>
			@setMuted data.tutorial.muted  if data.tutorial

		@frameEl.find(".audioControls .mute").click =>
			@setMuted not @muted
			false

		@frameEl.find(".audioControls .replay").click =>
			if @audio
				@audio.currentTime = 0
				@audio.play()
			false


	showCenter: (width, content, cb=null) ->
		@show {left:$(window).width()/2, top:$(window).height()/4, pointer:false, width:width}, 'below', content, cb


	show: (anchorEl, orientation, content, cb=null) ->
		framePos = pointerPos = pointerAngle = null

		@pointerEl.show()
		@frameEl.show()

		anchorPos = anchorWidth = anchorHeight = pointer = null

		audioUrl = undefined
		audioUrl = content.audio  if content.audio
		content = content.text  if content.text
		adjust = 0
		if _.isPlainObject orientation
			adjust = orientation.adjust if 'adjust' of orientation
			orientation = orientation.orientation

		if 'top' of anchorEl && 'left' of anchorEl
			anchorPos = anchorEl
			anchorWidth = anchorHeight = 0
			pointer = anchorEl.pointer ? true
		else
			anchorPos = anchorEl.offset()
			anchorWidth = anchorEl.outerWidth()
			anchorHeight = anchorEl.outerHeight()
			pointer = true


		next = =>
			if anchorEl.top && anchorEl.left
				if anchorEl.width
					@frameEl.css maxWidth:anchorEl.width
				else
					@frameEl.css maxWidth:''
			else
				@frameEl.css maxWidth:''

		calcFramePos = =>
			pos = switch orientation
				when 'left'
					left: anchorPos.left - @frameEl.outerWidth() - @distance
					top: anchorPos.top + anchorHeight/2 - @frameEl.outerHeight()/2
				when 'right'
					left: anchorPos.left + anchorWidth + @distance + (adjust ? 0)
					top: anchorPos.top + anchorHeight/2 - @frameEl.outerHeight()/2
				when 'above'
					left: anchorPos.left + anchorWidth/2 - @frameEl.outerWidth()/2
					top: anchorPos.top - @frameEl.outerHeight() - @distance
				when 'below'
					left: anchorPos.left + anchorWidth/2 - @frameEl.outerWidth()/2
					top: anchorPos.top + anchorHeight + @distance
			pos.left = Math.max 5, Math.min $(window).width() - 5, pos.left
			pos.top = Math.max 0, Math.min $(window).height() + $(window).scrollTop() - @frameEl.outerHeight(), pos.top
			pos


		frameSize = 55
		factor = .57
		switch orientation
			when 'left'
				pointerPos = 
					left: anchorPos.left - frameSize - @distance + frameSize*factor
					top: anchorPos.top + anchorHeight/2 - @pointerEl.outerHeight()/2

				pointerAngle = '90deg'

			when 'right'
				pointerPos = 
					left: anchorPos.left + anchorWidth + @distance - frameSize*factor + (adjust ? 0)
					top: anchorPos.top + anchorHeight/2 - @pointerEl.outerHeight()/2

				if @prevPointerAngle == '-180deg'
					pointerAngle = '-90deg'
				else if @prevPointerAngle == '180deg'
					pointerAngle = '270deg'
				else
					pointerAngle = '-90deg'

			when 'above'
				pointerPos = 
					left: anchorPos.left + anchorWidth/2 - frameSize/2
					top: anchorPos.top - @pointerEl.outerHeight() - @distance + @pointerEl.height()*factor
				
				if @prevOrientation == 'right'
					pointerAngle = '-180deg'
				else
					pointerAngle = '180deg'

			when 'below'
				pointerPos = 
					left: anchorPos.left + anchorWidth/2 - frameSize/2
					top: anchorPos.top + anchorHeight + @distance - @pointerEl.height()*factor

				pointerAngle = '0deg'


		transitionAngle = @prevOrientation != orientation
		@prevOrientation = orientation

		# console.debug @prevPointerAngle, pointerAngle

		@prevPointerAngle = pointerAngle

		updateSteps = =>
			stepWidth = 10
			contWidth = @frameEl.find('.cont').width()
			marginLeft = (contWidth - stepWidth*@steps)/(@steps - 1)

			for el,i in @frameEl.find('.steps .step')
				if i != 0
					$(el).css 'marginLeft', marginLeft

				if i + 1 <= @step
					$(el).addClass 'filled'
			++ @step

		playAudio = =>
			if @audio
				@audio.muted = true  if @muted
				@audio.play()
		@audio.pause()  if @audio
		
		if audioUrl
			@audio = new Audio(audioUrl)
		else
			@audio = null

		if !@shown
			next()
			@shown = true
			@frameEl.find('.cont').append content
			@frameEl.css calcFramePos()
			@pointerEl.css pointerPos
			@prevPointer = pointer
			setTimeout updateSteps, 0

			if pointer
				@pointerEl.find('.frame').css transform:"rotate(#{pointerAngle})"
				@pointerEl.find('.frameNoArrow').hide()
			else
				@pointerEl.find('.frame').hide()
				@pointerEl.find('.frameNoArrow').show()
			playAudio()
			cb?()
		else
			@frameEl.fadeOut =>
				next()
				@frameEl.find('.cont').html('').append content

				@pointerEl.animate pointerPos, =>
					@frameEl.css calcFramePos()
					setTimeout updateSteps, 0
					@frameEl.fadeIn -> playAudio(); cb?()

				if @prevPointer == pointer
					if pointer
						@pointerEl.find('.frame').animate transform:"rotate(#{pointerAngle})" if transitionAngle
				else
					if pointer
						@pointerEl.find('.frame').css(transform:"rotate(#{pointerAngle})").fadeIn()
						@pointerEl.find('.frameNoArrow').fadeOut()
					else
						@pointerEl.find('.frame').fadeOut()
						@pointerEl.find('.frameNoArrow').fadeIn()

				@prevPointer = pointer
	close: ->
		@frameEl.fadeOut()
		if @audio then @audio.pause()
		@pointerEl.fadeOut()
