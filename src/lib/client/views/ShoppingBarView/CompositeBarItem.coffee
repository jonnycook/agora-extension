define -> d: ['views/ShoppingBarView/BarItem', 'util', 'icons'], c: ->
	class CompositeBarItem extends BarItem
		width: -> super + 48

		onData: (data) ->
			@el.addClass data.type
			icons.setIcon @el, data.type

			@el.click =>
				@callBackgroundMethod 'click'

			@widthChanged()

		destruct: ->
			super
			icons.clearIcon @el