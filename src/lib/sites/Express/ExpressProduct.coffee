define ['scraping/SiteProduct', 'util', 'underscore'], (SiteProduct, util, _) ->
	class ExpressProduct extends SiteProduct
		variantImage: (variant, cb) ->
			@product.with 'more', (more) =>
				if more
					cb more.images?[variant.Color][0]
				else
					cb()

		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				for color,colorImages of more.images
					images[color] = for image in colorImages
						small:image
						medium:image
						large:image
						larger:image
						full:image

				cb images, more.color

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					details: 'Details'
					colors:
						title: 'Colors'
						map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews
						map:
							review: 'content'
				cb widgets