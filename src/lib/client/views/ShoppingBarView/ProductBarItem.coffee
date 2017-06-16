define -> d: ['views/ShoppingBarView/BarItem', 'views/ProductPopupView', 'util', 'Frame'], c: ->
	class ProductBarItem extends BarItem
		html: '<span class="image" /><a />'
		width: -> super + 48
		init: ->
			super
			popup = util.popupTrigger2 @el,
				delay:300
				createPopup: (cb, close, addEl, removeEl) =>
					return false if @view.shoppingBarView.disableProductPopups || window.suppressPopups
						
					productPopupView = @view.createView 'ProductPopupView', unconstrainedPictureHeight:true
					@view.shoppingBarView.propOpen productPopupView
					productPopupView.barItem = @
					tracking.page "#{@path()}/#{productPopupView.pathElement()}"

					productPopupView.represent @view.args, =>
						frame = Frame.frameAbove @el, productPopupView.el, type:'balloon', distance:20, onClose: ->
							productPopupView.destruct()
							productPopupView = null
						# frame.el.css marginTop:-17
						productPopupView.close = close
						productPopupView.sizeChanged = ->
							frame.update()
						productPopupView.addEl = addEl
						productPopupView.removeEl = removeEl
						productPopupView.shown()
						cb frame.el
					null
				onClose: (el) ->
					el.data('frame')?.close?()

			@el.mousedown -> popup.close()

		onData: (@data, @barItemViewData) ->
			@view.withData @data.image, (image) =>
				if image
					@el.find('.image').removeClass('loading').css backgroundImage: "url('#{image}')" 
				else
					@el.find('.image').addClass('loading').css backgroundImage: "none"

			@view.withData @data.purchased, (purchased) =>
				if purchased
					@el.addClass 'purchased'
				else
					@el.removeClass 'purchased'

			if 1
				@el.css 'cursor', 'pointer'

				data = @data
				@el.find('a').mousedown ->
					$(@).attr 'href', data

				@el.find('a').mouseup ->
					setTimeout (=>
						$(@).removeAttr 'href'
					), 500

				@el.find('a').mouseout ->
					$(@).removeAttr 'href'
			else
				@el.find('a').attr 'href', @data.url
			
			@el.html @data.productSid

			@el.click =>
				@callBackgroundMethod 'click'

			@el.append('<span class="feelingBadge noText"><span class="icon" /><span class="text"></span></span>')

			lastEmotion = null
			updateForLastFeeling = =>
				if lastEmotion
					@el.find('.feelingBadge').removeClass lastEmotion

				if @data.lastFeeling.get()
					@el.find('.feelingBadge').show()

					@el.find('.feelingBadge .text').html @data.lastFeeling.get().thought
					emotionClass = util.emotionClass @data.lastFeeling.get().positive, @data.lastFeeling.get().negative
					@el.find('.feelingBadge').addClass emotionClass
					lastEmotion = emotionClass
				else
					@el.find('.feelingBadge').hide()

			@data.lastFeeling.observe updateForLastFeeling
			updateForLastFeeling()

			@view.withData @data.status, (status) =>
				if status == 2
					@el.addClass 'error'
				else
					@el.removeClass 'error'


			@widthChanged()
			
		destruct: ->
			super
			util.clearPopupTrigger @el
			@el.css 'backgroundImage', ''
			@el.css 'cursor', ''
