define -> d: ['View', 'views/ProductOverlayView', 'Frame', 'util'], c: -> 
	showingModal = false
	textMap = 
		AccessWorkspace: 'Click on the preview to access the Workspace for this Decision.'
		AccessProductPortalFromWorkspace: 'Click on the product\'s image to access the Product Portal.'
		AccessProductPortalFromPopup: 'Click on the product\'s image to access the Product Portal.'
		Workspace: 'The Workspace is an open-ended product comparison environment. It displays the product considerations of a Decision in a fullscreen view. Press the ESC key or click the close button at the top right to exit.'
		'Workspace/Dismiss': 'Click the X to dismiss a product you’re considering off to the side. Click a dismissed product to return it.'
		Select: 'Click the checkmark to select the item as one you have chosen among your considerations. The Decision will then be represented by that — as well as any other item you have selected — on the Belt and in the Workspace.'
		'Workspace/ReturnToParent': 'You can return to the main Decision by click this thumbnail.'
		'Belt/RemoveItem': 'To remove a product from the Belt, simply drag it off.'
		AddFeeling: 'You can record the feelings and thoughts you have about the products you are shopping for. Type a thought or feeling and press enter, or just press ESC to close this dialog and continue on to the next step.'
		AddData: 'You can paste links to blogs, videos, or other websites that have information related to the product and hit enter to add the attached content feed.'
		AccessEditDescriptor: 'Edit your decision.'
		EditDescriptor: 'Describe what you\'re shopping for.'


	window._tutorial = (type, el=null, args=null, cb=null) ->
		if showingModal || window.tutorialInProgress
			cb? false
			return

		contentScript.triggerBackgroundEvent 'tutorialCheck', type, (showTutorial) ->
			cb? showTutorial
			if showTutorial
				close = null
				closed = false

				cb = null

				if args
					if _.isFunction args
						cb = args
						args = {}
					else
						cb = args.cb
				else
					args = {}

				if !el
					args.close = true

				cb? (delay=true) ->
					if close
						close delay
					else
						closed = true

				setTimeout (->
					return if closed || showingModal
					# id = new Date().getTime()
					# showing.push id

					text = textMap[showTutorial]

					tipEl = $("<div class='-agora tip'>#{text}</div>")

					tipEl.css
						position:'absolute'
						width:200
						opacity:0

					if args.close
						tipEl.addClass 'hasClose'
						tipEl.append $('<span class="close" />').click -> close false; showingModal = false
						util.tooltip tipEl.find('.close'), 'close'


					close = (delay=true) ->
						if delay
							setTimeout (-> close false), 300
						else
							tipEl.fadeOut -> tipEl.remove()



					if el
						position = 'right'
						if _.isArray el
							if _.isArray type
								el = el[type.indexOf(showTutorial)]
							else
								el = el[0]

						attachEl = positionEl = null
						if el.attachEl && el.positionEl
							{attachEl:attachEl, positionEl:positionEl} = el
							# positionEl = el.el
							# attachEl = positionEl.parent()


							if el.position
								position = el.position

						else
							attachEl = el.parent()
							positionEl = el


						tipEl.append '<div class="connector" />'
						attachEl.append tipEl


						offsetParent = util.positioned attachEl
						offsetParentPos = offsetParent.offset()

						elPos = positionEl.offset()

						pos = 
							left:elPos.left - offsetParentPos.left
							top:elPos.top - offsetParentPos.top

						distance = 20
						currentPosition = null
						margin = 10
						setPosition = (position) ->
							currentPosition = position
							if position == 'right'
								tipEl.css
									left:pos.left + positionEl.width() + distance
									top:pos.top + positionEl.outerHeight()/2 - tipEl.outerHeight()/2
								tipEl.offset().left + tipEl.width() <= $(window).width()

							else if position == 'left'
								tipEl.css
									left:pos.left - tipEl.outerWidth() - distance
									top:pos.top + positionEl.outerHeight()/2 - tipEl.outerHeight()/2
								tipEl.offset().left >= 0

							else if position == 'top'
								tipEl.css
									top:pos.top - tipEl.outerHeight() - distance
									left:Math.min $(window).width() - tipEl.outerWidth() - margin, Math.max margin, pos.left + positionEl.outerWidth()/2 - tipEl.outerWidth()/2
								console.log tipEl.offset()
								tipEl.offset().top >= 0

							else if position == 'bottom'
								tipEl.css
									top:pos.top + positionEl.outerHeight() + distance
									left:pos.left + positionEl.outerWidth()/2 - tipEl.outerWidth()/2
								tipEl.offset().top + tipEl.outerHeight() - $(window).scrollTop() <= $(window).height()



						if !setPosition position
							if position == 'right'
								setPosition 'left'

							else if position == 'top'
								setPosition 'bottom'

						tipEl.addClass currentPosition

						connectorEl = tipEl.find '.connector'
						if currentPosition in ['left', 'right']
							connectorEl.css top:Math.max 0, Math.min tipEl.height(), (elPos.top - tipEl.offset().top) + positionEl.outerHeight()/2 - connectorEl.height()/2
						else if currentPosition in ['top', 'bottom']
							connectorEl.css left:Math.max 0, Math.min tipEl.width(), (elPos.left - tipEl.offset().left) + positionEl.outerWidth()/2 - connectorEl.width()/2
					else
						showingModal = true
						tipEl.addClass 'modal'
						tipEl.appendTo document.body
						tipEl.css
							left:$(window).width()/2 - tipEl.outerWidth()/2
							top:$(window).height()/2 - tipEl.outerHeight()/2 + $(window).scrollTop()

					tipEl.animate opacity:1
						
					setTimeout (-> contentScript.triggerBackgroundEvent 'tutorialSeen', showTutorial), 500
				), 50

	ChangeCapsule = ->
		changes = []

		addChange = (type, args...) ->
			# console.debug 'change', type, args...
			changes.push type:type, args:args


		func = (args...) ->
			jq = $ args...


			obj = 
				jq:jq
				addClass: (className) ->
					addChange '$.addClass', jq, className
					jq.addClass className
					obj
				attr: (name, value) ->
					addChange '$.attr', jq, name, value
					jq.attr name, value
					obj
				css: (args...) ->
					addChange '$.css', jq, args
					jq.css args...
					obj

				data: (name, value) ->
					addChange '$.data', jq, name, value
					jq.data name, value
					obj
				append: (el) ->
					addChange '$.append', jq, el
					jq.append el
					obj
				appendTo: (el) ->
					addChange '$.appendTo', jq, el
					jq.appendTo el
					obj
				load: (func) ->
					addChange '$.load', jq, func
					jq.load func
					obj
				resize: (func) ->
					addChange '$.resize', jq, func
					jq.resize func
					obj
				blur: (func) ->
					addChange '$.blur', jq, func
					jq.blur func
					obj
				focus: (func) ->
					addChange '$.focus', jq, func
					jq.focus func
					obj

				delegate: (args...) ->
					addChange '$.delegate', jq, args...
					jq.delegate args...
					obj
				bind: (args...) ->
					addChange '$.bind', jq, args...
					jq.bind args...
					obj
				hide: ->
					addChange '$.hide', jq
					jq.hide()
					obj
				disableSelection: ->
					addChange '$.disableSelection', jq
					jq.disableSelection()
					obj
				mouseenter: (func) ->
					addChange '$.mouseenter', jq, func
					jq.mouseenter func
					obj
				mouseleave: (func) ->
					addChange '$.mouseleave', jq, func
					jq.mouseleave func
					obj




		_.extend func,
			setTimeout: (func, time) ->
				id = setTimeout func, time
				addChange 'setTimeout', id
				id
			setInterval: (func, time) ->
				id = setInterval func, time
				addChange 'setInterval', id
				id

			undo: ->
				for i in [changes.length - 1..0]
					{type:type, args:args} = changes[i]

					switch type
						when 'setTimeout'
							clearTimeout args[0]
						when 'setInterval'
							clearInterval args[0]

						when '$.addClass'
							args[0].removeClass args[1]
						when '$.attr'
							args[0].removeAttr args[1]
						when '$.data'
							args[0].data args[1], null
						when '$.append'
							# args[0].get(0)?.removeChild $(args[1]).get(0)
							$(args[1]).remove()
						when '$.appendTo'
							# $(args[1]).get(0).removeChild args[0].get(0)
							args[0].remove()
						when '$.load'
							args[0].unbind 'load', args[1]
						when '$.blur'
							args[0].unbind 'blur', args[1]
						when '$.focus'
							args[0].unbind 'focus', args[1]
						when '$.delegate'
							args[0].undelegate args[1], args[2], args[3]
						when '$.bind'
							args[0].unbind args[1], args[2]
						when '$.hide'
							args[0].show()
						when '$.disableSelection'
							args[0].enableSelection()
						when '$.mouseenter'
							args[0].unbind 'mouseenter', args[1]
						when '$.mouseleave'
							args[0].unbind 'mouseleave', args[1]

		func


	# maybe we should rename this to SiteAugumentor
	class SiteInjector
		onOldVersion: ->
			if !@alertedOldVersion
				@alertedOldVersion = true
				@shoppingBarView.el.addClass 'reload'

		constructor: (@contentScript, @continueTutorial, @siteName) ->
			window.Q = @c = ChangeCapsule()

		waitFor: (query, cb) ->
			interval = 0
			if typeof query == 'string'
				queryString = query
				query = => @contentScript.querySelector queryString

			@c.setTimeout (=>
				r = null
				if !r = query()
					@c.setTimeout arguments.callee, interval
				else
					cb r
				), interval

		run: ->	true
		
		initPage: (cb) ->
			@contentScript.triggerBackgroundEvent 'siteVisited', @siteName
			initTimer = @c.setInterval (=>
				if document.body
					if Agora.dev
						# $('body').addClass '-agora-dev'
						Q('body').addClass '-agora-dev'

					clearInterval initTimer
					cb()

					callWhen = (el, cb) ->
						timerId = setInterval (->
							if $(el).length
								cb()
								clearInterval timerId
						), 50

					callWhenNot = (el, cb) ->
						timerId = setInterval (->
							if !$(el).length
								cb()
								clearInterval timerId
						), 50

					if @continueTutorial# || 1
						window.tutorialInProgress = true
						window.suppressPopups = true

						tutorialSteps = [
							(next) =>
								@waitFor (=> el = $ '.-agora.v-shoppingBar .actions .moveUp'; el.offset().top > $(window).height()/2 if el.length), =>
									@c.setTimeout (=> 
										tutorialDialog.show $('.v-shoppingBar .actions'), {orientation:'above'}, {text:'Now click this back arrow to navigate back out of the Decision to the main level of the Belt where you can create new Decisions or add more products to your existing ones.', audio:'http://files.agora.sh/tutorialaudio/12_01.mp3'}
										$('.v-shoppingBar .moveUp').one 'click', =>	
											setTimeout next, 1000
									), 0

							(next) =>
								window.suppressShoppingBarMenu = false
								tutorialDialog.show $('.-agora.v-shoppingBar .actions'),
									{orientation:'above'},
									{text:'Now let\'s quickly learn how collaborative shopping works. First, hover over the <b>Belt Menu</b>.', audio:'http://files.agora.sh/tutorialaudio/13_01.mp3'}

								callWhen '.-agora .shoppingBarMenu', next

							(next) =>
								tutorialDialog.show $('.-agora .shoppingBarMenu .sharedWithYou'),
									{orientation:'right'},
									{text:'And click the <b>Shared With You</b> icon.', audio:'http://files.agora.sh/tutorialaudio/14_01.mp3'}

								callWhen '.-agora .v-sharedWithYou', next

							(next) =>
								tutorialDialog.show $('.-agora .v-sharedWithYou'),
									{orientation:'right'},
									{text:'<p>This menu lists all the things that have been shared with you. If there are items in the list, you can click the checkmarks to add them to your belt.</p>
										<p>Click the close button at the top right of the window to continue.</p>', audio:'http://files.agora.sh/tutorialaudio/15_01.mp3'}

								callWhenNot '.-agora .v-sharedWithYou', next

							(next) =>
								tutorialDialog.show $('.-agora.v-shoppingBar .decision'),
									{orientation:'above'},
									{text:'Next, click this <b>Decision</b>.', audio:'http://files.agora.sh/tutorialaudio/16_01.mp3'}

								callWhen '.-agora.v-shoppingBar.Decision', next

							(next) =>
								tutorialDialog.show $('.-agora.v-shoppingBar .actions .moveUp'),
									{orientation:'above'},
									{text:'Now hover over the <b>back button</b>.', audio:'http://files.agora.sh/tutorialaudio/17_01.mp3'}

								callWhen '.-agora .shoppingBarMenu', next

							(next) =>
								tutorialDialog.show $('.-agora .shoppingBarMenu .collaborate'),
									{orientation:'right'},
									{text:'And click the <b>Collaborate</b> icon.', audio:'http://files.agora.sh/tutorialaudio/18_01.mp3'}

								callWhen '.-agora .v-collaborate', next

							(next) =>
								tutorialDialog.show $('.-agora .v-collaborate'),
									{orientation:'right'},
									{text:'<p>This window allows you to see the collaborators and activity happening in the Decision. If you’re the owner you can invite or remove collaborators.</p>
										<p>Invite someone to help you shop or hit the close button at the top left.</p>', audio:'http://files.agora.sh/tutorialaudio/19_01.mp3'}

								id = callWhenNot '.-agora .v-collaborate', next
								callWhen '.-agora .v-share', ->
									callWhenNot '.-agora .v-share', ->
										clearInterval id
										next()

							(next) =>
								tutorialDialog.show {
									left:$(window).width()/2
									top:$(window).height()/4
									pointer:false, width:400
								}, 'below', {text:'<p>Congratulations! You\'ve finished the tour. You should now have a basic idea of what Agora is all about.</p> <ul> <li>To learn more, check out our <a target="_blank" href="http://agora.sh/manual.html">user manual</a>.</li> <li>Use Agora on any of our <a target="_blank" href="http://agora.sh/supportedSites.html">supported sites</a>.</li> <li>If you have any questions or comments, you may <a target="_blank" href="http://agora.sh/contact.html">contact us</a>.</li> </ul> <p>Thanks for using Agora, and happy shopping!</p> <a class="virtualHighFive">Virtual High Five!</a>', audio:'http://files.agora.sh/tutorialaudio/20_01.mp3'}, ->
									tutorialDialog.frameEl.find('.virtualHighFive').click ->
										next()
										tutorialDialog.close()
								@contentScript.triggerBackgroundEvent 'tutorialFinished'
								delete window.tutorialInProgress
								delete window.suppressPopups
						]

						stepStartTime = null

						doTutorial = (i) ->
							if i > 0
								console.debug 'time', i + 11, new Date().getTime() - stepStartTime
								tracking.time 'Tutorial', "Step#{i + 11}", new Date().getTime() - stepStartTime

							if tutorialSteps[i]
								@contentScript.triggerBackgroundEvent 'tutorialStep', i + 12
								stepStartTime = new Date().getTime()
								console.debug i + 12
								tutorialSteps[i] -> doTutorial i + 1

						tutorialDialog = new TutorialDialog 20, 12
						window.suppressShoppingBarMenu = true

						$ ->
							# stepStartTime = new Date().getTime()
							doTutorial 0
			), 200

		startContentClipping: ->
			$('body').removeClass '-agora-disabled'
			util.showDialog => 
				addDataView = new AddDataView @contentScript, 
					type:'drag'
					url:document.location.href
					title:document.title

				addDataView.shoppingBarView = @
				addDataView

		toggle: ->
			$('body').toggleClass '-agora-disabled'

		clearProductEl: (el) ->
			el = $ el
			util.terminateDragging el
			if el.data('agora')
				if el.data('agora').overlayView
					el.data('agora').overlayView.destruct()
				el.removeData 'agora'
			el.removeAttr 'agora'

		initProductEl: (el, productData, opts={}) -> @products el, productData, opts


		removeOverlay: (attachEl) ->
			attachEl.data('overlay')?.destruct?()
			attachEl.removeAttr 'agora'

		attachOverlay: (opts) ->
			return if opts.attachEl.attr('agora')

			if !('siteName' of opts.productData)
				opts.productData.siteName = @siteName

			Q(opts.attachEl).attr('agora', true)
			productOverlay = new ProductOverlayView contentScript, opts.productData, null, {attachEl:opts.attachEl, positionEl:opts.positionEl, hovering:opts.hovering, position:opts.position ? 'topRight'}
			if opts.overlayZIndex?
				productOverlay.el.css 'zIndex', opts.overlayZIndex
			productOverlay.represent opts.productData
			@initOverlay? productOverlay
			opts.init? productOverlay
			# el.data('agora').overlayView = productOverlay

		products: (selector, productData, opts={}) ->
			# try
				variant = null
				if productData.variant
					variant = productData.variant
					delete productData.variant

				el = $(selector)
				# return if el.data('agora') || el.attr('agora')

				if el.attr 'agora'
					if !el.data 'agora'
						el.parents('a').removeAttr 'agora'
						ProductOverlayView.clear el
					else
						return

				opts.image ?= true
				opts.overlay ?= true

				if !('siteName' of productData)
					productData.siteName = @siteName


				Q(el).attr 'productSid', productData.productSid

				# console.debug 'initProductEl', el.get(0)

				contentScript = @contentScript
				config = @config

				Q(el).data 'agora', opts:opts
				Q(el).attr 'agora', true


				if opts.overlay && config?.productBadges != false
					a = el.parents('a')
					if a.length == 0 || !a.attr 'agora'
						if a.length
							Q(a).attr 'agora', true
						productOverlay = new ProductOverlayView contentScript, _.clone(productData), el.get(0), {hovering:opts.hovering, extra:opts.extraOverlayElements, position:opts.overlayPosition ? 'topRight'}
						if opts.overlayZIndex?
							productOverlay.el.css 'zIndex', opts.overlayZIndex
						productOverlay.represent _.clone(productData)
						@initOverlay? productOverlay
						opts.initOverlay? productOverlay
						el.data('agora').overlayView = productOverlay
			

				if opts.image
					util.initDragging el,
						acceptsDrop: false
						affect:false
						context: 'page'
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
							shoppingBarView.startDrag()
							tracking.event 'Site', 'dragProduct', opts.area
							target = $ event.currentTarget
							target.css opacity:.25
							
							image = ui.helper.find '.p-image'
							image.css
								backgroundImage:"url('#{target.attr 'src'}')"
								width:target.width()
								height:target.height()

							title = ui.helper.find '.p-title'
							site = ui.helper.find '.p-site'
							price = ui.helper.find '.p-price'
							
							view = new View @contentScript
							view.type = 'ProductClip'
							view.onData = (data) ->
								title.html data.title.get() if data.title.get()
								view.observe data.title, (mutation) -> title.html mutation.value
								
								site.html data.site.get() if data.site.get()
								view.observe data.site, (mutation) -> site.html mutation.value

								price.html data.price.get() if data.price.get()
								view.observe data.price, (mutation) -> price.html mutation.value
							
							sendPayload = null
							payload = null
							
							payloadCb = (cb) ->
								if payload
									cb payload
								else
									sendPayload = cb

							ui.helper.data('dragging').data = payloadCb

							# marginLeft = if target.css('marginLeft') then parseInt target.css('marginLeft') else 0
							# marginTop = if target.css('marginTop') then parseInt target.css('marginTop') else 0
							marginLeft = marginTop = 0
							
							offsetX = event.pageX - target.offset().left + marginLeft
							offsetY = event.pageY - target.offset().top + marginTop
							
							ui.helper.css
								marginLeft: marginLeft
								width:target.width()
								height:target.height()
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
							
							productData.elementType = 'Product'
							if _.isFunction variant
								productData.variant = variant()
							else if variant?
								productData.variant = variant

							if productData.variant
								console.debug 'variant: %s', productData.variant
																
							if sendPayload
								sendPayload productData
							else
								payload = productData
							view.represent productData

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
								shoppingBarView.stopDrag()
								view.destruct()
								target.animate opacity:1, 'linear'
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
			# catch e
			# 	console.error e