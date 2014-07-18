define ['model/Model', 'Site', 'model/ModelInstance', 'model/ObservableValue'], (Model, Site, ModelInstance, ObservableValue) ->
	class ProductVariantInstance extends ModelInstance
		instanceMethods: ['update', 'displayValue', 'getDisplayValue', 'productId']

		productId: -> @_product().get 'id'

		_product: -> @_relationships?.product

		displayValue: (property) ->
			if property == 'image'
				=> @field('image').get()
			else
				@_product().displayValue property

		getDisplayValue: (property) ->
			if property == 'image'
				@field('image').get()
			else
				@_product().getDisplayValue property

		retrieve: (args...) ->
			@_product().retrieve args...

		update: ->
			@_product().update()

		_get: (field) ->
			if field in ['id', 'product_id', 'feelings', 'data', 'variant']
				super
			else
				@_product()._get field

		get: (field) ->
			if field in ['id', 'product_id', 'feelings', 'data', 'variant']
				super
			else if field == 'image'
				@field('image').get()
			else
				@_product().get field

		field: (name) ->
			if name in ['id', 'product_id', 'feelings', 'data', 'variant']
				super
			else if name == 'image'
				if !@_image
					@_image = new ObservableValue
					@_product().model.siteProduct @_product(), (siteProduct) =>
						if siteProduct
							siteProduct.variantImage @get('variant'), (image) =>
								if image
									@_image.set image
								else
									@_image.set @_product().getDisplayValue 'image'
				@_image
			else
				@_product().field name

		set: (field, value) ->
			if field != 'product_id'
				throw new Error 'variants are read only'
			super

		isA: (type) -> type == 'Product' || type == 'ProductVariant'

	class ProductVariant extends Model
		constructor: ->
			super
			@ModelInstance = ProductVariantInstance