define -> d: ['util'], c: ->
	class BarItem
		constructor: (@view, @args={}) ->
			@el = view.el
			@elementType = view.elementType

		supportsCreateBundle: -> true

		callBackgroundMethod: (name, args) ->
			@view.callBackgroundMethod name, args

		observeObject: (obj, observer) ->
			@view.view.observeObject obj, observer

		widthChanged: ->
			@view.parent.childWidthChanged? @view

		width: ->
			width = 0
			if @creatingBundle
				width += 58
			width

		init: (data) ->
			@el.html @html
			@el.addClass @elementType.toLowerCase()

			@onData data.barItemData, data

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
				context: 'shoppingBar'
				type: @elementType

				start: (e, opts) =>
					# console.debug 'start', @el
					@el.addClass 'dragging'
					@view.shoppingBarView.startDrag()
					orgDraggingData.start.apply(@, arguments) if orgDraggingData.start

				stop: =>
					# console.debug 'stop', @el
					@el.removeClass 'dragging'

					@view.shoppingBarView.stopDrag()
					orgDraggingData.stop.apply(@, arguments) if orgDraggingData.stop

				onDroppedOn: (el, fromEl, dropAction) =>
					@view.shoppingBarView.onDroppedOn el, fromEl, @el, dropAction
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

				onDraggedOver: (el) =>
					if el
						@el.addClass 'adding'
						@el.removeClass 'removing'
					else
						@el.removeClass 'adding'
						@el.addClass 'removing'

					orgDraggingData.onDraggedOver.apply(@, arguments) if orgDraggingData.onDraggedOver

				onHoldOver: (el) =>
					if el.data('dragging').action == 'addData'
						return

					if @supportsCreateBundle()
						unless @creatingBundle
							@el.addClass 'createBundle'
							@creatingBundle = true
							@el.append '<span class="bundleDrop addDrop" breaksimmutability="true" />'
							@el.append '<span class="fakeGrip" />'
							util.initDragging @el.children('.bundleDrop'),
								enabled: false
								onDroppedOn: (el, fromEl) =>
									@view.shoppingBarView.onDroppedOn el, fromEl, @el, 'createBundle'
									el.remove()
									false

							@widthChanged()

					orgDraggingData.onHoldOver.apply(@, arguments) if orgDraggingData.onHoldOver


				onDragOut: =>
					if @creatingBundle
						@el.removeClass 'createBundle'
						@el.children('.bundleDrop').remove()
						@el.children('.fakeGrip').remove()
						@creatingBundle = false
						@widthChanged()

					orgDraggingData.onDragOut.apply(@, arguments) if orgDraggingData.onDragOut

			util.initDragging @el, draggingData

		destruct: ->
			@el.unbind()
			@el.removeClass @elementType.toLowerCase()
			@el.html ''
			util.terminateDragging @el
		path: -> @view.path()