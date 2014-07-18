define -> d: ['View', 'util', 'icons'], c: -> 
	class AddItemView extends View
		type: 'AddItem'
		constructor: ->
			super
			@el = @viewEl '<div class="v-addItem t-dialog">
				<h2>Add something</h2>
				<div class="content">
					<input type="text" class="filter" placeholder="Describe what you are looking for">
					<div class="itemList">
						<!--<span class="item" />-->
					</div>
				</div>
			</div>'

			for type in ['decision', 'bundle', 'computer', 'session', 'list', 'descriptor']
				do (type) =>
					el = $ "<span class='-agora-newItem' />"
					icons.setIcon el, type

					util.tooltip el, type, position:'below'

					util.initDragging el,
						data: (cb) => 
							cb if type == 'descriptor'
								action:'new', type:type, descriptor:@el.find('.filter').val()
							else
								action:'new', type:type
						context: 'page'
						onDraggedOver: (activeEl, helperEl) ->
							if activeEl
								helperEl.addClass 'adding'
							else 
								helperEl.removeClass 'adding'
						helper: -> el.clone().addClass '-agora dragging'
						start: ->
							el.css opacity:.5
						stop: (event, ui) =>
							el.animate opacity:1
							ui.helper.detach()
							@close()
					@el.find('.itemList').append el

		onData: (@data) ->
