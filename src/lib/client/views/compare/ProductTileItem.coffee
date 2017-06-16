define -> d: ['views/compare/TileItem', 'views/ProductPopupView', 'util', 'Frame'], c: ->
	class ProductTileItem extends TileItem
		html: (layout) ->
			html = switch layout
				when 'tiles'
					'<span class="image" /><a />'
				when 'masonry'
					'<div><img class="image" /><a /><ul class="properties"><li /></ul><div class="productMenu" /></div>'

		width: -> super + 48
		init: ->
			super
			triggerEl = @el.find('.image')

			triggerEl.click =>
				@callBackgroundMethod 'click'

			triggerEl.css 'cursor', 'pointer'


			@el.bind 'mouseenter.tutorial', =>
				_tutorial ['AccessProductPortalFromWorkspace', 'Workspace/Dismiss', 'Select'], [@el.find('.image'), {positionEl:@el.find('.actions .dismiss'), attachEl:@el}, {positionEl:@el.find('.actions .chosen'), attachEl:@el}], (close) =>
					@el.find('.image').one 'mousedown', close
					@el.one 'mouseleave', close


			if @view.compareView.public && !@view.contentScript.webApp
				util.draggableImage
					view:@view
					el:@el.find('.image')
					productData:=>@view.args


		updateMasonryLayout: ->
			@el.height Math.max 70, @el.children('div').height()#@el.find('.properties').offset().top - @el.offset().top + @el.find('.properties').outerHeight()# + parseInt @el.find('.properties').css('marginBottom')

		onData: (@data) ->
			updateForImage = switch @view.compareView.layout 
				when 'tiles'
					=> @el.find('.image').css backgroundImage:"url('#{@data.image.get()}')" if @data.image.get()
				when 'masonry'
					=>
						updateMenuPos = =>
							@el.find('.productMenu').css bottom:6#top:@el.find('.image').height() - @el.find('.productMenu').height() + 6

						@el.find('.image')
							.attr('src', @data.image.get())
							.load =>
								@widthChanged()
								updateMenuPos()

						if @el.find('.image').prop 'complete'
							@widthChanged()
							updateMenuPos()

						updateMenuPos()

			updateForImage()
			@data.image.observe updateForImage
			
			if @view.compareView.layout == 'masonry'
				iface = @view.listInterface @el.find('.properties'), 'li', (el, data, pos, onRemove) =>
					view = @view.createView()
					onRemove -> view.destruct()
					switch data.property
						when 'price'
							@view.createView('ProductPrice', el).represent data.value
						when 'rating'
							if data.value
								el.addClass("rating").html "<div class='ratingInfo'><span class='rating'>#{util2.ratingHtml}</span><span class='reviews'>Loading...</span>"
								util2.setRating el.find('.rating'), data.value.rating.get()
								data.value.rating.observe ->
									util2.setRating el.find('.rating'), data.value.rating.get()

								view.valueInterface(el.find('.reviews')).setDataSource data.value.ratingCount
						when 'title'
							view.valueInterface(el).setDataSource data.value
						when 'feelings'
							el.html '<ul class="feelings">
								<li>
									<span class="emotion" />
									<span class="thought" />
									<a href="#" class="delete" />
								</li>
							</ul>'

							feelingsIface = view.listInterface el, '.feelings li', (el, data, pos, onRemove) =>
								feelingsView = view.view()
								onRemove -> feelingsView.destruct()
								feelingsView.valueInterface(el.find('.thought')).setDataSource data.thought

								previousEmotion = null
								updateForEmotion = =>
									emotion = util.emotionClass data.positive.get(), data.negative.get()

									if previousEmotion
										el.find('.emotion').removeClass previousEmotion

									el.find('.emotion').addClass emotion
									previousEmotion = emotion

								data.positive.observe updateForEmotion
								data.negative.observe = updateForEmotion
								updateForEmotion()

								el.find('.delete').click =>
									@callBackgroundMethod 'deleteFeeling', data.id
									false
								el

							# feelingsIface.onInsert = =>
							# 	@widthChanged?()

							# feelingsIface.onDelete = (el, del) =>
							# 	del()
							# 	@widthChanged?()

							feelingsIface.onMutation = => @widthChanged?()

							feelingsIface.setDataSource data.value

						when 'arguments'
							el.html '<ul class="arguments">
								<li>
									<span class="position" />
									<span class="thought" />
									<a href="#" class="delete" />
								</li>
							</ul>'

							argumentsIface = view.listInterface el, '.arguments li', (el, data, pos, onRemove) =>
								argumentsView = view.view()
								onRemove -> argumentsView.destruct()
								argumentsView.valueInterface(el.find('.thought')).setDataSource data.thought
								# view.valueInterface(el.find('.emotion')).setDataSource data.emotion

								previousPosition = null
								updateForPosition = =>
									position = util.positionClass data.for.get(), data.against.get()

									if previousPosition
										el.find('.position').removeClass previousPosition

									el.find('.position').addClass position
									previousPosition = position

								data.for.observe updateForPosition
								data.against.observe = updateForPosition
								updateForPosition()

								el.find('.delete').click =>
									@callBackgroundMethod 'deleteArgument', data.id
									false
								el

							# argumentsIface.onInsert = =>
							# 	@widthChanged?()

							# argumentsIface.onDelete = (el, del) =>
							# 	del()
							# 	@widthChanged?()


							argumentsIface.onMutation = => @widthChanged()
							argumentsIface.setDataSource data.value

						else
							view.valueInterface(el).setDataSource data.value

					el

				# iface.onInsert = =>
				# 	@widthChanged?()

				# iface.onDelete = (el, del) =>
				# 	del()
				# 	@widthChanged?()

				iface.onMutation = => @widthChanged?()

				iface.setDataSource @data.properties
				@view.createView('ProductMenu', @el.find('.productMenu'),
					orientation:'horizontal'
					pinSidebar: =>
						@el.addClass 'pinSidebar'
					unpinSidebar: =>
						@el.removeClass 'pinSidebar'
				).represent @view.args
						
			@el.append('<span class="feelingBadge"><span class="icon" /><span class="text">buffalo</span></span>')

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

			@widthChanged()

		destruct: ->
			super
			@el.css 'backgroundImage', ''
			@el.css 'cursor', ''
			# @el.parent().unbind '.tutorial'

			@popupFrame.el.remove() if @popupFrame
