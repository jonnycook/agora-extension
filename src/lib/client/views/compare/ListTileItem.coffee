define -> d: ['views/compare/TileItem', 'util'], c: ->
	class ListTileItem extends TileItem
		html: ''
		itemSpacing: 10

		supportsCreateBundle: -> false

		draggingData: ->
			type: @type
			immutableContents:@args.readOnly

			onRippedOut: (el) =>
				# @updateLayout()
				# @widthChanged()

			onReorder: (el, startIndex, endIndex) =>
				@callBackgroundMethod 'reorder', [startIndex, endIndex]

			# onRemove: (el) =>
			# 	@view.shoppingBarView.callBackgroundMethod 'remove', [{view:el.data('view').id}, {view:@view.id}]

			onDragOver: =>
				if @state == 'expanded' && !@args.readOnly
					if !@expanded
						@startedDrag = true
						@expand()
				
			onDragOut: =>
				if @expanded
					@view.shoppingBarView.queueShrink @

		constructor: ->
			super
			if !@args.readOnly
				@startEdit = =>
					@expand()

				@stopEdit = =>
					@shrink()

				# @view.shoppingBarView.addEditListener @

			@el.addClass 'list'

		childrenCount: -> @el.children('.element').length

		items: -> @el.children('.tileItem')

		# width: ->
		# 	itemSpacing = @itemSpacing
		# 	super + if @view.data
		# 		switch @state
		# 			when 'expanded'
		# 				width = 0 
		# 				@el.children('.element').each ->
		# 					width += $(@).data('view').width()
		# 				width = Math.max 0, width + (@childrenCount() - 1) * itemSpacing

		# 				if width
		# 					if @expanded
		# 						width += 58
		# 					width
		# 				else
		# 					48
		# 			when 'collapsed'
		# 				48
		# 	else 
		# 		0

		# childWidthChanged: (view) ->
		# 	@updateLayout()
		# 	@parent.childWidthChanged? @


		updateTilesLayout: (params, state) ->
			offsetX = params.offset?.x ? 0
			offsetY = params.offset?.y ? 0

			@el.css
				left: state.x - offsetX
				top: state.y - offsetY

			newParams = _.clone params
			newParams.offset = x:state.x, y:state.y

			startX = state.x
			startRow = state.rows - 1
			for el in @items()
				el = $ el
				el.data('view').barItem.updateTilesLayout newParams, state

			endRow = endX = null
			if state.x == 0
				endRow = state.rows - 2
				endX = params.contWidth + params.margin
			else
				endRow = state.rows - 1
				endX = state.x


			@segments = []

			if startRow != endRow
				@segments.push 
					left: 0
					top: 0
					width: params.contWidth - startX
					height: params.rowHeight

				if startRow != endRow - 1
					for i in [(startRow+1)..(endRow-1)]
						@segments.push
							left: -startX
							top: (i - startRow)*(params.rowHeight+params.margin)
							width: params.contWidth
							height: params.rowHeight

				@segments.push
					left: -startX
					top: (endRow - startRow) * (params.rowHeight+params.margin)
					width: endX - params.margin
					height: params.rowHeight

			else
				@segments.push
					left: 0
					top: 0
					width: endX - startX - params.margin
					height: params.rowHeight


			@el.children('.backing').remove()
			for segment,i in _.clone(@segments).reverse()
				backingEl = $('<div class="backing" />').prependTo(@el).css(position:'absolute').css segment

				if @segments.length > 1
					if i == 0
						backingEl.addClass 'right'

					else if i == @segments.length - 1
						backingEl.addClass 'left'

					else
						backingEl.addClass 'middle'


			lastSegment = @segments[@segments.length - 1]

			actionsEl = @el.children('.actions')
			actionsEl.css
				left:lastSegment.left + lastSegment.width - actionsEl.outerWidth() - 2
				top:lastSegment.top + 2

		updateMasonryLayout: ->
			y = 0
			if @items().length
				@empty = false
				@onNotEmpty?()
				for el in @items()
					el = $ el 
					el.css top:y, left:0
					el.data('view').barItem.updateMasonryLayout()
					y += el.outerHeight() + 40

				@el.height y - 40 - 12

			else
				@empty = true
				@onEmpty?()
				@el.height 185



		# updateLayout: ->
		# 	itemSpacing = @itemSpacing
		# 	switch @state
		# 		when 'expanded'
		# 			x = 0
		# 			# {itemSpacing:itemSpacing, animateSpeed:animateSpeed} = @view.shoppingBarView
		# 			itemSpacing = 10

		# 			@el.children('.element').each ->
		# 				# $(@).animate left:x, animateSpeed
		# 				$(@).css left:x

		# 				x += $(@).data('view').width() + itemSpacing

		# 			# @el.animate width: Math.max(0, x - itemSpacing), animateSpeed
		# 			width = Math.max(0, x - itemSpacing)
		# 			# if width
		# 			# 	if @expanded
		# 			# 		width += 48

		# 			@_width = if width then width else 48

		# 			if width == 0
		# 				@el.addClass 'empty'
		# 			else
		# 				@el.removeClass 'empty'
		# 		when 'collapsed'
		# 			@_width = 48

		# 	@el.css 'width', @_width

		shrink: ->
			if @expanded
				@expanded = false
				@updateLayout()
				@widthChanged()
				@addDrop.remove()
				# @el.css 'padding-right', ''
				@el.removeClass 'hasAddDrop'

		expand: ->
			if !@expanded
				@expanded = true
				@updateLayout()
				@widthChanged()
				@el.addClass 'hasAddDrop'
				# @el.css 'padding-right', 48

				el = $('<a href="#" class="addDrop"></a>').click (e) =>
					dialogEl = Frame.wrapInFrame '<a href="#" class="computer">Add Computer</a>'
					dialogEl.find('.computer').click =>
						@callBackgroundMethod 'add', ['computer']
						Frame.close dialogEl
						false
					dialogEl.appendTo document.body
					Frame.fixFrameAboveAndCentered el, dialogEl
					e.stopPropagation()
					false

				util.initDragging el,
					enabled: false
					acceptsDrop: false
					onDragOver: =>
						# @view.shoppingBarView.stopShrink()
					# onDragOut: =>
					# 	@view.shoppingBarView.resumeShrink()

				@addDrop = el
				@el.append el

		setup: (data) ->
			@contentsView = @view.view.createView()
			@state = data.state
			@el.addClass @state

			if @state == 'expanded'
				# @el.data 'spacing', @view.shoppingBarView.itemSpacing

				@el.append  $ '<div class="element" />'
				contents = @contentsView.listInterface @el, '.element', (el, data, pos, onRemove) =>
					tileItemView = @view.createView 'TileItemView', @view.compareView
					tileItemView.represent data
					tileItemView
					@contentsView.trackView tileItemView
					onRemove -> tileItemView.destruct()
					tileItemView.el

				contents.setDataSource data.contents

				updateForLength = =>
					if contents.length()
						@el.removeClass 'empty'
					else
						@el.addClass 'empty'

				contents.onLengthChanged = updateForLength
				updateForLength()

				contents.onInsert = =>
					@widthChanged()
					@view.updateLayout()

				contents.onDelete = (el, del) =>
					del()
					@widthChanged()
					@view.updateLayout()

				contents.onMove = => 
					@view.updateLayout()

			else if @state == 'collapsed'
				@el.bind 'click.list', => @view.callBackgroundMethod 'click'
				@el.append  $ '<span class="image" />'
				contents = @view.view.listInterface @view.el, '.image', (el, data, pos, onRemove) =>
					el.css 'background-image', "url('#{data}')"
				contents.setDataSource data.contents

				prevLength = contents.length()
				classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
				updateForLength = =>
					@el.removeClass classesForLength[prevLength]
					@el.addClass classesForLength[prevLength = contents.length()]

				contents.onLengthChanged = updateForLength
				updateForLength()

			@view.updateLayout()
			@view.parent.childWidthChanged? @

		onData: (data) ->
			@setup data.state.get()

			@observeObject data.state, =>
				@clearState()
				@setup data.state.get()

		clearState: ->
			@el.removeClass @state
			@contentsView.destruct()

			switch @state
				when 'collapsed'
					@el.find('.image').remove()

				when 'expanded'
					@el.unbind '.list'
					@el.children('.element').remove()


		destruct: ->
			super
			@clearState()
			# @view.shoppingBarView.removeEditListener @ if !@args.readOnly