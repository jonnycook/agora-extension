define -> d: ['View', 'Frame', 'views/OffersView', 'views/AddFeelingView', 'views/AddArgumentView'], c: ->
	class ProductPreviewView extends View
		type: 'ProductPreview'
		flexibleLayout: true
		constructor: (@contentScript) ->
			super @contentScript
			@el = $ '
				<div class="-agora v-productPreview loading">
					<a href="#" class="title"><span class="title" /> <span class="continue">continue to product page <span class="arrow">&rarr;</span></span></a>
					<span class="price" />
					<ul class="pictures" />
					<span class="picture lowRes" />
					<span class="picture mediumRes" />
					<a class="picture hiRes" />

					<div class="stylesWrapper"><ul class="styles" /></div>
					<div class="productMenu white" />
				</div>'

			@alsoRepresent @createView 'ProductMenu', @el.find('.productMenu')

			util.initDragging @el.find('.picture.hiRes'),
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
					@event 'dragProduct'
					target = $ event.currentTarget
					# target.css opacity:.25

					width = target.width()
					height = target.height()

					image = ui.helper.find '.p-image'
					image.css
						backgroundImage:"url('#{if @image() then @image().small else @defaultImage}')"
						width:width
						height:height

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
					
					# sendPayload = null
					# payload = null
					
					# payloadCb = (cb) ->
					# 	if payload
					# 		cb payload
					# 	else
					# 		sendPayload = cb

					ui.helper.data 'dragging', data:@args

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
					
					# productData = 
					# productData.elementType = 'Product'
					# if sendPayload
					# 	sendPayload productData
					# else
					# 	payload = productData
					view.represent @args

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


			$(document).bind 'keydown.-agoraProductPreview', (e) =>
				if e.which == 27
					@event 'close', 'esc'
					@close?()
					$(document).unbind 'keydown', arguments.callee

			@el.find('.title').click => @event 'continueToProduct'

		onRepresent: (args) ->
			@createView('ProductPrice', @el.find('.price')).represent args
			@product

		updateLayout: ->
			contWidth = @el.find('.stylesWrapper').width()
			width = @el.find('.styles').width()
			@el.find('.styles').css marginLeft:Math.max 0, (contWidth - width)/2

		setStyle: (style) ->
			@style = style
			if style && @images[style]
				@el.find('.pictures').html ''
				for image,i in @images[style]
					do (i) =>
						@el.find('.pictures').append $("<li style=\"background-image:url('#{image.small}')\" />").click =>
							@event 'selectImage', 'click'
							@setImage i

				@setImage @imageIndex ? 0

				@el.find('.styles .active').removeClass 'active'
				@el.find(".styles [productstyle=\"#{style}\"]").addClass 'active'


		image: -> @images?[@style]?[@imageIndex]


		setImage: (index) ->
			if index >= @images[@style].length
				index = @images[@style].length - 1

			@imageIndex = index
			@el.find('.picture.lowRes').css backgroundImage:"url('#{@images[@style][index].small}')"
			@el.find('.picture.mediumRes').css backgroundImage:"url('#{@images[@style][index].medium}')"
			@el.find('.picture.hiRes').css backgroundImage:"url('#{@images[@style][index].large}')"

			@el.find('.pictures .active').removeClass 'active'
			@el.find(".pictures li:nth-child(#{index + 1})").addClass 'active'

		onData: (data) ->
			# if data.layout
			# 	@el.addClass(data.layout).addClass 'hasLayout'

			title = @el.children '.title'
			imageEl = @el.find '.picture'
			# price = @el.find '.price'

			title.find('.title').html data.title.get() if data.title.get()
			@observe data.title, (mutation) -> title.find('.title').html mutation.value
			title.attr href:data.url

			@el.find('.picture.hiRes').attr href:data.url

			# price.html data.price.get() if data.price.get()
			# @observe data.price, (mutation) -> price.html mutation.value
			
			@defaultImage = data.image.get()

			imageEl.css backgroundImage:"url('#{data.image.get()}')" if data.image.get()
			@observe data.image, (mutation) => 
				@defaultImage = mutation.value
				imageEl.css backgroundImage:"url('#{mutation.value}')"


			if data.layout == 'basic'
				@el.removeClass 'loading'
			else
				updateImages = =>
					@el.find('.styles').html ''
					if data.styleInfo.get()
						@el.removeClass 'loading'
						@images = data.styleInfo.get().images
						if @images && ! _.isEmpty @images
							@el.removeClass 'singlePicture'
							for style,images of @images
								do (style) =>
									@el.find('.styles').append $("<li productstyle='#{style}' style=\"background-image:url('#{images[0].small}')\" />").click =>
										@event 'selectStyle'
										@setStyle style
						else
							@el.addClass 'singlePicture'

						@updateLayout()
						@setStyle data.styleInfo.get().currentStyle

						util.scrollbar @el.find('.stylesWrapper')
						util.scrollbar @el.find('.pictures')


				updateImages()
				data.styleInfo.observe updateImages


			# util.productSidebarCom.observe @, data

		shown: -> @event 'open'
		destruct: ->
			super
			$(document).unbind '.-agoraProductPreview'

			# @initLayout data, data.layout
