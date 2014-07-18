define ['View', 'Site', 'Formatter'], (View, Site, Formatter) ->
	class ProductAddedView extends View
		@id: (productId) -> "Product\##{productId}"
		
		init: (productId) ->
			Product = @agora.modelManager.getModel 'Product'
			@product = product = Product.withId productId

			title = @clientValue product.get('title')
			product.field('title').observe (mutation) -> title.set mutation.value
			
			price = @clientValue product.get('price')
			product.field('price').observe (mutation) -> price.set mutation.value

			displayPrice = @clientValue product.get('displayPrice')
			product.field('price').observe (mutation) -> displayPrice.set product.get('displayPrice')

			image = @clientValue product.get('image')
			product.field('image').observe (mutation) -> image.set mutation.value
						
			@data = 
				title:title
				site: name:product.get('siteName'), url:product.get('siteUrl')
				price:price
				displayPrice:displayPrice
				image:image
				url:product.get 'url'

		getData: (cb) ->
			cb View.serializeObject @data


		methods:
			set: (view, args) ->
				for property,value of args
					@product.set property, value