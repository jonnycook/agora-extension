define -> d: ['views/ShoppingBarView/BarItem', 'util'], c: ->
	class ListBarItem extends BarItem
		html: ''

		supportsCreateBundle: -> false

		draggingData: ->
			type: @type
			immutableContents:@args.readOnly

			onRippedOut: (el) =>
				# @updateLayout()
				# @widthChanged()

			onReorder: (el, startIndex, endIndex) =>
				tracking.event 'ShoppingBar', 'reorder'
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

				@view.shoppingBarView.addEditListener @

			@el.addClass 'list'

		childrenCount: -> @el.children('.element').length

		items: -> @el.children('.element')

		width: ->
			super + if @view.data
				switch @state
					when 'expanded'
						width = 0 
						@el.children('.element').each ->
							width += $(@).data('view').width()
						width = Math.max 0, width + (@childrenCount() - 1) * @view.shoppingBarView.itemSpacing

						if width
							if @expanded
								width += 58
							width
						else
							48
					when 'collapsed'
						48
			else 
				0

		# childWidthChanged: (view) ->
		# 	@updateLayout()
		# 	@parent.childWidthChanged? @

		updateLayout: ->
			switch @state
				when 'expanded'
					x = 0
					{itemSpacing:itemSpacing, animateSpeed:animateSpeed} = @view.shoppingBarView

					@el.children('.element').each ->
						# $(@).animate left:x, animateSpeed
						$(@).css left:x

						x += $(@).data('view').width() + itemSpacing

					# @el.animate width: Math.max(0, x - itemSpacing), animateSpeed
					width = Math.max(0, x - itemSpacing)
					# if width
					# 	if @expanded
					# 		width += 48

					@_width = if width then width else 48

					if width == 0
						@empty = true
						@el.addClass 'empty'
						@onEmpty?()
					else
						@empty = false
						@el.removeClass 'empty'
						@onNotEmpty?()
				when 'collapsed'
					@_width = 48

			@el.css 'width', @_width

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
						@view.shoppingBarView.stopShrink()
					# onDragOut: =>
					# 	@view.shoppingBarView.resumeShrink()

				@addDrop = el
				@el.append el

		setup: (data) ->
			@contentsView = @view.view.createView()
			@state = data.state
			@el.addClass @state

			if @state == 'expanded'
				@el.data 'spacing', @view.shoppingBarView.itemSpacing

				@el.append  $ '<div class="element" />'
				contents = @contentsView.listInterface @el, '.element', (el, data, pos, onRemove) =>
					view = util.getBarItem data, @view, @view.shoppingBarView
					@contentsView.trackView view
					onRemove -> view.destruct()
					view.el

				contents.setDataSource data.contents

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
			@view.shoppingBarView.removeEditListener @ if !@args.readOnly