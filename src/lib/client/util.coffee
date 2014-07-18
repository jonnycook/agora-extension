define -> d: [], c: ->
	util = 
	draggingListeners: {}
	nextDraggingListenerId: 1

	terminateDragging: (baseEl) -> 
		baseEl.unbind 'mousedown.dragging'
   
		if baseEl.data 'dragging'
			baseEl.unbind 'mousedown.dragging'
			baseEl.removeData 'dragging'

			if draggingListenerId = baseEl.data 'draggingListenerId'
				delete util.draggingListeners[draggingListenerId]
				baseEl.removeData 'draggingListenerId'

	initDragging: (baseEl, args = {}) ->
		if baseEl.data 'dragging'
			baseEl.unbind 'mousedown.dragging'

		Q(baseEl).data 'dragging', args unless args.affect == false

		if args.onDroppedOn || args.onDragOver || args.onDragOut || args.dragArea || args.root
			Q(baseEl).attr 'dragarea', true

		if args.root
			Q(baseEl).attr 'draggingroot', true

		if !(('acceptsDrop' of args) && args.acceptsDrop == false)
			Q(baseEl).attr 'acceptsdrop', true

		if 'enabled' of args
			if !args.enabled
				return

		if args.onUserStartDrag || args.onUserEndDrag
			draggingListenerId = util.nextDraggingListenerId++
			util.draggingListeners[draggingListenerId] = baseEl:baseEl, args:args
			Q(baseEl).data 'draggingListenerId', draggingListenerId

		Q(baseEl).bind 'mousedown.dragging', (e) ->
			return if args.cancel?()
			selector = '[dragarea]'
			dragging =
				startDrag: (e) ->
					@started = true

					draggingContEl = null
					draggingCont = -> 
						if !draggingContEl
							draggingContEl = $('<div class="-agora -agoraDraggingCont">').css(position:'absolute', left:0, top:0).appendTo document.body
						draggingContEl

					overlay = $('<div />').css(position:'fixed', left:0, right:0, top:0, bottom:0, zIndex:9999999999).appendTo(document.body)		
					offset = x:e.pageX - @el.offset().left, y:e.pageY - @el.offset().top

					if args.helper
						helper = args.helper e, @el, offset
						helper.data 'dragging', args
						helper.appendTo draggingCont()
						@el = helper

					# args.start? e, helper:@el, args:args

					@el.data('dragging').start? e, helper:@el, args:args

					# @el.data 'dragging', args

					el = @el
					if args.context == 'shoppingBar'
						el.addClass 'activeDrag'

					rootEl = if args.context == 'shoppingBar' then baseEl.parents '[draggingroot=true]' else $ '.-agora.v-shoppingBar .content'

					@mousemove = (e) ->
						left = e.pageX - @el.offsetParent().offset().left - offset.x
						top = e.pageY - @el.offsetParent().offset().top - offset.y

						if @state && @state.mousemove(e, left, top) == false
							@state = states.global
							@state.init()
							@el.css zIndex:99999999
							# dragging.fromEl.data('dragging').onRippedOut? el
							el.data('dragging').onGlobal?()
							@state.mousemove e, left, top

						if !@state
							left = e.pageX - @el.offsetParent().offset().left - offset.x
							top = e.pageY - @el.offsetParent().offset().top - offset.y

							@el.css
								left:left
								top:top

					@mouseup = (e) ->
						@el.removeClass 'activeDrag' if args.context == 'shoppingBar'
						@state?.mouseup? e
						overlay?.remove()

						setTimeout (-> draggingContEl.remove() if draggingContEl), 1000

					states = 
						list: (->
							containerEl = el.parents('.element').first()
							if containerEl.length == 0
								containerEl = rootEl

							contentEl = containerEl.data('dragging')?.contentEl ? containerEl

							elements = contentEl.children '.element'

							removed = false

							direction = 'ltr'#containerEl.data('dragging').direction ? 'ltr'

							for i in [0...elements.length]
								if elements.get(i) == el.get(0)
									currentIndex = startIndex = i
									break

							count = elements.length

							el.css
								position:'absolute'

							elementAtIndex = (index) ->
								if removed
									if index >= startIndex
										$ elements.get index + 1
									else
										$ elements.get index
								else
									if index == currentIndex
										el
									else
										resolvedIndex = index
										if index > currentIndex
											resolvedIndex--

										if resolvedIndex >= startIndex
											resolvedIndex++

										$ elements.get resolvedIndex

							indexForSegment = (start, end) ->
								x = 0
								for i in [0...count] 
									width = elementAtIndex(i).data('view').width()

									if i != currentIndex
										if start < x + width/2 && end > x + width/2
											return i

									x += width + contentEl.data('spacing')

								currentIndex

							posForIndex = (index) ->
								if index == 0
									0
								else
									pos = 0
									for i in [0...index]
										pos += elementAtIndex(i).data('view').width() + contentEl.data('spacing')
									pos

							updatePos = (el, i) ->
								if direction == 'ltr'
									el.stop(true, true).animate left:posForIndex(i), 150
								else if direction == 'rtl'
									el.stop(true, true).animate right:posForIndex(i), 150


							mousemove: (e, left, top) ->
								lock = false

								if !lock && (e.pageY - el.offsetParent().offset().top < -35 || e.pageX - (contentEl.offset().left + contentEl.width()) > 100 || contentEl.offset().left - e.pageX > 100)
									if currentIndex != null
										removed = true
										updatePos elementAtIndex(i), i for i in [0...count-1]
										dragging.fromEl = containerEl
									return false

								if direction == 'ltr'
									el.css left:Math.min Math.max(0, left), contentEl.width() - el.width()
								else if direction == 'rtl'
									right = (contentEl.width()) - left
									el.css right:Math.min Math.max(0, right), contentEl.width() - el.width()


								index = indexForSegment left, left + el.width()

								if index != undefined && currentIndex != index
									prevCurrent = currentIndex
									currentIndex = index

									if prevCurrent != null
										updatePos elementAtIndex(prevCurrent), prevCurrent

							mouseup: (e) ->
								updatePos elementAtIndex(i), i for i in [0...count]

								containerEl.data('dragging')?.onReorder? el, startIndex, currentIndex
								el.removeClass 'activeDrag'
								# args.stop? e
								el.data('dragging').stop? e

						)()
						# end list

						global: (->
							skipRoot = false
							rootEls = []
							$('[draggingroot]').each ->
								rootEls.push @
							rootEls.sort (a, b) -> ($(b).data('dragging').rootZIndex ? 0) - ($(a).data('dragging').rootZIndex ? 0)


							activeEl = null
							dropAction = 'default'
							bundleActionTimer = null

							highlightEl = (el) -> if el.data('dragging')?.highlightEl then el.data('dragging').highlightEl else el

							setActiveEl = (el) ->
								return if activeEl && el && el.get(0) == activeEl.get(0)
								dragOutList = []
								dragOverList = []

								if activeEl
									highlightEl(activeEl).removeClass 'activeDrop'
									curEl = activeEl
									loop
										if !curEl.data('dragging')
											console.debug curEl
										# curEl.data('dragging')?.onDragOut?()
										dragOutList.push curEl.data('dragging') if curEl.data('dragging')
										curEl = curEl.parents(selector).first()
										break unless curEl.length

									activeEl.data('dragging')?.onInactive?()

								activeEl = el

								# args.onDraggedOver? activeEl, dragging.el
								# console.debug dragging.el.data('dragging')
								dragging.el.data('dragging').onDraggedOver? activeEl, dragging.el if dragging.el.data('dragging')

								if activeEl
									activeEl.data('dragging').onActive?()
									els = []
									els.push activeEl.get 0 
									activeEl.parents(selector).each -> els.push @
									for i in [els.length-1..0]
										curEl = $ els[i]
										dragOverList.push curEl.data('dragging')
										break if curEl.data('dragging')?.immutableContents && !dragging.el.data('dragging').breaksImmutability

									# activeEl = curEl

									highlightEl(activeEl).addClass 'activeDrop'

								for data in dragOutList
									unless _.contains dragOverList, data
										data.onDragOut?()

								for data in dragOverList
									unless _.contains dragOutList, data
										data.onDragOver?()

							deeper = (e) ->
								sel = selector

								if activeEl.data('dragging').immutableContents && !dragging.el.data('dragging').breaksImmutability
									sel += '[breaksimmutability]'
								
								children = (activeEl.data('dragging').contentEl ? activeEl).children sel

								if children.length > 0
									for i in [0..children.length - 1]
										continue if el.get(0) == children.get(i)
										childEl = $(children.get(i))
										childOffset = childEl.offset()
										if e.pageX > childOffset.left && e.pageY > childOffset.top && e.pageX < childOffset.left + childEl.outerWidth() && e.pageY < childOffset.top + childEl.outerHeight()
											setActiveEl childEl
											return true
								false

							drill = (e, el) ->
								sel = selector

								if el.data('dragging').immutableContents && !dragging.el.data('dragging').breaksImmutability
									sel += '[breaksimmutability]'
								
								children = (el.data('dragging').contentEl ? el).children sel

								if children.length > 0
									for i in [0..children.length - 1]
										continue if el.get(0) == children.get(i)
										childEl = $(children.get(i))
										childOffset = childEl.offset()
										if e.pageX > childOffset.left && e.pageY > childOffset.top && e.pageX < childOffset.left + childEl.outerWidth() && e.pageY < childOffset.top + childEl.outerHeight()
											return drill e, childEl
								el

							shallower = (e) ->
								contOffset = activeEl.offset()

								while !(e.pageX > contOffset.left && e.pageY > contOffset.top && e.pageX < contOffset.left + activeEl.outerWidth() && e.pageY < contOffset.top + activeEl.outerHeight())
									parentEl = activeEl.parents(selector).first()
									if parentEl.length
										setActiveEl parentEl
										contOffset = activeEl.offset()
									else
										setActiveEl null
										break

							init: ->
								el.appendTo draggingCont()
								@start()

							start: ->
								setActiveEl null
								dragging.fromEl = baseEl.parents(selector).first() if args.context != 'page' && !dragging.fromEl
								for id,listener of util.draggingListeners
									listener.args.onUserStartDrag?()

							mousemove: (e, left, top) ->
								clearTimeout bundleActionTimer if bundleActionTimer
								el.css left:left, top:top

								hoverEl = null
								for rootEl in rootEls
									contentEl = $ rootEl
									contOffset = contentEl.offset()
									if e.pageX > contOffset.left && e.pageY > contOffset.top && e.pageX < contOffset.left + contentEl.outerWidth() && e.pageY < contOffset.top + contentEl.outerHeight()
										# setActiveEl contentEl
										# if skipRoot
										# deeper e

										hoverEl = drill e, contentEl
										break

								setActiveEl hoverEl

								if activeEl
									bundleActionTimer = setTimeout (->
										activeEl.data('dragging').onHoldOver? el
									), activeEl.data('dragging').holdDelay ? 500

								return



								if activeEl
									frameEl = highlightEl activeEl
									contOffset = frameEl.offset()

									if !(e.pageX > contOffset.left && e.pageY > contOffset.top && e.pageX < contOffset.left + frameEl.outerWidth() && e.pageY < contOffset.top + frameEl.outerHeight())
										shallower e
									else
										loop
											break unless deeper e

										bundleActionTimer = setTimeout (->
											# highlightEl(activeEl).addClass 'createBundle'
											# dropAction = 'createBundle'
											activeEl.data('dragging').onHoldOver? el
										), activeEl.data('dragging').holdDelay ? 500
								else
									for rootEl in rootEls
										contentEl = $ rootEl
										contOffset = contentEl.offset()
										if e.pageX > contOffset.left && e.pageY > contOffset.top && e.pageX < contOffset.left + contentEl.outerWidth() && e.pageY < contOffset.top + contentEl.outerHeight()
											setActiveEl contentEl
											if skipRoot
												deeper e
											break

							mouseup: (e) ->
								clearTimeout bundleActionTimer if bundleActionTimer

								for id,listener of util.draggingListeners
									listener.args.onUserEndDrag?()

								receivingEl = null
								if activeEl
									receivingEl = unless activeEl.attr 'acceptsdrop'
										activeEl.parents('[acceptsdrop]').first()
									else
										activeEl

								# args.stop? e, helper:dragging.el, receivingEl:receivingEl
								el.data('dragging').stop? e, helper:dragging.el, receivingEl:receivingEl
								el.data('dragging').onDropped? receivingEl

								if receivingEl
									receivingEl.data('dragging')?.onDroppedOn?(el, dragging.fromEl, dropAction)

								else if dragging.fromEl
									if dragging.fromEl.data('dragging')?.onRemove?(el) != false
										el.remove()


								setActiveEl null
								
						)()
						# end global

					if args.context == 'shoppingBar'
						@state = states.list
					else
						@state = states.global

					@state.start?()
					dragging.mousemove e
				# end startDrag
			# end dragging



			dragging.el = if args.context != 'page'
				parents = baseEl.parents(selector)
				el = baseEl
				for i in [parents.length-1..0]
					curEl = $ parents.get i
					if curEl.data('dragging')?.immutableContents
						if curEl.data('dragging').enabled
							el = $ parents.get(i)
						else
							el = null
						break
				el
			else
				baseEl

			if dragging.el
				$(window).bind 'mousemove.dragging', (e) ->
					e.currentTarget = baseEl
					dragging.startDrag e unless dragging.started
					dragging.mousemove e

				$(window).bind 'mouseup.dragging', (e) ->
					$(window).unbind '.dragging'
					e.currentTarget = baseEl
					dragging.mouseup e if dragging.started
				false
		# end mousedown

	getBarItem: (data, parentView, shoppingBarView, selectMode) ->
		barItemView = parentView.createView 'BarItem', shoppingBarView, selectMode:selectMode
		barItemView.represent data
		barItemView

	isMutable: (el) ->
		parents = el.parents('.element')
		for i in [parents.length-1..0]
			curEl = $ parents.get i
			if curEl.data('dragging')?.immutableContents
				return false
		true

	isFixed: (el) ->
		while el.get(0) != document.body
			if el.css('position') == 'fixed'
				return true
			el = el.offsetParent()

		false


	showPopup: (el, args) ->
		args.close ?= true
		popupEl = timerId = open = null
		shouldClose = true

		cancelClose = ->
			clearTimeout timerId
			shouldClose = false


		initiateClose = (time=500) ->
			time = 500 if !_.isNumber time

			if pinned
				shouldClose = true
			else
				clearTimeout timerId
				timerId = setTimeout close, time

		close = ->
			if popupEl
				args.onClose popupEl
				popupEl = null
				el.unbind('mouseleave', initiateClose).unbind('mouseenter', cancelClose)

		pinned = false

		pin = ->
			cancelClose()
			pinned = true

		unpin = ->
			pinned = false
			if shouldClose
				initiateClose()
				shouldClose = false


		init = -> popupEl.mouseenter(cancelClose).mouseleave(initiateClose) if args.close

		cb = (el) ->
			popupEl = el
			init()

		popupEl = args.createPopup cb, close
		if popupEl
			init()


		if args.close
			el.mouseleave initiateClose
			el.mouseenter cancelClose


		close:close, pin:pin, unpin:unpin, initiateClose:initiateClose, cancelClose:cancelClose

	popupTrigger2: (el, args) ->
		popupEl = timerId = open = null
		shouldClose = false
		closing = false

		cancelClose = ->
			clearTimeout timerId
			shouldClose = false
			closing = false

		cancelOpen = ->
			clearTimeout openTimerId

		initiateClose = ->
			closing = true
			if pinned
				shouldClose = true
			else
				clearTimeout timerId
				if open
					timerId = setTimeout close, args.closeDelay ? 500

		close = (animate=false) ->
			# return if args.stayOpen
			clearTimeout openTimerId
			if popupEl
				args.onClose popupEl, animate
				popupEl = null
				clearInterval closingTimerId
				closing = false
				el.unbind('mouseenter', onEnter).unbind('mouseleave', onLeave) for el in els
			open = false

		pinned = false

		pin = ->
			pinned = true

		unpin = ->
			pinned = false
			if shouldClose
				initiateClose()
				shouldClose = false

		over = 0

		els = []


		onEnter = ->
			$(@).data 'entered', true
			++ over; cancelClose()

		onLeave = ->
			$(@).data 'entered', false

			-- over
			if !open
				cancelOpen()
			else
				if over <= 0 && !closing
					initiateClose()

		addEl = (el) ->
			els.push el
			el.mouseenter(onEnter).mouseleave(onLeave)

		removeEl = (el) ->
			if $(el).data 'entered'
				onLeave()


		closingTimerId = null

		openTimerId = null
		el.bind 'mouseenter.popup', =>
			onEnter()
			openTimerId = setTimeout (=>
				if open
					cancelClose()
				else
					inited = false
					init = ->
						inited = true
						# closingTimerId = setInterval (->
						# 	if over <= 0 && !closing
						# 		initiateClose()
						# ), 50
						addEl popupEl

					cb = (el) ->
						if open
							popupEl = el
							init()
						else
							args.onClose el

					open = true

					e = args.createPopup cb, close, addEl, removeEl
					if !popupEl
						popupEl = e

					if popupEl && !inited
						init()
					else if popupEl == false
						open = false
			), args.delay ? 200

		el.bind 'mouseleave.popup', onLeave

		close:close, pin:pin, unpin:unpin, cancelOpen:cancelOpen, addEl:addEl

	popupTrigger: (el, args) ->
		popupEl = timerId = open = null
		shouldClose = false

		cancelClose = ->
			clearTimeout timerId
			shouldClose = false

		cancelOpen = ->
			clearTimeout timerId

		initiateClose = ->
			if pinned
				shouldClose = true
			else
				clearTimeout timerId
				if open
					timerId = setTimeout close, 500

		close = ->
			clearTimeout timerId
			if popupEl
				args.onClose popupEl
				popupEl = null
			open = false

		pinned = false

		pin = ->
			pinned = true

		unpin = ->
			pinned = false
			if shouldClose
				initiateClose()
				shouldClose = false


		addEl = (el) ->
			el.mouseenter(cancelClose).mouseleave(initiateClose)


		el.bind 'mouseenter.popup', =>
			cancelClose()
			timerId = setTimeout (=>
				if open
					cancelClose()
				else
					init = -> addEl popupEl

					cb = (el) ->
						if open
							popupEl = el
							init()
						else
							args.onClose el

					open = true

					popupEl = args.createPopup cb, close, addEl
					if popupEl
						init()
					else if popupEl == false
						open = false


			), 200

		el.bind 'mouseleave.popup', =>
			initiateClose()

		close:close, pin:pin, unpin:unpin, cancelOpen:cancelOpen



	clearPopupTrigger: (el) ->
		el.unbind '.popup'

	showDialog: (createView, params={}) ->
		_showDialog = ->
			view.close = ->
				view.destruct()
				Frame.close frameEl

			view.sizeChanged = ->
				Frame.positionInCenterOfScreen frameEl

			frameEl = Frame.wrapInFrame view.el, close:-> view.destruct()
			frameEl.appendTo document.body
			Frame.positionInCenterOfScreen frameEl

			Frame.show frameEl

		view = createView (v) ->
			view = v 
			_showDialog()

		if view
			_showDialog()

	styleSelect: (selectEl, opts={}) ->
		autoSize = opts.autoSize ? true
		hasLabel = opts.label ? true

		el = $('<span class="t-select" />').css position:'relative'
		el.addClass opts.class

		updateLabel = ->
			selected = selectEl.children(':selected')
			label = selected.html()
			el.html label

			if hasLabel
				if selected.index() == 0
					el.addClass 'label'
				else
					el.removeClass 'label'
			selectEl.after el


		if autoSize
			sizeCalcEl = $('<div class="-agora t-selectOptions" />').css position:'absolute', visibility:'hidden'
			selectEl.children().each ->		
				$('<div class="t-option" />').css(whiteSpace:'nowrap', fontSize:12).html(@innerHTML).appendTo sizeCalcEl
			sizeCalcEl.appendTo document.body
			width = sizeCalcEl.width()
			sizeCalcEl.remove()
			el.css width:width+15

		selectEl.change ->
			updateLabel()

		el.mousedown ->
			close = ->
				el.animate opacity:1, 100
				optionsEl.fadeOut 100, ->
					optionsEl.remove()

			ignore = true
			setTimeout (-> ignore = false), 500


			optionsEl = $ '<div class="-agora t-selectOptions" />'
			selectEl.children().each ->
				optionEl = $ "<span class='t-option' value='#{@value}'>#{@innerHTML}</span>"
				if @selected
					optionEl.addClass 'selected'
					optionEl.attr 'selected', true
				optionsEl.append optionEl
				optionEl.mousedown (e) -> e.stopPropagation()
				optionEl.mouseup =>
					unless ignore && $(@).prop('selected')
						optionEl.addClass 'selected'
						$(@).prop('selected', true)
						selectEl.trigger 'change'
						updateLabel()
						close()
					ignore = false

			# optionsEl.appendTo document.body
			optionsEl.appendTo el

			optionsEl.mousemove (e) ->
				optionsEl.children().each ->
					offset = $(@).offset()
					if e.pageY > offset.top && e.pageY < offset.top + $(@).outerHeight()
						optionsEl.find('.selected').removeClass 'selected'
						$(@).addClass 'selected'

			optionsEl.css
				position:'absolute'
				width: el.outerWidth()
				zIndex: 9999999999

			optionsEl.css
				left:0
				top:(Math.max 4, el.offset().top - optionsEl.children('.selected').position().top) - el.offset().top

			# el.css opacity:0
			false

		selectEl.css display:'none'
		updateLabel()

	tooltip2: (el, text, opts={}) ->
		opts.type ?= 'text'
		if el.data 'hasTooltip'
			util.clearTooltip el

		frame = null
		timerId = null

		el.data('hasTooltip', true)

		onFrame = null

		count = 0
		shouldOpen = true

		open = false

		closing = false

		closingTimerId = null

		close = ->
			# console.debug 'close'
			clearTimeout timerId
			open = false
			if frame
				# console.debug 'close'
				frame.el.unbind('mouseleave', left).unbind('.mouseenter', entered)
				frame.close()
				# frame = null
				opts.onClose?()
				count = 0
				closing = false
				clearInterval closingTimerId
			else
				shouldOpen = false


		entered = ->
			# if open
				++ count
				# if count > 2
					# count = 2 
					# console.error 'fak'
				cancelClose()
				# console.debug 'entered', count

		left = ->
			# if open = false

			-- count
				# if count <= 0
				# 	initiateClose()
				# console.debug 'left', count

			if !open
				clearTimeout timerId

		# if opts.canFocus
		closeTimer = null
		initiateClose = ->
			# console.debug 'initiateClose', frame
			closing = true
			if frame
				closeTimer = setTimeout close, if opts.canFocus then 200 else 0
			else
				shouldOpen = false
				clearTimeout timerId

		cancelClose = -> clearTimeout closeTimer; closing = false

		addEl = (el) -> el.mouseleave(left).mouseenter(entered)

		if opts.canFocus
			onFrame = -> addEl frame.el


		el.bind 'mouseenter.tooltip', ->
			document.body.addEventListener 'click', (->close(); document.body.removeEventListener 'click', arguments.callee, true), true

			if !frame
				shouldOpen = true

				timerId = setTimeout (->
					return unless el.get(0).parentNode && shouldOpen && !opts.cancel?()

					contentEl = if opts.type == 'text'
						document.createTextNode(if typeof text == 'function' then text() else text)
					else if opts.type == 'html'
						$ text

					view = null
					onClose = ->
						frame = null
						view?.destruct()

					if opts.parentView
						view = opts.parentView.createView()


					opts.init? contentEl, close, view
					frame = Frame.frameAround opts.anchor ? el, contentEl, _.extend _.clone(opts), type:opts.frameType ? 'tooltip', onClose:onClose
					frame.el.addClass opts.class if opts.class
					onFrame?()
					open = true

					closingTimerId = setInterval (->
						if !count && !closing
							initiateClose()
					), 50

					if view
						view.useEl frame.el

					# $(window).one 'click', -> console.debug 'asdf';close()
				), opts.delay ? 500




		addEl el
		addEl opts.anchor if opts.anchor


		# else
		# 	el.mouseleave close
		# 	el.mousedown close

	tooltip: (el, text, opts={}) ->
		opts.type ?= 'text'
		if el.data 'hasTooltip'
			util.clearTooltip el

		frame = null
		timerId = null

		el.data('hasTooltip', true)

		onFrame = null

		count = 0
		shouldOpen = true

		open = false

		close = ->
			# console.debug 'close'
			clearTimeout timerId
			open = false
			if frame
				# console.debug 'close'
				frame.el.unbind('mouseleave', left).unbind('.mouseenter', entered)
				frame.close()
				# frame = null
				opts.onClose?()
				count = 0
			else
				shouldOpen = false


		entered = ->
			# if open
				++ count
				# if count > 2
					# count = 2 
					# console.error 'fak'
				cancelClose()
				# console.debug 'entered', count

		left = ->
			# if open = false
				-- count
				if count <= 0
					initiateClose()
				# console.debug 'left', count

		# if opts.canFocus
		closeTimer = null
		initiateClose = ->
			# console.debug 'initiateClose', frame
			if frame
				closeTimer = setTimeout close, if opts.canFocus then 200 else 0
			else
				shouldOpen = false
				clearTimeout timerId

		cancelClose = -> clearTimeout closeTimer

		addEl = (el) -> el.mouseleave(left).mouseenter(entered)

		if opts.canFocus
			onFrame = -> addEl frame.el


		el.bind 'mouseenter.tooltip', ->
			document.body.addEventListener 'click', (->close(); document.body.removeEventListener 'click', arguments.callee, true), true

			if !frame
				shouldOpen = true

				timerId = setTimeout (->
					return unless el.get(0).parentNode && shouldOpen && !opts.cancel?()

					contentEl = if opts.type == 'text'
						document.createTextNode(if typeof text == 'function' then text() else text)
					else if opts.type == 'html'
						$ text

					view = null
					onClose = ->
						frame = null
						view?.destruct()

					if opts.parentView
						view = opts.parentView.createView()


					opts.init? contentEl, close, view
					frame = Frame.frameAround opts.anchor ? el, contentEl, _.extend _.clone(opts), type:opts.frameType ? 'tooltip', onClose:onClose
					frame.el.addClass opts.class if opts.class
					onFrame?()
					open = true

					if view
						view.useEl frame.el

					# $(window).one 'click', -> console.debug 'asdf';close()
				), 500




		addEl el
		addEl opts.anchor if opts.anchor


		# else
		# 	el.mouseleave close
		# 	el.mousedown close




	clearTooltip: (el) ->
		if el.data 'hasTooltip'
			el.removeData 'hasTooltip'
			el.unbind '.tooltip'


	resolveDraggingData: (el, cb) ->
		elData = if el.data('dragging').data 
			el.data('dragging').data
		else 
			view: el.data('view').id
			
		if typeof elData == 'function'
			elData (data) =>
				cb data
		else
			cb elData


	emotionClass: (positive, negative) ->
		if positive && negative
			'mixed'
		else if positive
			if positive > 1
				'veryPositive'
			else
				'positive'
		else if negative
			if negative > 1
				'veryNegative'
			else
				'negative'
		else
			'neutral'

	positionClass: (pro, against) ->
		if pro
			return 'for'
		else if against
			return 'against'

	openProductPreview: (productData, fromView=null) ->
		productPreviewView = new ProductPreviewView contentScript
		if fromView
			productPreviewView.basePath = fromView.path() 
			fromView.event 'openProductPreview'
		productPreviewView.represent productData
		tracking.page productPreviewView.path()

		productPreviewView.close = ->
			Frame.close frameEl

		frameEl = Frame.wrapInFrame productPreviewView.el,
			type: 'fullscreen'
			resize: (width, height) ->
				[width - 20, height - 20]
			close: -> productPreviewView.destruct()
		frameEl.children('.close').css top:15

		frameEl.appendTo document.body
		# Frame.positionInCenterOfScreen frameEl
		# frameEl.css(opacity:0).animate opacity:1, 200
		Frame.show frameEl
		productPreviewView.shown()


	trapScrolling: (el) ->
		el.bind 'DOMMouseScroll mousewheel', (ev) ->
			$this = $(this);
			scrollTop = this.scrollTop;
			scrollHeight = this.scrollHeight;
			height = $this.height();
			delta = (if ev.type == 'DOMMouseScroll' then ev.originalEvent.detail * -40 else ev.originalEvent.wheelDelta);
			up = delta > 0;

			prevent = ->
				ev.stopPropagation();
				ev.preventDefault();
				ev.returnValue = false;
				return false;
			

			if (!up && -delta > scrollHeight - height - scrollTop)
				$this.scrollTop(scrollHeight);
				return prevent();

			else if (up && delta > scrollTop)
				$this.scrollTop(0);
				return prevent();

	createPopout: (anchorEl, opts={}) ->
		opts.anchor ?= 'bottom'
		opts.flexibleHeight ?= true
		if !_.isFunction opts.el
			opts.el.hide()

		init = (el, remove=true) ->
			el.css 'position', 'absolute'

			side = opts.side

			anchorEl.append connectorEl = $('<div class="popoutConnector" />').css('position', 'absolute').addClass side

			switch opts.anchor
				when 'top'
					el.css
						top:-9

				when 'bottom'
					el.css
						bottom:-9

				when 'middle'
					el.css top:-el.outerHeight()/2 + anchorEl.height()/2

			updateSide = ->
				switch side
					when 'left'
						el.css right:anchorEl.outerWidth() + 3 + (opts.distance ? 0)
						connectorEl.css marginLeft:-(opts.distance ? 0)

					when 'right'
						el.css left:anchorEl.outerWidth() + 3 + (opts.distance ? 0)
						connectorEl.css marginRight:-(opts.distance ? 0)

			updatePos = ->
				updateSide()
				if side == 'left'
					if el.offset().left < 0
						connectorEl.removeClass('left').addClass 'right'
						side = 'right'
						updateSide()
				else if side == 'right'
					if el.offset().left + el.width() > $(window).width()
						connectorEl.removeClass('right').addClass 'left'
						side = 'left'
						updateSide()

				switch opts.anchor
					when 'top', 'middle'
						if el.offset().top < $(window).scrollTop() + 10
							el.css top:($(window).scrollTop() + 10) - anchorEl.offset().top

						if el.offset().top + el.outerHeight() > $(window).scrollTop() + $(window).height() - 10
							el.css top:$(window).scrollTop() + $(window).height() - 10 - el.outerHeight() - anchorEl.offset().top

						if opts.flexibleHeight && el.offset().top < $(window).scrollTop() + 10
							height = $(window).height() - 20
							el.css height:height, top:$(window).scrollTop() + 10 - anchorEl.offset().top

					when 'bottom'
						if el.offset().top - $(window).scrollTop() < 10
							el.css bottom:(anchorEl.offset().top + anchorEl.height() - $(window).scrollTop()) - el.outerHeight() - 10
						if el.offset().top - $(window).scrollTop() + el.outerHeight() > $(window).height() - 42
							el.css height:$(window).height() - 66 - 20
							el.css bottom:(anchorEl.offset().top + anchorEl.height() - $(window).scrollTop()) - el.outerHeight() - 10


	

			updatePos()

			close = ->
				opts.onClose?()
				onClose?()
				if remove
					el.remove()
				else
					el.hide()
				anchorEl.removeClass 'active'
				connectorEl.remove()

			# anchorEl.one 'mouseleave', close

			anchorEl.removeClass('hover').addClass 'active'
			updatePos:updatePos, close:close

		if _.isFunction opts.el
			opts.el (el, onClose) ->
				el.appendTo anchorEl
				init el, true
				
		else
			remove = false
			if !opts.el.parent().length
				opts.el.appendTo anchorEl
				remove = true
			opts.el.show()
			init opts.el, remove


	popoutTrigger: (triggerEl, opts={}) ->
		opts.anchor ?= 'bottom'
		if !_.isFunction opts.el
			opts.el.hide()

		pinned = shouldClose = false

		opened = false

		pin = ->
			pinned = true

		unpin = ->
			pinned = false
			if shouldClose
				close()
				shouldClose = false

		closeTimerId = null

		close = initiateClose = null

		triggerEl.mouseenter =>
			if opened
				triggerEl.one 'mouseleave', initiateClose
				clearTimeout closeTimerId
				return
			triggerEl.addClass 'hover'

			openTimerId = setTimeout (=>
				init = (el, remove=true) ->
					opened = true
					switch opts.side
						when 'left'
							el.addClass('left popout').css
								position:'absolute'
								right:triggerEl.outerWidth() + 3
						when 'right'
							el.addClass('right popout').css
								position:'absolute'
								left:triggerEl.outerWidth() + 3

					switch opts.anchor
						when 'top'
							el.css
								top:0

						when 'bottom'
							el.css
								bottom:-9

					triggerEl.append connectorEl = $('<div class="popoutConnector" />').addClass opts.side

					updatePos = ->
						switch opts.anchor
							when 'top'
								if el.offset().top + el.outerHeight() > $(window).scrollTop() + $(window).height() - 42
									el.css top:$(window).scrollTop() + $(window).height() - 66 - 10 - el.outerHeight() - triggerEl.offset().top

								if el.offset().top < $(window).scrollTop() + 10
									height = $(window).height() - 66 - 20
									el.css height:height, top:$(window).scrollTop() + 10 - triggerEl.offset().top

								# if el.offset().top - $(window).scrollTop() < 10
								# 	el.css top:(triggerEl.offset().top + triggerEl.height() - $(window).scrollTop()) - el.outerHeight() - 10
								# if el.offset().top - $(window).scrollTop() + el.outerHeight() > $(window).height() - 42
								# 	el.css height:$(window).height() - 66 - 20
								# 	el.css top:(triggerEl.offset().top + triggerEl.height() - $(window).scrollTop()) - el.outerHeight() - 10
							when 'bottom'
								if el.offset().top - $(window).scrollTop() < 10
									el.css bottom:(triggerEl.offset().top + triggerEl.height() - $(window).scrollTop()) - el.outerHeight() - 10
								if el.offset().top - $(window).scrollTop() + el.outerHeight() > $(window).height() - 42
									el.css height:$(window).height() - 66 - 20
									el.css bottom:(triggerEl.offset().top + triggerEl.height() - $(window).scrollTop()) - el.outerHeight() - 10

					updatePos()

					close = ->
						if pinned
							shouldClose = true
						else
							onClose?()
							if remove
								el.fadeOut 200, -> el.remove(); triggerEl.removeClass 'active'
							else
								el.fadeOut 200, -> triggerEl.removeClass 'active'
							
							connectorEl.fadeOut 200, -> connectorEl.remove()
							opened = false

					initiateClose = ->
						closeTimerId = setTimeout close, 200

					triggerEl.one 'mouseleave', initiateClose

					triggerEl.removeClass('hover').addClass 'active'
					[updatePos, close]

				if _.isFunction opts.el
					opts.el ((el, onClose) ->
						el.css 'position', 'absolute'
						el.appendTo triggerEl
						init el), pin:pin, unpin:unpin

						
				else
					opts.el.show()
					init opts.el, false

			), 200
			triggerEl.one 'mouseleave', -> clearTimeout openTimerId; triggerEl.removeClass 'hover'

			pin:pin, unpin:unpin


	observeOffers: (view, el, data) ->
		offers = data
		el.html '<span class="current offer"><span class="price" /><span class="icon" /></span>'

		updateCurrent = ->
			current = offers.current.get()

			util.tooltip el.find('.current .icon').css('backgroundImage', "url(#{current.siteIcon})"), current.siteName
			el.find('.current .price').html current.price

			if current.cheaper
				el.find('.current').addClass 'cheaper'
			else
				el.find('.current').removeClass 'cheaper'

		updateAlternative = =>
			alternative = offers.alternative.get()
			el.find('.alternative').remove()				

			if alternative
				el.append '<span class="alternative offer"><span class="price" /><span class="icon" /></span>'
				if alternative.cheaper
					el.find('.alternative').addClass 'cheaper'

				util.tooltip el.find('.alternative .icon').css('backgroundImage', "url(#{alternative.siteIcon})"), alternative.siteName
				el.find('.alternative .price').html alternative.price

		updateCurrent()
		offers.current.observe updateCurrent

		updateAlternative()
		offers.alternative.observe updateAlternative


	scrollbar: (wrapper, opts={}) ->
		if window.navigator.appVersion.indexOf('Windows') != -1
			setTimeout (=>
				wrapper.css overflow:'hidden'
				# el.customScrollBar 'destroy'
				# el.customScrollBar theme:'lionbars'
				# wrapper.lionbars useVScroll:false

				# wrapper.addClass('antiscroll-inner').addClass('antiscroll-wrap')
				# el.addClass 'antiscroll-inner'
				w = $('<div />').css(width:'100%', height:'100%').addClass 'antiscroll-inner'
				w.append wrapper.children()
				wrapper.append w
				wrapper.antiscroll useVScroll:false
				util.trapScrolling w if opts.trapScrolling
			), 0
		else
			if opts.trapScrolling
				util.trapScrolling wrapper

	initScrollbar: (el, opts={}) ->
		opts.trapScrolling ?= true
		opts.absolute ?= true
		el.addClass 'scroll'
		wrapper = $('<div class="scrollWrapper" />')#.css position:'absolute', left:0, right:0, top:0, bottom:0
		wrapper.append el.children()
		wrapper.appendTo el
		wrapper.css 'padding', el.css 'padding'

		util.trapScrolling wrapper if opts.trapScrolling

		# el.css 'overflow', 'hidden'




		if !opts.absolute
			el.css 'position', 'relative' if el.css('position') == 'static'
			wrapper.css
				position:'static'
				# height: el.css 'height'
				maxHeight: el.css 'maxHeight'

		if window.navigator.appVersion.indexOf('Windows') != -1
			wrapper.addClass 'hasScrollBars'
			bars = []

			if el.hasClass 'vertical'
				do ->
					thumbEl = $ '<div class="scrollThumb vertical" />'
					thumbEl.appendTo el
					update = ->
						thumbEl.height Math.max 30, wrapper.height()/wrapper.get(0).scrollHeight * wrapper.height()
						thumbEl.css 'top', (wrapper.scrollTop()/(wrapper.get(0).scrollHeight - wrapper.height())) * (wrapper.height() - thumbEl.height())

					bars.push el:thumbEl, update:update

			if el.hasClass 'horizontal'
				do ->
					thumbEl = $ '<div class="scrollThumb horizontal" />'
					thumbEl.appendTo el
					update = ->
						thumbEl.width Math.max 30, wrapper.width()/wrapper.get(0).scrollWidth * wrapper.width()
						thumbEl.css 'left', (wrapper.scrollLeft()/(wrapper.get(0).scrollWidth - wrapper.width())) * (wrapper.width() - thumbEl.width())

					bars.push el:thumbEl, update:update


			scrolling = false
			timerId = null
			wrapper.scroll ->
				bar.update() for bar in bars
				clearTimeout timerId
				timerId = setTimeout (-> el.removeClass 'scrolling'; scrolling = false), 1000
				if !scrolling
					el.addClass 'scrolling'
					scrolling = true

			setTimeout (->bar.update() for bar in bars), 50

			el.addClass 'scrolling'
			setTimeout (-> el.removeClass 'scrolling'), 2000

		# Q.setInterval update, 50



	draggableImage: (args) ->
		util.initDragging args.el,
			acceptsDrop: false
			affect:false
			context: 'page'
			cancel: args.cancel
			helper: (event) ->
				$ '<div class="-agora -agora-productClip t-item dragging" style="position:absolute">
						<span class="p-image"></span>
						<div class="g-productInfo">
							<span class="p-title">loading...</span>
							<span class="p-site">loading...</span>
							<span class="p-price">loading...</span>
						</div>
					</div>'
				
			start: (event, ui) =>
				args.onStart?()
				shoppingBarView.startDrag()

				# args.view.event 'dragProduct'
				target = $ event.currentTarget
				# target.css opacity:.25

				width = target.width()
				height = target.height()

				image = ui.helper.find '.p-image'
				image.css
					backgroundImage:"url('#{if args.image then args.image() else args.el.attr('src')}')"
					width:width
					height:height

				title = ui.helper.find '.p-title'
				site = ui.helper.find '.p-site'
				price = ui.helper.find '.p-price'
				
				view = new View args.view.contentScript
				view.type = 'ProductClip'
				view.onData = (data) ->
					title.html data.title.get() if data.title.get()
					view.observe data.title, (mutation) -> title.html mutation.value
					
					site.html data.site.get() if data.site.get()
					view.observe data.site, (mutation) -> site.html mutation.value

					price.html data.price.get() if data.price.get()
					view.observe data.price, (mutation) -> price.html mutation.value
				
				ui.helper.data('dragging').data = args.productData()

				# marginLeft = if target.css('marginLeft') then parseInt target.css('marginLeft') else 0
				# marginTop = if target.css('marginTop') then parseInt target.css('marginTop') else 0
				
				marginLeft = 0
				marginTop = 0

				offsetX = event.pageX - target.offset().left + marginLeft
				offsetY = event.pageY - target.offset().top + marginTop

				# offsetX = 0
				# offsetY = 0
				
				ui.helper.css
					marginLeft:marginLeft
					width:width
					height:height
					zIndex:999999
					
				ui.helper.find('.g-productInfo').css opacity:0

				size = width:48, height:48
				clip = ->
					time = 200
					curve = null
	
					ui.helper.animate
						marginLeft:offsetX - size.width*.9#event.offsetX/target.width()*size.width
						marginTop:offsetY - size.height*.9#event.offsetY/target.height()*size.height
						width:148
						height:size.height
						time
						curve
						
					image.animate width:44, height:44, time, curve
					
					setTimeout (->
						ui.helper.find('.g-productInfo').animate opacity:1, time, curve unless itemState
					), time

				itemState = false
				item = ->
					itemState = true
					time = 300
					image.animate width:44, height:44, time
					ui.helper.find('.g-productInfo').stop(true).animate opacity:0, time, ->
					ui.helper.stop(true).animate width:size.width, height:size.height, marginLeft:offsetX - size.width/2, marginTop:offsetY - size.height/2, time
				
				view.represent args.productData()

				ui.args.onDraggedOver = (el) ->
					if el
						clearTimeout clipTimerId
						unless itemState
							item()
						ui.helper.addClass 'adding'
						# ui.helper.removeClass 'removing'
					else
						# ui.helper.addClass 'removing'
						ui.helper.removeClass 'adding'

				ui.args.stop = (event, ui) ->
					shoppingBarView.startDrag()

					view.destruct()
					# target.animate opacity:1, 'linear'
					ui.helper.animate
						marginLeft: offsetX
						marginTop: offsetY
						width: 10
						height: 10
						opacity: 0
						100
						'linear'
						-> ui.helper.remove()

				clipTimerId = setTimeout clip, 100

	initMosaic: (view, el, selector, dataSource) ->
		contents = view.listInterface el, selector, (el, data, pos, onRemove) =>
			if data
				el.css 'background-image', "url('#{data}')"
			el
		contents.setDataSource dataSource

		prevLength = contents.length()
		classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
		updateForLength = =>
			el.removeClass classesForLength[prevLength]
			el.addClass classesForLength[prevLength = contents.length()]

		contents.onLengthChanged = updateForLength
		updateForLength()


	decisionPreview: (args) ->
		updateTooltip = =>
			text = if args.descriptor.get()?.descriptor
				args.descriptor.get()?.descriptor
			else 
				'<i>Edit Decision</i>'

			util.tooltip2 args.anchorEl(), "
				<span class='descriptorTooltip'>
					<span class='preview'><span class='image' /></span>
					<div class='descriptorWrapper'><span class='icon' /> <span class='descriptor'>#{text}</span><a class='edit' href='#' /></div>
				</span>
			",
				parentView:args.view
				canFocus:true
				type:'html'
				anchor:args.el if args.selection.length()
				distance:20
				frameType:'balloon'
				delay:300
				cancel: => window.suppressPopups || args.view.shoppingBarView.disableProductPopups
				init: (el, close, view) =>
					args.view.shoppingBarView.propOpen view
					args.view.shoppingBarView.disableProductPopups = true
					icons.setIcon el.find('.icon'), args.icon.get() ? 'list', size:'small'
					el.find('.icon').removeClass 't-item'
					# util.tooltip el.find('.edit'), 'edit'
					edit = =>
						editDescriptorView = args.view.createView 'EditDescriptor'
						args.view.shoppingBarView.propOpen editDescriptorView
						editDescriptorView._mouseenter true
						editDescriptorView.close = -> frame.close()
						editDescriptorView.represent args.view.data.get().id
						frame = Frame.frameAround args.el, editDescriptorView.el, type:'balloon', distance:20, close: -> frame.close(); editDescriptorView.destruct()
						tracking.page "#{args.view.path()}/#{editDescriptorView.pathElement()}"
						false
					el.find('.edit').click edit

					openCompareView = =>
						tracking.page "#{args.view.path()}/DecisionPreview/Compare"
						compareTileView = new CompareView args.view.contentScript
						compareTileView.shoppingBarView = args.view.shoppingBarView
						frameEl = Frame.wrapInFrame compareTileView.el,
							type:'fullscreen'
							scroll:true
							resize: (width, height) -> [width - 100, height - 100]
							close: -> compareTileView.destruct()

							
						compareTileView.close = -> Frame.close frameEl

						frameEl.appendTo document.body
						Frame.show frameEl

						compareTileView.setContEl frameEl.data('client')
						compareTileView.backEl = compareTileView.contEl
						compareTileView.el.css margin:'20px auto 0'

						compareTileView.represent decision:id:args.view.data.get().id
						# tracking.page "#{@path()}/Compare"
						# @event 'openWorkspace'

					el.find('.descriptor').click edit
					el.find('.preview').click openCompareView


					contents = view.listInterface el.find('.preview'), '.image', (el, data, pos, onRemove) =>
						el.css 'background-image', "url('#{data}')"
					contents.setDataSource args.preview

					prevLength = contents.length()
					classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
					updateForLength = =>
						el.find('.preview').removeClass classesForLength[prevLength]
						el.find('.preview').addClass classesForLength[prevLength = contents.length()]

					contents.onLengthChanged = updateForLength
					updateForLength()


					_tutorial ['AccessWorkspace', 'AccessEditDescriptor'], [el.find('.preview'),el.find('.descriptor')]


				onClose: =>
					delete args.view.shoppingBarView.disableProductPopups
			# else
			# 	util.clearTooltip @el.find('.count')

		args.descriptor.observe updateTooltip
		args.selection.observe updateTooltip
		updateTooltip()

	presentViewAsModalDialog: (type, args, params={}) ->
		if params.waitUntilRepresented
			view = View.createView type
			view.represent args, ->
				util.showDialog -> view
		else
			util.showDialog ->
				view = View.createView type
				view.represent args
				view

	positioned: (el) ->
		if el.css("position") isnt "static" or el.get(0) is document.body
			return el

		else
			parents = el.parents()
			i = 0

			while i < parents.length
				parent = $(parents.get(i))
				if parent.css("position") isnt "static" or parent.get(0) is document.body
					# parent.css "position", "relative"  if parent.css("position") is "static"
					return parent
					break
				++i
