define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class KateSpadeProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				parts = @product.get('productSid').split '_'
				colorId = parts[1]
				colorName = null
				for color in more.colors
					if color.id == colorId
						colorName = color.name
						break

				for name, imgs of more.images
					images[name] = for img in imgs
						small:img + '?op_sharpen=1&resMode=sharp2&id=kmVqf0&scl=10&fmt=jpg'
						medium:img + '?op_sharpen=1&resMode=sharp2&id=kmVqf0&scl=6&fmt=jpg'
						large:img + '?op_sharpen=1&resMode=sharp2&id=kmVqf0&scl=3&fmt=jpg'
						larger:img + '?op_sharpen=1&resMode=sharp2&id=kmVqf0&scl=2&fmt=jpg'
						full:img + '?op_sharpen=1&resMode=sharp2&id=kmVqf0&scl=1&fmt=jpg'
				cb images, colorName

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					'details.details': 'Details'
					'details.features': 'Features'
					'details.material': 'Material'
					colors:
						title: 'Colors'
						map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews
				cb widgets