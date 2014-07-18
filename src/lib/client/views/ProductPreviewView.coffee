widgets = [
	'AmazonFeatures'
	'AmazonDetails'
	'AmazonMostHelpfulReview'
	'AmazonMostRecentReviews'
	'AmazonQuotes'
	'AmazonSizes'
	'html'
	'List'
	'Details'
	'Reviews'
]

define -> d:("widgets/#{widget}Widget" for widget in widgets), c: ->
	withData = (data, cb) ->
		if data.get()
			cb data.get()
		data.observe -> cb data.get()

	class ProductPreviewView extends View
		flexibleLayout:true
		type: 'ProductPreview'
		init: (opts={}) ->
			@public = opts.public
			@viewEl '
				<div class="-agora v-productPreview2 loading">
					<div class="head">
						<a href="#" class="title"><span class="title" /> <span class="continue">continue to product page</span></a>
						<span class="price" />
						<span class="ratingInfo">
							<span class="rating">
								<div><div /></div>
								<div><div /></div>
								<div><div /></div>
								<div><div /></div>
								<div><div /></div>
							</span>
							<span class="reviews">Loading...</span>
					</div>

					<div class="content">
						<div class="picture widget">
							<span class="expand" />
							<div class="current">
								<div class="zoomLevel">Loading...</div>
								<div class="controls">
									<span class="zoomIn">Zoom In</span>
									<span class="zoomOut">Zoom Out</span>
									<span class="actualSize">Actual Size</span>
									<span class="fit">Fit</span>
								</div>
								<span class="bg lowRes" />
								<span class="bg mediumRes" />
								<span class="bg hiRes" />

								<div class="scrollView scroll vertical horizontal">
									<img />
								</div>
							</div>
							<div class="pictures scroll vertical">

							</div>
							<div class="stylesWrapper scroll horizontal">
								<div class="styles">

								</div>
							</div>
						</div>

						<div class="widgets scroll vertical">

						</div>
						<div class="productMenu white" />
					</div>
				</div>'


			productMenuView = @createView 'ProductMenu', @el.find('.productMenu'), public:@public
			@alsoRepresent productMenuView

			@el.find('.title').click => @event 'continueToProduct'

			@updateImage = update = =>
				frameSize = width:imageFrameEl.width(), height:imageFrameEl.height()
				imgEl.css
					marginLeft:Math.max 0, (frameSize.width - imgEl.width())/2
					marginTop:Math.max 0, (frameSize.height - imgEl.height())/2

			@fitImage = true
			setImageSize = (width, height) =>
				frameSize = width:imageFrameEl.width(), height:imageFrameEl.height()

				pos = x:(scrollViewEl.scrollLeft() + frameSize.width/2)/imgEl.width(), y:(scrollViewEl.scrollTop() + frameSize.height/2)/imgEl.height()


				imgEl.css width:width, height:height

				scrollViewEl.scrollLeft imgEl.width()*pos.x - frameSize.width/2
				scrollViewEl.scrollTop imgEl.height()*pos.y - frameSize.height/2

				imgEl.css
					marginLeft:Math.max 0, (frameSize.width - imgEl.width())/2
					marginTop:Math.max 0, (frameSize.height - imgEl.height())/2

				@fitImage = false
				if @imageSize.height/@imageSize.width < frameSize.height/frameSize.width
					if width == frameSize.width
						@fitImage = true
				else
					if height == frameSize.height
						@fitImage = true

				@el.find('.picture .current .zoomLevel').html Math.round((imgEl.width()/@imageSize.width)*100) + '%'


				update()

			scrollImage = (amount) =>
				scrollViewEl.scrollLeft scrollViewEl.scrollLeft() + amount.x
				scrollViewEl.scrollTop scrollViewEl.scrollTop() + amount.y

			zoomIn = =>
				frameSize = width:imageFrameEl.width(), height:imageFrameEl.height()

				newWidth = newHeight = null
				if @imageSize.height/@imageSize.width < frameSize.height/frameSize.width
					inc = (@imageSize.width - frameSize.width)/5
					newWidth = Math.min imgEl.width() + inc, @imageSize.width
					newHeight = ''
				else
					inc = (@imageSize.height - frameSize.height)/5
					newHeight = Math.min imgEl.height() + inc, @imageSize.height
					newWidth = ''

				setImageSize newWidth, newHeight

			zoomOut = =>
				frameSize = width:imageFrameEl.width(), height:imageFrameEl.height()

				newWidth = newHeight = ''
				if @imageSize.height/@imageSize.width < frameSize.height/frameSize.width
					inc = (@imageSize.width - frameSize.width)/5
					newWidth = Math.max imgEl.width() - inc, frameSize.width

				else
					inc = (@imageSize.height - frameSize.height)/5
					newHeight = Math.max imgEl.height() - inc, frameSize.height

				setImageSize newWidth, newHeight

			@fit = fit = =>
				frameSize = width:imageFrameEl.width(), height:imageFrameEl.height()

				width = height = ''
				if @imageSize.height/@imageSize.width < frameSize.height/frameSize.width
					width = frameSize.width
				else
					height = frameSize.height

				setImageSize width, height

			actualSize = =>
				setImageSize '', ''

			imageFrameEl = @el.find('.picture .current')
			scrollViewEl = imageFrameEl.find('.scrollView')
			imgEl = imageFrameEl.find('img')
			@imageSize = null

			imgEl.hide().load =>
				imgEl.show()
				@el.find('.picture .current .bg').css 'backgroundImage', 'none'
				imgEl.css width:'', height:''
				@imageSize = width:imgEl.width(), height:imgEl.height()
				setTimeout (=> @el.find('.picture .current').removeClass 'loading'), 1000
				fit()

			dragging = true
			lastPos = null
			scrollViewEl.mousedown (e) ->
				dragging = true
				lastPos = x:e.clientX, y:e.clientY
				$(window).bind 'mousemove.draggingImage', (e) =>
					pos = x:e.clientX, y:e.clientY

					diff = x:pos.x - lastPos.x, y:pos.y - lastPos.y

					scrollImage x:-diff.x, y:-diff.y
					lastPos = pos

				$(window).one 'mouseup', -> dragging = false; $(window).unbind 'mousemove.draggingImage'

				false

			imageFrameEl.find('.controls')
				.find('.fit').click(=>fit(); @event 'picture/fit').end()
				.find('.actualSize').click(=>actualSize(); @event 'picture/actualSize').end()
				.find('.zoomIn').click(=>zoomIn(); @event 'picture/zoomIn').end()
				.find('.zoomOut').click(=>zoomOut(); @event 'picture/zoomOut').end()

			$(window).bind 'keypress.ProductPreviewView', (e) =>
				switch e.keyCode
					when 40
						e.stopPropagation()
						e.preventDefault()
						false
					when 38
						e.stopPropagation()
						e.preventDefault()
						false
					when 37
						e.stopPropagation()
						e.preventDefault()
						false
					when 39
						e.preventDefault()
						e.stopPropagation()
						false

			$(window).bind 'keydown.ProductPreviewView', (e) =>
				switch e.keyCode
					when 40
						@setCurrentImage (@currentImage + 1) % @images[@currentStyle].length, true
						e.stopPropagation()
						e.preventDefault()
						@event 'nextPicture'
						false
					when 38
						@setCurrentImage (@images[@currentStyle].length + @currentImage - 1) % @images[@currentStyle].length, true
						e.stopPropagation()
						e.preventDefault()
						@event 'previousPicture'
						false
					when 37
						styles = _.keys(@images)
						@setCurrentStyle styles[(styles.length + styles.indexOf(@currentStyle) - 1) % styles.length], true

						e.stopPropagation()
						e.preventDefault()
						@event 'previousStyle'
						false
					when 39
						styles = _.keys(@images)
						@setCurrentStyle styles[(styles.indexOf(@currentStyle) + 1) % styles.length], true

						e.preventDefault()
						e.stopPropagation()
						@event 'nextStyle'
						false
					when 27
						@event 'close', 'esc'
						@close?()
						false



			util.tooltip @el.find('.picture .controls .zoomIn'), 'zoom in'
			util.tooltip @el.find('.picture .controls .zoomOut'), 'zoom out'
			util.tooltip @el.find('.picture .controls .actualSize'), 'actual size'
			util.tooltip @el.find('.picture .controls .fit'), 'fit'


			# util.trapScrolling @el.find('.picture .styleWrapper')
			# util.trapScrolling @el.find('.picture .pictures')
			# util.trapScrolling @el.find('.picture .current .scrollView')
			# util.trapScrolling @el.find('.widgets')

			# util.initScrollbar @el.find('.picture .current .scrollView')



			@el.find('.picture .expand').click =>
				@el.toggleClass 'fullPicture'
				@updateLayout()
				@event 'toggleFullPicture'


			util.draggableImage
				view:@
				el:@el.find('.picture .current img')
				cancel:=> !@fitImage
				productData:=>@args
				image:=>if @getCurrentImage() then @getCurrentImage().small else @defaultImage
				onStart: => @event 'dragProduct'


		updateLayout: ->
			if @imageSize
				if @fitImage
					@fit()
				else
					@updateImage()

			@updateStylesLayout()


		onRepresent: (args) ->
			@createView('ProductPrice', @el.find('.head .price')).represent args

		updateStylesLayout: ->
			contWidth = @el.find('.stylesWrapper').width()
			width = @el.find('.styles').width()
			@el.find('.styles').css marginLeft:Math.max 0, (contWidth - width)/2


		updateImages: ->
			if @images[@currentStyle].length == 1
				@el.find('.picture').addClass 'singlePicture'
			else
				@el.find('.picture').removeClass 'singlePicture'


			@el.find('.picture .pictures').html ''
			for image,i in @images[@currentStyle]
				do (i) =>
					@el.find('.picture .pictures').append($("<span />")
						.css 'backgroundImage', "url('#{image.small}')"
						.click =>
							@setCurrentImage i
							@event 'selectPicture'
					)
			util.initScrollbar @el.find('.picture .pictures')

		getCurrentImage: -> @images[@currentStyle][@currentImage]

		setCurrentImage: (image, scrollIntoView=false) ->
			$(@el.find('.picture .pictures span').get(@currentImage)).removeClass 'active'

			@currentImage = Math.min image, @images[@currentStyle].length - 1


			imgObj = @images[@currentStyle][@currentImage]
			@el.find('.picture .current .bg.lowRes').css backgroundImage:"url('#{imgObj.small}')"
			@el.find('.picture .current .bg.mediumRes').css backgroundImage:"url('#{imgObj.medium}')"
			@el.find('.picture .current .bg.hiRes').css backgroundImage:"url('#{imgObj.large}')"
			@el.find('.picture .current img').hide().attr 'src', imgObj.full

			@el.find('.picture .current .zoomLevel').html 'Loading...'
			@el.find('.picture .current').addClass 'loading'

			$(@el.find('.picture .pictures span').get(@currentImage)).addClass('active')

			if scrollIntoView
				@el.find('.picture .pictures .scrollWrapper').scrollTop @el.find('.picture .pictures span').get(@currentImage).offsetTop - @el.find('.picture .pictures').height()/2 + @el.find('.picture .pictures span:first-child').height()/2


		setCurrentStyle: (style, scrollIntoView=false) ->
			@el.find('.picture .styles')
				.find('.active').removeClass('active').end()
				.find("[stylename='#{style}'").addClass('active')
			@currentStyle = style
			@updateImages()
			@setCurrentImage @currentImage, scrollIntoView

			if scrollIntoView
				if @el.find('.picture .styles').find("[stylename='#{style}'").get(0)
					@el.find('.picture .stylesWrapper .scrollWrapper').scrollLeft @el.find('.picture .styles').find("[stylename='#{style}'").get(0).offsetLeft - @el.find('.picture .stylesWrapper').width()/2 + @el.find('.picture .styles span:first-child').width()/2

		onData: (data) ->
			title = @el.find('.head .title')
			title.find('.title').html data.title.get() if data.title.get()
			@observe data.title, (mutation) -> title.find('.title').html mutation.value
			title.attr href:data.url

			if data.rating && data.ratingCount
				withData data.rating, (rating) => util2.setRating @el.find('.head .rating'), rating
				@valueInterface(@el.find('.ratingInfo .reviews')).setDataSource data.ratingCount
			else
				@el.find('.ratingInfo').remove()

			loading = 0

			finishedLoading = =>
				if !--loading
					@el.removeClass 'loading'

			if data.images
				loading++
				withData data.images, (images) =>
					if images?.images && _.keys(images.images).length
						finishedLoading()
						@images = images.images
						@currentStyle = images.currentStyle
						@currentImage = 0

						if _.keys(images.images).length == 1
							@el.find('.picture').addClass 'noStyles'
						else
							for styleName,styleImages of images.images
								do (styleName) =>
									@el.find('.picture .styles').append($("<span stylename='#{styleName}' />")
										.css 'backgroundImage', "url('#{styleImages[0].small}')"
										.click =>
											@setCurrentStyle styleName
											@event 'selectStyle'
									)
							util.initScrollbar @el.find('.stylesWrapper'), trapScrolling:false


						@updateStylesLayout()
						@updateImages()

						@setCurrentStyle @currentStyle, true
					else
						@el.addClass 'noPictures'
						@withData data.image, (image) =>
							@el.find('.picture').css 'backgroundImage', "url('#{image}')"
			else
				@el.addClass 'noPictures'
				@withData data.image, (image) =>
					@el.find('.picture').css 'backgroundImage', "url('#{image}')"

			if data.widgets
				withData data.widgets, (widgets) =>
					if widgets && widgets.length
						finishedLoading()
						@el.removeClass('fullPicture').removeClass('widgetPanel')
						if widgets == 'none'
							@el.addClass 'fullPicture'
						else
							@el.addClass 'widgetPanel'
							for widgetData in widgets
								throw new Error "No widget #{widgetData.type}" unless __classes["#{widgetData.type}Widget"]
								widget = new __classes["#{widgetData.type}Widget"] widgetData.data
								widgetEl = $('<div class="widget"><span class="title" /><div class="content" /></div>')
									.find('.title').html(widget.title).end()

								widgetEl.addClass "widget-#{widgetData.type}"


								widgetEl.find('.content').append(widget.el)

								@el.find('.widgets').append widgetEl
								widget.init?()
								# if widget.expands
								# 	widgetEl.append '<span class="expand" />'

						util.initScrollbar @el.find('.widgets')
					else
						@el.addClass 'fullPicture'
			else
				@el.addClass 'fullPicture'


		destruct: ->
			super
			$(window).unbind '.ProductPreviewView'