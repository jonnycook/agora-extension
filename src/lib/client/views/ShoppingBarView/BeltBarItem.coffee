define -> d: ['views/ShoppingBarView/BarItem', 'views/ProductPopupView', 'util', 'Frame'], c: ->
	class BeltBarItem extends BarItem
		html:'
			<span class="preview mosaic"><span class="image" /></span>
			<span class="icon" />
			<span class="count" />
			<span class="shareIndicator" />'
		width: -> 48
		init: ->
			super
			@el.click =>
				@callBackgroundMethod 'click'

		onData: (@data, barItemData) ->			
			util.initMosaic @view, @el.find('.preview'), '.image', data.preview

			@view.withData data.count, (count) =>
				if count == 0
					@el.addClass 'empty'
				else
					@el.removeClass 'empty'
				@el.find('.count').html count

			@view.withData data.shared, (shared) =>
				if shared
					@el.addClass 'shared'
				else
					@el.removeClass 'shared'

			if barItemData.user
				@el.find('.shareIndicator').css 'backgroundColor':barItemData.user.color
				
			popup = util.popupTrigger2 @el.find('.shareIndicator'),
				delay:300
				# stayOpen:true
				createPopup: (cb, close, addEl) =>
					return false if window.suppressPopups
						
					collaborateView = @view.createView 'Collaborate'
					@view.shoppingBarView.propOpen collaborateView
					# tracking.page "#{@path()}/#{collaborateView.pathElement()}"

					collaborateView.addExtension = (el) ->
						addEl el

					collaborateView.removeExtension = (el) ->

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
