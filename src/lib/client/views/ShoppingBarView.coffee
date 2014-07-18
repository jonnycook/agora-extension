define -> d: ['View', 'util', 'util2'
	'views/ShoppingBarView/BarItemView', 'views/CompetitiveProcessView', 'views/ReviewsView', 'views/AddItemView','views/CouponsView', 'views/AddDescriptorView', 'views/AddDataView', 'views/compare/CompareView', 'views/ContactView', 'views/ShareView', 'views/SharedWithYouView', 'views/CollaborateView', 'views/ChatView', 'devAction', 'views/SocialShareView', 'views/BuyView', 'views/ProductWatchView'], c: ->
	class ShoppingBarView extends View
		type: 'ShoppingBar'
		constructor: (contentScript, @opts={}) ->
			super
			@startTime = new Date().getTime()
			@el = @viewEl '
				<div class="-agora v-shoppingBar style1">
					<div class="actions">
						<span class="count" />
						<a href="#" class="home" />
						<a href="#" class="moveUp">Up</a>
					</div>
					<div class="contentWrapper">
						<div class="content">
							<div class="element" />
							<!--<div class="add" />-->
						</div>
					</div>
					<a href="http://agora.sh/connect.html" target="_blank" class="signIn">Sign In to Agora</a>
					<span class="message" />
					<span class="errorState">!</span>

					<div class="right">
						<span class="collaborate" />
						<span class="bagsby" />
					</div>
					<span class="devAction"><span class="reloadDevAction" /><span class="devAction" /><span class="reloadStyles" /></span>
					<span class="needsReload">To continue to use Agora, please reload this page. Thank you!</span>
				</div>'

			@el.find(".devAction .reloadDevAction").click ->
				devAction.reloadDevAction()


			@el.find(".devAction .devAction").click ->
				devAction.devAction()

			@el.find(".devAction .reloadStyles").click ->
				reloadStyles()


			@itemSpacing = 7
			@sessionSpacing = 7
			@animateSpeed = 0

			@pinCount = 0

			@editListeners = []

			@el.find('.content')
				.data(
					view: @
					spacing: @sessionSpacing
				)

			@el.find('.contentWrapper').data 'view', @

			util.initDragging @el.find('.contentWrapper'),
				enabled:false
				root:true
				rootZIndex:1
				acceptsDrop:true
				dragArea:true
				contentEl: @el.find '.content'
				onRippedOut: =>
					# @updateLayout()
				onReorder: (el, startIndex, endIndex) =>
					tracking.event 'ShoppingBar', 'reorder'
					@callBackgroundMethod 'reorder', [startIndex, endIndex]
				# onRemove: (el) =>
				# 	@callBackgroundMethod 'remove', [{view:el.data('view').id}, {view:@id}]
				onDroppedOn: (el, fromEl) =>
					@onDroppedOn el, fromEl, @el.find('.contentWrapper')
					el.remove();
					false
				data: 'ShoppingBar'

			util.initDragging @el.find('.actions .moveUp'),
				enabled:false
				root:true
				acceptsDrop:true
				dragArea:true
				onDroppedOn: (el, fromEl) =>
					@onDroppedOn el, fromEl, 'up'

			@contents = @listInterface @el, '.element', (el, data, pos, onRemove) =>
				view = util.getBarItem(data, @, @, @selectMode)
				onRemove -> view.destruct()
				view.el

			@contents.onDelete = (el, del) =>
				del()
				@updateLayout()

			@contents.onInsert = (el) =>
				@updateLayout()

			@contents.onMove = => @updateLayout()

			menu = (anchorEl) =>
				=>
					return false if window.suppressShoppingBarMenu
					@updateMenu = update = =>
						if @selectMode
							el.html '
								<div class="group">
									<a href="#" class="wrap"><label>wrap</label></a>
									<a href="#" class="createBundle"><label>bundle</label></a>
									<a href="#" class="delete"><label>delete</label></a>
								</div>
								<div class="group">
									<a href="#" class="cancel"><label>cancel select</label></a>
								</div>
							'
							if @atRoot
								el.find('.group:first').prepend '
									<a href="#" class="createSession"><label>create session</label></a>'
								el.find('.createSession').click =>
									@wrapSelection 'session'
									false
							else
								el.find('.group:first').prepend '
									<a href="#" class="extract"><label>extract</label></a>
									<a href="#" class="split"><label>split</label></a>
								'

								el.find('.extract').click =>
									@extractSelection()
									false

								el.find('.split').click =>
									@splitSelection()
									false

							el.find('.cancel').click =>
								@event 'cancelSelect'
								@unpinMenu()
								@disableSelection()
								update()
								frame.update()
								false

							el.find('.createBundle').click =>
								@wrapSelection 'bundle'
								false

							el.find('.wrap').click =>
								@wrapSelection 'decision'
								false

							el.find('.delete').click =>
								@deleteSelection()
								false

						else
							el.html '
								<div class="group">
									<a href="#" class="settings"><label>settings</label></a>
									<a href="#" class="contact"><label>contact</label></a>
									<a href="#" class="sharedWithYou"><span class="count" /><label>shared with you</label></a>
								</div>
								<div class="group actions">
									<a href="#" class="collaborate"><label>collaborate</label></a>
									<a href="#" class="selectMode"><label>selection mode</label></a>
								</div>
							'

							if @data.unseenSharedObjectsCount.get()
								el.find('.sharedWithYou .count').addClass('nonzero').html @data.unseenSharedObjectsCount.get()


							if @atRoot
								el.find('.group:first')
									.append '<a href="http://agora.sh/supportedSites.html" target="_blank" class="supportedSites"><label>supported sites</label></a>'
									.append '<a href="http://support.agora.sh/knowledgebase" target="_blank" class="manual"><label>manual</label></a>'

							# unless @atRoot
							# 	el.find('.group:first').append '<a href="#" class="home"><label>home</label></a>'
							# 	el.find('.home').click =>
							# 		@callBackgroundMethod 'web'
							# 		false

							@menuInjection? el

							el.find('.sharedWithYou').click =>
								tracking.page "#{@path()}/SharedWithYou"
								util.showDialog => 
									view = new SharedWithYouView @contentScript
									view.represent()
									view
								false

							el.find('.collaborate').click =>
								tracking.page "#{@path()}/Share"
								util.showDialog => 
									view = new CollaborateView @contentScript
									view.represent()
									view
								false

							el.find('.contact').click =>
								tracking.page "#{@path()}/Contact"
								util.showDialog => 
									contactView = new ContactView @contentScript
									contactView.represent()
									contactView
								false


							el.find('.settings').click =>
								tracking.page "#{@path()}/Settings"
								util.showDialog => 
									settingsView = new SettingsView @contentScript
									settingsView.represent()
									settingsView
								false


							el.find('.selectMode').click =>
								@event 'select'
								@enableSelection()
								update()
								frame.update()
								false

						frame.update() if frame

					@menuEl = el = $ '
						<div class="shoppingBarMenu">
							
						</div>
					'

					el.mouseenter => @_mouseenter()
					el.mouseleave => @_mouseleave()

					update()

					frame = Frame.frameFixedAbove anchorEl, el, type:'balloon'
					frame.el.css marginTop:-14
					frame.el



			@menus = []
			@menus.push util.popupTrigger @el.find('.home'),
				createPopup: menu @el.find('.home')
				onClose: (el) =>
					el.data('frame').close()
					@menuEl = null

			@el.find('.home').hide().click false
			@el.find('.moveUp').hide().click =>
				@callBackgroundMethod 'up'
				false

			@menus.push util.popupTrigger @el.find('.moveUp'),
				createPopup: menu @el.find('.moveUp')
				onClose: (el) ->
					el.data('frame').close()


			@el.find('.addData').click =>
				util.showDialog => 
					addDataView = @createView 'AddData'
					# addDataView.represent decisionId:data.args.decisionId
					addDataView.shoppingBarView = @
					addDataView
				false

			@el.find('.content > .add').hide().click =>
				util.showDialog =>
					addItemView = @createView 'AddDescriptor'
					addItemView.represent()
					addItemView.shoppingBarView = @
					addItemView

			# util.showDialog =>
			# 	addItemView = @createView 'AddDescriptorView'
			# 	addItemView.represent()
			# 	addItemView.shoppingBarView = @
			# 	addItemView


			util.tooltip @el.find('.content > .add'), 'add item', distance:20

			util.initDragging @el.find('.content > .add'),
				enabled: false
				dragArea: true
				acceptsDrop: false

			@el.find('.collectionsToggle').click =>
				if @state == 'collections'
					@callBackgroundMethod 'exitCollections'
				else 
					@callBackgroundMethod 'enterCollections'
				false


			util.initDragging @el.find('.collectionsToggle'),
				enabled: false
				dragArea: true
				# acceptsDrop: false
				holdDelay: 200
				onDroppedOn: (el) =>
					util.resolveDraggingData el, (data) =>
						@callBackgroundMethod 'addCollection', [data]
						el.remove()

				onHoldOver: (el) =>
					if @state != 'collections'
						onDropped = el.data('dragging').onDropped
						el.data('dragging').onDropped = (receivingEl) =>
							setTimeout (=>@callBackgroundMethod 'exitCollections'), 500
							onDropped? receivingEl
			
						@callBackgroundMethod 'enterCollections'

			contentWrapperEl = @el.find '.contentWrapper'
			@updateContentWrapperWidth = =>
				x = 10
				prevEl = contentWrapperEl.prevAll(':visible').first()
				if prevEl.length
					x = prevEl.position().left + prevEl.outerWidth(true)


				nextEl = contentWrapperEl.nextAll(':visible').first()
				right = 0
				if nextEl.length
					right = @el.width() - nextEl.position().left

				# right = 70
				# if Agora.errorState.get()
				# 	right = 50
				contentWrapperEl.css
					left:x
					width:''#@el.find('.collectionsToggle').position().left - x - parseInt @el.find('.collectionsToggle').css 'marginLeft'
					right:right

				if @state == 'collections'
					@el.find('.collectionsArrow').css left:contentWrapperEl.offset().left + contentWrapperEl.width()
				true


			$(window).resize @updateContentWrapperWidth
			$ => @updateContentWrapperWidth()

			window.shoppingBarView = @

			updateForUserId = =>
				if Agora.userId.get()
					@el.removeClass('signedOut').addClass 'signedIn'
				else
					@el.removeClass('signedIn').addClass 'signedOut'

			Agora.userId.observe updateForUserId
			updateForUserId()

			@el.find('.errorState').click =>
				@contentScript.reloadExtension()
				setTimeout (-> document.location.reload()), 1000
				false


			updateForErrorState = =>
				if Agora.errorState.get()
					contentWrapperEl.css right:50
					@el.find('.errorState').show()
					util.tooltip @el.find('.errorState'), 'Error! Click to reload extension (some changes may be lost)'
				else
					contentWrapperEl.css right:0
					@el.find('.errorState').hide()

			Agora.errorState.observe updateForErrorState
			updateForErrorState()

			# util.styleSelect $('#select'), true

			if Agora.settings.hideBelt.get()
				@displayMode = 'hidden'
				@hide()
			else
				@displayMode = 'always' # always, hidden, minimal


			Agora.settings.hideBelt.observe =>
				if Agora.settings.hideBelt.get()
					@displayMode = 'hidden'
					@pinCount = 0
					@hide()
				else
					if !@shown
						@show()
					@displayMode = 'always'

			# @el.addClass @displayMode

			bagsbyEl = @el.find('.right .bagsby')
			@chatView = @createView 'Chat', bagsbyEl
			@chatView.represent()
			chatOpen = false
			chatFrame = null
			bagsbyEl.click =>
				if chatOpen
					chatFrame.close()
				else
					tracking.page "#{@path()}/Chat"

					# {left:bagsbyEl, top:@el, position:'fixed', marginLeft:-5}
					chatFrame = frame = Frame.frameAbove bagsbyEl, @chatView.el, type:'balloon', close:true, onClose: =>
						@chatView.onClose()
						@chatView.el.detach()
						chatOpen = false
						delete @chatView.sizeChanged
					frame.el.css
						marginLeft: -9
						marginTop: -24
					@chatView.onDisplay()
					chatOpen = true
					@chatView.close = -> frame.close()
					@chatView.sizeChanged = ->
						frame.update()


			collaborateFrame = null
			collaborateOpen = false
			collaborateView = @collaborateView = @createView 'Collaborate'
			@el.find('.right .collaborate').click =>
				if collaborateOpen
					collaborateFrame.close()
				else
					tracking.page "#{@path()}/Collaborate"
					# {left:bagsbyEl, top:@el, position:'fixed', marginLeft:-5}
					collaborateFrame = frame = Frame.frameAbove @el.find('.right .collaborate'), collaborateView.el, type:'balloon', close:true, onClose: =>
						collaborateView.onClose()
						collaborateView.el.detach()
						collaborateOpen = false
						delete collaborateView.sizeChanged
					frame.el.css
						marginLeft: -9
						marginTop: -24
					collaborateView.onDisplay()
					collaborateOpen = true
					collaborateView.close = -> frame.close()
					collaborateView.sizeChanged = ->
						frame.update()

		closeMenu: ->
			close() for {close:close} in @menus

		pinMenu: ->
			pin() for {pin:pin} in @menus

		unpinMenu: ->
			unpin() for {unpin:unpin} in @menus

		shrinkQueue: []
		queueShrink: (listBarItem) ->
			@shrinkQueue.push listBarItem
			@stopShrink()
			@resumeShrink()

		stopShrink: ->
			clearTimeout @shrinkTimerId

		resumeShrink: ->
			@shrinkTimerId = setTimeout (=>
				for listBarItem in @shrinkQueue
					if listBarItem.state == 'expanded' && !listBarItem.args.readOnly
						if listBarItem.startedDrag
							listBarItem.startedDrag = false
							listBarItem.shrink()
				@shrinkQueue = []
			), 50

		barItemLoadCount: 0
		loadBarItem: (barItem) ->
			++@barItemLoadCount
		barItemLoaded: (barItem) ->
			--@barItemLoadCount

			if !@barItemLoadCount
				@el.find('.content').animate opacity:1, 100


		hoverStack: []
		mouseEnteredBarItemView: (barItemView) ->
			barItemView.el.addClass 'mouseentered'
			item.el.removeClass 'hover' for item in @hoverStack

			@hoverStack.push barItemView

			deepest = deepestDepth = null
			for item in @hoverStack
				depth = item.el.parents('.element').length 
				if deepest == null || depth > deepestDepth
					deepestDepth = depth
					deepest = item

			deepest.el.addClass 'hover'

		mouseLeftBarItemView: (barItemView) ->
			barItemView.el.removeClass 'mouseentered'
			barItemView.el.removeClass 'hover'
			
			$(@hoverStack).find('.hover').removeClass 'hover'
			_.pull @hoverStack, barItemView

			deepest = deepestDepth = null
			for item in @hoverStack
				depth = item.el.parents('.element').length 
				if deepest == null || depth > deepestDepth
					deepestDepth = depth
					deepest = item

			deepest.el.addClass 'hover' if deepest

		processChild: (view) ->
			#Debug.log 'Process', view

		destructChild: (view) ->
			# Debug.log view

		addEditListener: (listener) ->
			@editListeners.push listener

		startEdit: ->
			if !@editing
				@editing = true
				for listener in @editListeners
					listener.startEdit()

		stopEdit: ->
			if @editing
				@editing = false
				for listener in @editListeners
					listener.stopEdit()

		removeEditListener: (listener) ->
			index = @editListeners.indexOf listener
			if index != -1
				@editListeners.splice index, 1


		pin: ->
			clearTimeout @hideTimerId if !@pinCount && @shown
			++ @pinCount
			# console.debug 'shoppingbar pin', @pinCount

			if !@shown
				@show()

		unpin: ->
			-- @pinCount
			# console.debug 'shoppingbar unpin', @pinCount

			if !@pinCount && @shown
				@hideTimerId = setTimeout (=> @hide()), 1000


		startDrag: ->
			# @el.addClass 'dragging'
			@pin() 

		stopDrag: ->
			# @el.removeClass 'dragging'
			@unpin()


		hide: (animate=true) ->
			if @displayMode == 'hidden'
				if @shown
					@el.animate opacity:0, => @el.css height:10, overflow:'hidden'
					@shown = false

		show: ->
			if @displayMode == 'hidden'
				if !@shown
					@el.stop()
					@el.css height:'', overflow:''
					@el.animate opacity:1
					@shown = true

		onMouseenter: ->
			@pin()

		onMouseleave: ->
			@unpin()

		eachSelectable: (cb) ->
			@el.find('.content').children('.element').each ->
				view = $(@).data 'view'
				if view.elementType == 'Session'
					for v in view.views
						cb(v) if v.barItem
				else
					cb view

		enableSelection: ->
			unless @selectMode
				@pinMenu()
				@eachSelectable (view) -> view.enableSelection()
				@selectMode = true

		disableSelection: ->
			if @selectMode
				@unpinMenu()
				@eachSelectable (view) -> view.disableSelection()
				@selectMode = false
				@updateMenu()


		selected: ->
			selected = []
			@eachSelectable (view) -> selected.push(view.id) if view.selected
			selected

		wrapSelection: (type) ->
			@event 'wrap'
			@callBackgroundMethod 'wrap', [type, @selected()]
			@disableSelection()

		deleteSelection: ->
			@event 'delete'
			@callBackgroundMethod 'delete', [@selected()]
			@disableSelection()

		extractSelection: ->
			@event 'extract'
			@callBackgroundMethod 'extract', [@selected()]
			@disableSelection()

		splitSelection: ->
			@event 'split'
			@callBackgroundMethod 'split', [@selected()]
			@disableSelection()

		updateLayout: ->
			x = 0
			sessionSpacing = @el.find('.content').data('spacing')
			animateSpeed = @animateSpeed

			@el.find('.content').children('.element').each ->
				if !$(@).data('view')
					throw new Error 'no view'
				$(@).css left:x, right:''
				x += $(@).data('view').width() + sessionSpacing

			@el.find('.content > .add').css left:x, right:''

			if @state != 'collections'
				x += @el.find('.content > .add').width()
			@el.find('.content').width Math.max(0, x - @sessionSpacing)

			if @direction == 'ltr'
				@el.find('.content').css(left:0, right:'')
			else if @direction == 'rtl'
				@el.find('.content').css(left:'', right:5)

			@animateSpeed = 200
			@updateContentWrapperWidth()

		childWidthChanged: (view) ->
			@updateLayout()

		onData: (data) ->
			@collaborateView.represent 'ShoppingBar'

			if data.barContents
				@withData data.barContents, (barContents) =>
					@configure barContents


			@withData data.updaterStatus, (updaterStatus, mutation) =>
				if mutation
					if mutation.oldValue
						@el.removeClass "#{mutation.oldValue}-status"
				@el.addClass "#{updaterStatus}-status"


			@valueInterface(@el.children('.message')).setDataSource data.updaterMessage

			if data.unseenSharedObjectsCount
				@withData data.unseenSharedObjectsCount, (count) =>
					if @menuEl
						@menuEl.find('.sharedWithYou .count')[if count then 'addClass' else 'removeClass'] 'nonzero'
						@menuEl.find('.sharedWithYou .count').html count
					@el.find('.actions .count')[if count then 'addClass' else 'removeClass'] 'nonzero'
					@el.find('.actions .count').html count


			# console.debug (new Date().getTime() - @startTime)/1000

		onDroppedOn: (el, fromEl, toEl, dropAction) ->
			@lastDroppedOn = toEl
			util.resolveDraggingData el, (data) =>
				to = if toEl != 'up'
					{view:toEl.data('view').id}
				else
					toEl

				if fromEl
					@event 'move'
					@callBackgroundMethod 'move', [data, to, dropAction]
				else
					@event 'drop'
					@callBackgroundMethod 'drop', [data, to, dropAction]

		configure: (data) ->
			@disableSelection()
			@hoverStack = []
			@barItemLoadCount = 0
			@productAddedPopup.close() if @productAddedPopup
			if @state
				@el.removeClass @state
				delete @menuInjection
				switch @state
					# when 'Decision'
						# @el.find('.competitiveProcess').remove()

					when 'collections'
						@el.find('.content > .add').show()
						@el.find('.collectionsArrow').remove()
						null

			@state = data.state

			if @state
				@el.addClass @state
				switch @state
					when 'Decision'
						@menuInjection = (el) =>
							el.find('.group.actions').prepend(
								$('<a href="#" class="workspace"><label>workspace</label></a>').click =>
									compareTileView = new CompareView @contentScript
									compareTileView.shoppingBarView = @
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

									compareTileView.represent decision:id:data.args.decisionId
									tracking.page "#{@path()}/Compare"
									@event 'openWorkspace'
									@closeMenu()
									false
							)

							el.find('.group.actions').prepend(
								$('<a href="#" class="share"><label>share</label></a>').click =>
									tracking.page "#{@path()}/SocialShare"
									util.presentViewAsModalDialog 'SocialShare', {id:data.args.decisionId}, waitUntilRepresented:true
									false
							)

							# el.find('.group.actions').prepend(
							# 	$('<a href="#" class="buy"><label>buy</label></a>').click =>
							# 		tracking.page "#{@path()}/Buy"
							# 		util.presentViewAsModalDialog 'Buy', id:data.args.decisionId
							# 		false
							# )

					when 'collections'
						@el.find('.content > .add').hide()
						@el.append '<span class="collectionsArrow" />'


			@el.find('.contentWrapper').css width:0
			@el.find('.content').css opacity:0

			@direction = data.direction

			# @el.find('.content').data('dragging').direction = @direction

			if data.contents
				@contents.setDataSource data.contents
				@updateLayout()
				if @barItemLoadCount == 0
					@el.find('.content').css opacity:''

			if data.moveUp
				@atRoot = false
				@el.find('.moveUp').show()
				@el.find('.home').hide()
			else
				@atRoot = true
				@el.find('.moveUp').hide()
				@el.find('.home').show()

			@withData data.shared, (shared) =>
				@el[if shared then 'addClass' else 'removeClass'] 'shared'
				@updateContentWrapperWidth()


			@updateContentWrapperWidth()

		items: -> @el.find('.content').children('.element')

		# onMouseenter: ->
		# 	console.debug 'mouseenter'

		# onMouseleave: ->
		# 	console.debug 'mouseleave'

		propOpen: (view) ->
			@pin()

			view.events.onDestruct.subscribe =>
				@unpin()

		methods:
			productAdded: (id) ->
				setTimeout (=>
					el = if @lastDroppedOn.data('view') == @
						@lastDroppedOn.data('view').items().last()
					else if @lastDroppedOn.data('view').elementType == 'Session' || @lastDroppedOn.data('view').elementType == 'Bundle'
						@lastDroppedOn.data('view').barItem.items().last()
					else
						@lastDroppedOn

					_tutorial 'Belt/RemoveItem', {positionEl:el, attachEl:$(document.body), position:'top'}, close:true, (showTutorial) =>
						return unless !window.suppressAddFeeling && (Agora.settings.autoFeelings.get() || @opts.context == 'tutorial')

						@disableProductPopups = true


						editPin = false

						closing = false
						count = 0

						initiateClose = ->
							closing = true
							popup.initiateClose()

						cancelClose = ->
							popup.cancelClose()
							closing = false


						enter = ->
							++ count
							cancelClose()

						leave = ->
							-- count

						closingTimerId = null

						@productAddedPopup = popup = util.showPopup el, 
							close:false
							createPopup: (cb, close) =>
								addFeelingView = @createView 'AddFeelingView', auto:true
								@propOpen addFeelingView

								addFeelingView.el.find('input[name=feeling]').keyup (e) ->
									if e.keyCode == 13
										if editPin
											editPin = false
									else
										editPin = true
										cancelClose()

								addFeelingView.represent id, =>
									frame = Frame.frameFixedAbove el, addFeelingView.el, type:'balloon', color:'dark', onClose: ->
										addFeelingView.destruct()
										addFeelingView = null
									frame.el.css marginTop:-17
									addFeelingView.close = (esc) ->
										if esc
											popup.close()
										else
											popup.initiateClose()
									addFeelingView.sizeChanged = ->
										frame.update()

									frame.el.mouseenter(enter).mouseleave(leave)

									cb frame.el
								null
							onClose: (el) =>
								el.data('frame')?.close?()
								@lastDroppedOn.unbind('mouseleave', leave).unbind('mouseenter', enter)
								delete @disableProductPopups
								delete @productAddedPopup
								clearTimeout closingTimerId

						if @opts.context != 'tutorial'
							@lastDroppedOn.mouseleave leave
							@lastDroppedOn.mouseenter enter
							$(window).one 'mousemove', ->
								closingTimerId = setInterval (->
									if count <= 0 && !editPin && !closing
										initiateClose()
								), 100
				), 100