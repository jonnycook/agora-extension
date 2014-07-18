define -> d: ['views/ShoppingBarView/BarItem', 'util', 'icons'], c: ->
	class CompositeSlotBarItem extends BarItem
		supportsCreateBundle: -> false

		width: ->
			super + if @elementView
				@elementView.width()
			else
				48

		onData: (data) ->
			@observeObject data.elementId, (mutation) =>
				if @elementView
					@elementView.el.remove()
					@elementView.detach()
					@elementView.destruct()
					delete @elementView

				if data.elementId.get()
					@elementView = util.getBarItem type:data.elementType.get(), id:data.elementId.get(), container:type:'CompositeSlot', id:data.id, @view, @view.shoppingBarView
					@el.append @elementView.el
					@widthChanged()


			if data.elementId.get()
				@elementView = util.getBarItem type:data.elementType.get(), id:data.elementId.get(), container:type:'CompositeSlot', id:data.id, @view, @view.shoppingBarView
				@el.append @elementView.el

			@el.addClass data.type
			icons.setIcon @el, data.type
						
			@widthChanged()