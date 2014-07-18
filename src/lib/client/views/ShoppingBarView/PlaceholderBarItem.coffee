define -> d: ['views/ShoppingBarView/BarItem', 'views/ProductPopupView', 'util', 'Frame', 'icons'], c: ->
	class PlaceholderBarItem extends BarItem
		width: -> super + 48
		# init: ->
		# 	super

		onData: (barItemData, data) ->
			util.tooltip @el, data.descriptor.descriptor
			@widthChanged()
			icons.setIcon @el, data.icon


			
		# destruct: ->
		# 	super
