define -> d: ['View', 'util', 'views/ShoppingBarView/ListBarItem'], c: ->
	class BundleBarItem extends ListBarItem
		type: 'Bundle'
		html: '<span class="grip" />'

		init: ->
			super
			@el.children('.grip')
				.mouseenter(-> $(@).addClass 'hover' if $(@).parent().hasClass('hover') && util.isMutable $(@).parent())
				.mouseleave(->
					if util.isMutable $(@).parent()
						unless $(@).parent().hasClass 'dragging'
							$(@).removeClass 'hover'
				)