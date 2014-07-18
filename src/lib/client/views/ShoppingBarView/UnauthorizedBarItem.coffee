define -> d: ['views/ShoppingBarView/BarItem', 'views/ProductPopupView', 'util', 'Frame', 'icons'], c: ->
	class UnauthorizedBarItem extends BarItem
		width: -> super + 48
		# init: ->
		# 	super

		onData: (barItemData, @data) ->
			@el.addClass data.objectType
			@widthChanged()

		destruct: ->
			super
			@el.removeClass @data.objectType