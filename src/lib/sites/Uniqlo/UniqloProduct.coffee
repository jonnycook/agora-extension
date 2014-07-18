define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class UniqloProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				otherImages = for image in more.images
					small:image
					medium:image
					large:image
					larger:image
					full:image

				images = {}

				for color in more.colors
					id = @product.get('productSid').split('-')[0]
					image = "http://uniqlo.scene7.com/is/image/UNIQLO/goods_#{color.id}_#{id}"
					images[color.name] = [
						small:image
						medium:image
						large:image
						larger:image
						full:image
					].concat otherImages

				currentColor = @product.get('productSid').split('-')?[1]
				colorName = null
				if currentColor
					for color in more.colors
						if currentColor == color.id
							colorName = color.name
				cb images, colorName

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					materials: 'Details'
					sizes: 'Sizes'
					colors: 
						title:'Colors'
						map: (color) -> "#{color.id} #{util.ucfirst color.name}"
					reviews:
						obj: reviews
						# maxHeight:100
						map:
							review: 'content'
				cb widgets