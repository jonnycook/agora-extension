define -> d: ['views/ShoppingBarView/BarItem', 'util'], c: ->
	class DecisionBarItem extends BarItem
		html: '
			<span class="preview"><span class="image" /><span class="icon" /></span>
			<span class="count" />
			<span class="popupTrigger" />
			<span class="shareIndicator" />
		'
		draggingData: ->
			immutableContents:true
			enabled:true

		onData: (data, barItemData) ->
			@listItem = new ListBarItem @view, true

			@listItem.setup state:'expanded', contents:data.selection

			@view.withData data.shared, (shared) =>
				if shared
					@el.addClass 'shared'
				else
					@el.removeClass 'shared'

			util.initMosaic @view, @el.find('.preview'), '.image', data.preview

			do =>
				updateIcon = => icons.setIcon @el.find('.preview .icon'), data.icon.get() ? 'list', size:'small', itemClass:false

				data.icon.observe =>
					updateIcon()
				updateIcon()

			updateForListSize = =>
				if data.listSize.get() == 0
					@el.addClass 'emptyList'
				else
					@el.removeClass 'emptyList'
				@el.find('.count').html data.listSize.get()

			data.listSize.observe updateForListSize

			updateForListSize()

			@el.find('.count').click (e) =>
				@callBackgroundMethod 'click'
				e.stopPropagation() 

			util.decisionPreview
				anchorEl: =>if data.selection.length() then @el.find('.count') else @el.find('.popupTrigger')
				view:@view
				selection:data.selection
				descriptor:data.descriptor
				icon:data.icon
				preview:data.preview
				el:@el

			@el.click =>
				@callBackgroundMethod 'click' if @el.hasClass 'empty'

			@el.find('.count .selection').html data.selectionSize.get()
			data.selectionSize.observe => @el.find('.count .selection').html data.selectionSize.get()


			if barItemData.user
				@el.find('.shareIndicator').css 'backgroundColor':barItemData.user.color
				
			popup = util.popupTrigger2 @el.find('.shareIndicator'),
				delay:300
				# stayOpen:true
				createPopup: (cb, close, addEl) =>
					return false if window.suppressPopups
						
					collaborateView = @view.createView 'Collaborate'
					@view.shoppingBarView.propOpen collaborateView
					tracking.page "#{@path()}/#{collaborateView.pathElement()}"

					collaborateView.addExtension = (el) ->
						console.debug 'addExtension',el
						addEl el

					collaborateView.removeExtension = (el) ->
						console.debug 'removeExtension', el

					frame = Frame.frameAbove @el.find('.shareIndicator'), collaborateView.el, type:'balloon', distance:20, onClose: ->
						collaborateView.destruct()
						collaborateView = null

					# frame.el.css marginTop:-17
					collaborateView.close = close
					collaborateView.sizeChanged = ->
						frame.update()
					collaborateView.addEl = addEl
					collaborateView.shown()

					collaborateView.represent @view.args
					cb frame.el, 

					null
				onClose: (el) ->
					el.data('frame')?.close?()
			# popup.pin()

		updateLayout: ->
			@listItem.updateLayout()

		width: -> super + @listItem.width()

		destruct: ->
			super
			# if @barItem
			# 	@el.removeClass @barItem.elementType.toLowerCase()
			# else
			# 	@el.removeClass 'placeholder'

			@listItem.destruct()