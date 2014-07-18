define ['View', 'Formatter', 'util'], (View, Formatter, util) -> class ProductOverlayView extends View
		# @nextId: 1
		@id: (args) -> JSON.stringify args
		
		init: (args) ->
			inShoppingBar = @clientValue()
			lastFeeling = @clientValue()
			lastArgument = @clientValue()
			status = @clientValue()

			@data = 
				bagged:inShoppingBar
				lastFeeling:lastFeeling
				lastArgument:lastArgument
				# productSid:product.get 'productSid'
				status:status

			@agora.product args, ((product) =>
				if product
					updateInShoppingBar = =>
						obj = product.get('inShoppingBar')
						if obj
							if @agora.user && obj[@agora.user.get('id')]
								inShoppingBar.set true
							else
								inShoppingBar.set false
						else
							inShoppingBar.set false

					@observeObject product.field('inShoppingBar'), updateInShoppingBar
					updateInShoppingBar()

					@ctx.bind status, product.field 'status'

					util.lastFeeling @ctx, product, lastFeeling
					util.lastArgument @ctx, product, lastArgument
			), false