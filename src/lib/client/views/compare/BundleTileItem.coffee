define -> d: ['View', 'util', 'views/compare/ListTileItem'], c: ->
	class BundleTileItem extends ListTileItem
		type: 'Bundle'
		html: ''

		init: ->
			super
			@el.children('.grip')
				.mouseenter(-> $(@).addClass 'hover' if $(@).parent().hasClass('hover') && util.isMutable $(@).parent())
				.mouseleave(->
					if util.isMutable $(@).parent()
						unless $(@).parent().hasClass 'dragging'
							$(@).removeClass 'hover'
				)

		updateTilesLayout: (params, state) ->
			super
			@el.children('.grip').remove()
			for segment,i in @segments
				gripEl = $ '<div class="grip" />'

				if @segments.length > 1
					if i == 0
						gripEl.addClass 'left'

					else if i == @segments.length - 1
						gripEl.addClass 'right'

					else
						gripEl.addClass 'middle'

				gripEl.css
					position:'absolute'
					left:segment.left
					width:segment.width
					top:segment.top + params.rowHeight + 7
					height: 10

				gripEl.appendTo @el
