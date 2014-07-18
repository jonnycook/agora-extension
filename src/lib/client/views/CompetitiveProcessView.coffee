define -> d: ['View'], c: -> 
	class CompetitiveProcessView extends View
		type: 'CompetitiveProcess'
		constructor: ->
			super
			@el = @viewEl '<div class="v-competitiveProess">
				<div class="elements">
					<div class="element" />
				</div>
			</div>'

			@elementsEl = @el.find('.elements')
			@el.find('.elements')
				.data('spacing', 5)
				.attr 'draggingroot', true

		updateLayout: (animate=false)->
			x = 0
			itemSpacing = 5
			@el.children('.elements').children('.element').each ->
				if animate
					$(@).stop(true,true).animate left:x
				else
					$(@).css left:x
				x += $(@).data('view').width() + itemSpacing
			width = Math.max(0, x - itemSpacing)
			@el.children('.elements').css 'width', if width then width else 48

		childWidthChanged: ->
			@updateLayout()

		initEl: (el, row) ->
			offset = null
			newTop = null
			el.css top:-row*48

			mousemove = (e) =>
				newTop = Math.min 0, e.pageY - @elementsEl.offset().top - offset.y
				newRow = -Math.round(newTop/48)

				if row != newRow
					row = newRow
					@callBackgroundMethod 'setRow', [el.data('view').id, row]
					el.stop(true).animate
						top: -row*48

			el.mousedown (e) =>
				offset = x:e.pageX - el.offset().left, y:e.pageY - el.offset().top
				$(window).mousemove mousemove

				$(window).one 'mouseup', ->
					# row = Math.round(newTop/48)
					# el.animate top:row*48
					$(window).unbind 'mousemove', mousemove

		onData: (@data) ->
			contents = @listInterface @el, '.element', (el, data, pos, onRemove) =>
				barItemView = @createView 'BarItemView', @shoppingBarView,
					barItemArgs:
						draggingData:
							immutableContents: true
							enabled: false

				barItemView.changedType = => 
					@initEl barItemView.el, data.row.get()
				barItemView.represent data.barItem
				onRemove -> barItemView.destruct()
				barItemView.el

			contents.setDataSource data

			contents.onInsert = =>
				@updateLayout true

			contents.onDelete = (el, del) =>
				del()
				@updateLayout true

			contents.onMove = => @updateLayout true

			@updateLayout()
