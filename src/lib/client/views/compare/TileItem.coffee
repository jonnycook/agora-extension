define -> d: ['util'], c: ->
	class TileItem
		constructor: (@view, @args={}) ->
			@el = @view.el
			@elementType = @view.elementType

		supportsCreateBundle: -> true

		callBackgroundMethod: (name, args) ->
			@view.callBackgroundMethod name, args

		observeObject: (obj, observer) ->
			@view.view.observeObject obj, observer

		widthChanged: ->
			@view.updateLayout()
			# @view.parent.childWidthChanged? @view

		updateTilesLayout: (params, state) ->
			width = @el.width()

			if state.rows == 1
				++ state.cols

			# if state.x + width > params.contWidth
			# 	state.x = 0
			# 	++ state.rows
			# 	state.y += params.rowHeight + params.margin

			if params.offset
				@el.css
					left: state.x - params.offset.x
					top: state.y - params.offset.y
			else
				@el.css
					left: state.x
					top: state.y

			state.x += width

			if state.x > state.maxWidth
				state.maxWidth = state.x

			state.x += params.margin

			if state.x + width > params.contWidth
				state.x = 0
				++ state.rows
				state.y += params.rowHeight + params.margin

		updateMasonryLayout: ->

		# width: ->
		# 	width = 0
		# 	if @creatingBundle
		# 		width += 58
		# 	width

		init: (data) ->
			if _.isFunction @html
				@el.html @html @view.compareView.layout
			else
				@el.html @html

			@el.addClass @elementType.toLowerCase()
			@el.addClass @view.compareView.layout

			@onData data.barItemData, data

			if !@view.compareView.public
				draggingData = null
				if 'draggingData' of @args
					if @args.draggingData
						draggingData = @draggingData?() ? {}
						_.extend draggingData, @args.draggingData
						util.initDragging @el, draggingData
				else
					draggingData = @draggingData?() ? {}

				orgDraggingData = _.clone draggingData

				_.extend draggingData,
					type: @elementType
					helper: (event, el, offset) => 
						barItemView = new BarItemView @view.contentScript,
							queueShrink: ->
							addEditListener: ->
							itemSpacing: 10
							animateSpeed: 10
							stopShrink: ->
							removeEditListener: ->
							mouseEnteredBarItemView: ->
							mouseLeftBarItemView: ->
							loadBarItem: ->
							barItemLoaded: ->
								offset.x = barItemView.el.width() - 10
								offset.y = barItemView.el.height() - 10
							stopDrag: ->
							startDrag: ->

						barItemView.parent = childWidthChanged: ->
						barItemView.represent @view.args
						barItemView.el.addClass 'dragging'
						barItemView.el.data 'dragging', data:{view:@view.id}
						barItemView.el

					cancel: =>
						!@view.id

					start: (event, ui) =>
						@el.remove()
						orgDraggingData.start.apply(@, arguments) if orgDraggingData.start

					stop: =>
						@el.removeClass 'dragging'
						orgDraggingData.stop.apply(@, arguments) if orgDraggingData.stop

					onDroppedOn: (el, fromEl, dropAction) =>
						@view.compareView.onDroppedOn el, fromEl, @el, dropAction
						el.remove()
						if orgDraggingData.onDroppedOn then orgDraggingData.onDroppedOn.apply(@, arguments) else false
					
					onGlobal: =>
						@view.noDestruct = true
						@view.separate()

					onDropped: (receivingEl) =>
						delete @view.noDestruct
						unless receivingEl
							@callBackgroundMethod 'delete'
							@view.destruct()

					onDraggedOver: (el, draggingEl) =>
						if el
							draggingEl.addClass 'adding'
							draggingEl.removeClass 'removing'
						else
							draggingEl.removeClass 'adding'
							draggingEl.addClass 'removing'

						orgDraggingData.onDraggedOver.apply(@, arguments) if orgDraggingData.onDraggedOver

					# onHoldOver: (el) =>
					# 	if el.data('dragging').action == 'addData'
					# 		return

					# 	if @supportsCreateBundle()
					# 		unless @creatingBundle
					# 			@el.addClass 'createBundle'
					# 			@creatingBundle = true
					# 			@el.append '<span class="bundleDrop addDrop" breaksimmutability="true" />'
					# 			@el.append '<span class="fakeGrip" />'
					# 			util.initDragging @el.children('.bundleDrop'),
					# 				enabled: false
					# 				onDroppedOn: (el, fromEl) =>
					# 					@view.compareView.onDroppedOn el, fromEl, @el, 'createBundle'
					# 					el.remove()
					# 					false

					# 			@widthChanged()

					# 	orgDraggingData.onHoldOver.apply(@, arguments) if orgDraggingData.onHoldOver


					# onDragOut: =>
					# 	if @creatingBundle
					# 		@el.removeClass 'createBundle'
					# 		@el.children('.bundleDrop').remove()
					# 		@el.children('.fakeGrip').remove()
					# 		@creatingBundle = false
					# 		@widthChanged()

					# 	orgDraggingData.onDragOut.apply(@, arguments) if orgDraggingData.onDragOut

				util.initDragging @el, draggingData

		destruct: ->
			@el.unbind()
			@el.removeClass @elementType.toLowerCase()
			@el.html ''
			# util.terminateDragging @el