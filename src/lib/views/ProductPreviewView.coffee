define ['View', 'underscore', 'util'], (View, _, util) ->
	class ProductPreviewView extends View
		@nextId:0
		@id: -> ++@nextId
		initAsync: (args, done) ->
			@data = {}

			@resolveObject args, (product) =>
				product.update()
				
				_.extend @data,
					url:product.get('url')
					title:@clientValue product.field('title'), product.displayValue 'title'
					image:@clientValue product.field('image'), product.displayValue 'image'

				product.interface (siteProduct) =>
					if siteProduct
						images = @clientValue()
						widgetsCv = @clientValue()
						siteProduct.images (imgs, currentStyle) =>
							if imgs
								if !currentStyle
									currentStyle = _.keys(imgs)[0]

								images.set images:imgs, currentStyle:currentStyle
							else
								images.set null

						if siteProduct.widgets
							siteProduct.widgets (widgets) =>
								widgetsCv.set widgets
						else
							widgetsCv.set 'none'

						_.extend @data,
							images:images
							widgets:widgetsCv


						if siteProduct.site.hasFeature 'rating'
							_.extend @data,
								rating:@clientValue product.field('rating'), product.displayValue 'rating'
								ratingCount:@clientValue product.field('ratingCount'), product.displayValue 'ratingCount'

					done()

				
