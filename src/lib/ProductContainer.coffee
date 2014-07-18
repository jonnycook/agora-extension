define ->
	class ProductContainer
		@nextId: 0

		constructor: (@agora, @productInfo) ->
			@subscribers = []
			@id = ++@nextId

			Product = @agora.modelManager.getModel 'Product'
			Product.get productInfo, (product) =>
				@product = product
				subscriber product for subscriber in @subscribers
				delete @subscribers

		withProduct: (cb) ->
			if @product
				cb @product
			else
				@subscribers.push cb
