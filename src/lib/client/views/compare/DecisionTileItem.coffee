define -> d: ['views/compare/TileItem', 'util'], c: ->
	class DecisionTileItem extends TileItem
		draggingData: ->
			immutableContents: true

		onData: (data, itemData) ->
			@el.append '<span class="count"><!--<span class="selection" />/--><span class="list" /></span>'
			@el.append "<span class='preview'><span class='image' /><span class='icon' /></span>"
			@el.append '<span class="shareIndicator" />'

			@view.withData data.shared, (shared) =>
				if shared
					@el.addClass 'shared'
				else
					@el.removeClass 'shared'

			updateIcon = =>
				icons.setIcon @el, (data.icon.get() ? 'list'), size:'large'
			@listItem = new ListTileItem @view, true
			@listItem.onEmpty = updateIcon
			@listItem.onNotEmpty = => icons.clearIcon @el

			updateIcon()

			data.icon.observe =>
				if @listItem.empty
					updateIcon()

			@listItem.setup state:'expanded', contents:data.selection

			do =>
				contents = @view.listInterface @el.find('.preview'), '.image', (el, data, pos, onRemove) =>
					el.css 'background-image', "url('#{data}')"
				contents.setDataSource data.preview

				prevLength = contents.length()
				classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
				updateForLength = =>
					@el.find('.preview').removeClass classesForLength[prevLength]
					@el.find('.preview').addClass classesForLength[prevLength = contents.length()]

				contents.onLengthChanged = updateForLength
				updateForLength()

			do =>
				updateIcon = => icons.setIcon @el.find('.preview .icon'), data.icon.get() ? 'list', itemClass:false

				data.icon.observe =>
					updateIcon()
				updateIcon()

			do =>
				updateForListSize = =>
					if data.listSize.get() == 0
						@el.addClass 'emptyList'
					else
						@el.removeClass 'emptyList'
					@el.find('.count .list').html data.listSize.get()
				data.listSize.observe updateForListSize

				updateForListSize()

			@el.find('.count').click (e) =>
				tracking.event 'Compare', 'openDecision'
				@callBackgroundMethod 'click'
				e.stopPropagation()

			if !@view.compareView.public
				updateTooltip = =>
					# if data.descriptor.get()
					# 	if data.descriptor.get()

					text = if data.descriptor.get()?.descriptor
						data.descriptor.get()?.descriptor
					else 
						'<i>Edit Decision</i>'


					util.tooltip @el.find('.count'), "
						<span class='descriptorTooltip'>
							<span class='preview'><span class='image' /></span>
							<div class='descriptorWrapper'><span class='icon' /> <span class='descriptor'>#{text}</span><a class='edit' href='#' /></div>
						</span>
					",
						parentView:@view
						canFocus:true
						type:'html'
						frameType:'balloon'
						init: (el, close, view) =>
							icons.setIcon el.find('.icon'), data.icon.get() ? 'list', size:'small'
							el.find('.icon').removeClass 't-item'
							# util.tooltip el.find('.edit'), 'edit'

							edit = =>
								editDescriptorView = new EditDescriptorView @view.contentScript
								tracking.page "#{@view.path()}/#{editDescriptorView.pathElement()}"
								tracking.event 'Compare', 'editDescriptor', 'item'
								editDescriptorView.close = -> frame.close()
								editDescriptorView.represent @view.data.get().id
								frame = Frame.frameAround @el.find('.count'), editDescriptorView.el, type:'balloon', distance:15, close: -> frame.close()
								false


							el.find('.edit').click edit


							el.find('.preview').click => @callBackgroundMethod 'click'
							el.find('.descriptor').click edit

							contents = view.listInterface el.find('.preview'), '.image', (el, data, pos, onRemove) =>
								el.css 'background-image', "url('#{data}')"
							contents.setDataSource data.preview

							prevLength = contents.length()
							classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
							updateForLength = =>
								el.find('.preview').removeClass classesForLength[prevLength]
								el.find('.preview').addClass classesForLength[prevLength = contents.length()]

							contents.onLengthChanged = updateForLength
							updateForLength()

					# else
					# 	util.clearTooltip @el.find('.count')

				data.descriptor.observe updateTooltip
				updateTooltip()

			@el.click =>
				@callBackgroundMethod 'click' if @el.hasClass 'empty'

			@el.find('.count .selection').html data.selectionSize.get()
			data.selectionSize.observe => @el.find('.count .selection').html data.selectionSize.get()

			if itemData.user
				@el.find('.shareIndicator').css 'backgroundColor', itemData.user.color
				
			popup = util.popupTrigger2 @el.find('.shareIndicator'),
				delay:300
				# stayOpen:true
				createPopup: (cb, close, addEl) =>
					return false if window.suppressPopups
						
					collaborateView = @view.createView 'Collaborate'

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


		updateTilesLayout: (params, state) ->
			@listItem.updateTilesLayout params, state

			lastSegment = @listItem.segments[@listItem.segments.length - 1]

			countEl = @el.children('.count')
			countEl.css
				left:lastSegment.left + lastSegment.width - countEl.outerWidth()
				top:lastSegment.top + lastSegment.height - countEl.outerHeight()

		updateMasonryLayout: ->
			@listItem.updateMasonryLayout()

		# width: -> super + @listItem.width()

		destruct: ->
			super
			# if @barItem
			# 	@el.removeClass @barItem.elementType.toLowerCase()
			# else
			# 	@el.removeClass 'placeholder'

			@listItem.destruct()