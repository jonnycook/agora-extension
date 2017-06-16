define -> d: ['View', 'Frame', 'views/OffersView', 'views/DataView', 'views/AddFeelingView', 'views/AddArgumentView'], c: ->
	class ProductPopupView extends View
		type: 'ProductPopup'
		constructor: (contentScript, @opts={}) ->
			super
			@el = @viewEl '
				<div class="-agora v-productPopup">
					<span class="p-picture"></span>
					<a href="#" class="p-title"></a>
					<a href="#" class="p-site"></a>
					<span class="ratingInfo"><span class="rating">' + util2.ratingHtml + '</span><span class="reviews">Loading...</span></span>
					<span class="price" />

					<!--<a href="#" class="menu" />-->

					<ul class="subAdd">
						<li class="feelings"><a href="#">Feelings</a></li>
						<li class="arguments"><a href="#">Pros and cons</a></li>
						<li class="attachments"><a href="#">Attached clips</a></li>
					</ul>
					<div class="productSidebar" />
				</div>'

			if @opts.unconstrainedPictureHeight
				@el.addClass 'unconstrainedPictureHeight'
				@el.find('.p-picture').append('<img>')

				# util.draggableImage
				# 	view:@
				# 	el:@el.find('.p-picture img')
				# 	productData:=>@args
				# 	# image:=>if @getCurrentImage() then @getCurrentImage().small else @defaultImage

			@productMenuView = @createView 'ProductMenu', @el.find('.productSidebar'),
				orientation:'horizontal'
				pinSidebar: =>
					@el.addClass 'pinSidebar'
				unpinSidebar: =>
					@el.removeClass 'pinSidebar'
				addEl: (el) =>
					@addEl? el
				removeEl: (el) =>
					@removeEl? el

			if @opts.pictureClickHandler
				@el.find('.p-picture').mouseup @opts.pictureClickHandler
			else
				@el.find('.p-picture').mouseup =>
					@close? false
					util.openProductPreview @args, @
					false
			
		onRepresent: (args) ->
			@createView('ProductPrice', @el.find('.price')).represent args, =>
				setTimeout (=>@sizeChanged?()), 0
			@productMenuView.represent args

		onData: (data) ->
			title = @el.find '.p-title'
			site = @el.find '.p-site'
			image = @el.find '.p-picture'
			price = @el.find '.productOffer .price'
		
			title.html data.title.get() if data.title.get()
			@observe data.title, (mutation) =>
				title.html mutation.value
				@sizeChanged?()

			if data.rating && data.ratingCount
				util2.setRating @el.find('.ratingInfo .rating'), data.rating.get() if data.rating.get()
				data.rating.observe =>
					util2.setRating @el.find('.ratingInfo .rating'), data.rating.get()
					@sizeChanged?()

				@valueInterface(@el.find('.ratingInfo .reviews')).setDataSource data.ratingCount
			else
				@el.find('.ratingInfo').remove()


			title.attr href:data.url
			
			site.html data.site.name
			site.attr href:data.site.url

			updateForImage = if @opts.unconstrainedPictureHeight
					=>
						updateForSize = =>
							image.css 'height', img.height()
							@sizeChanged?()
							updateMenuPos()

						updateMenuPos = =>
							@el.find('.productSidebar').css top:image.height() - @el.find('.productSidebar').height() + 9

						img = image.find('img')
						height = img.height()
						clearInterval @imageResizeTimerId

						@imageResizeTimerId = setInterval (=> 
							if img.height() != height
								updateForSize()
								clearInterval @imageResizeTimerId
							height = img.height()
						), 100

						img
							.attr('src', data.image.get())
							.load => 
								updateForSize()
								clearInterval @imageResizeTimerId

						if img.height()
							updateForSize()

				else
					=> image.css backgroundImage: "url('#{data.image.get()}')" if data.image.get() 
						
			updateForImage()
			data.image.observe updateForImage

			@el.append('<span class="feelingBadge"><span class="icon" /><span class="text">buffalo</span></span>')

			lastEmotion = null
			updateForLastFeeling = =>
				if lastEmotion
					@el.find('.feelingBadge').removeClass lastEmotion

				if data.lastFeeling.get()
					@el.find('.feelingBadge').show()

					@el.find('.feelingBadge .text').html data.lastFeeling.get().thought
					emotionClass = util.emotionClass data.lastFeeling.get().positive, data.lastFeeling.get().negative
					@el.find('.feelingBadge').addClass emotionClass
					lastEmotion = emotionClass
				else
					@el.find('.feelingBadge').hide()

			data.lastFeeling.observe updateForLastFeeling
			updateForLastFeeling()


			if data.selected
				mouseDowned = false
				@el.append '<div class="actions"><!--<a href="#" class="dismiss" />--><input type="checkbox" class="chosen"></div>'
				@el.find('.chosen')
					.prop('checked', data.selected.get())
					.mousedown -> mouseDowned = true
					.mouseup (e) -> 
						$(@).trigger 'click' unless mouseDowned
						e.stopPropagation()
						# @callBackgroundMethod 'setSelected', [@el.find('.chosen').prop('checked')]
						mouseDowned = false
					.change => @callBackgroundMethod 'setSelected', [@el.find('.chosen').prop('checked')]
					.click (e) =>
						@event 'toggleChosen'
						e.stopPropagation()
						# @callBackgroundMethod 'setSelected', [@el.find('.chosen').prop('checked')]

				@observeObject data.selected, =>
					@el.find('.chosen').prop 'checked', data.selected.get()

				util.tooltip @el.find('.chosen'), 'choose'

				@el.find('.dismiss')
					.mouseup => @callBackgroundMethod 'dismiss'; false
					.click -> false
				util.tooltip @el.find('.dismiss'), 'dismiss'

				@sizeChanged?()

		shown: ->
			@productMenuView.shown()
			@event 'open'
			_tutorial 'AccessProductPortalFromPopup', @el.find('.p-picture'), 'side'
	
		destruct: ->
			super
			clearInterval @imageResizeTimerId