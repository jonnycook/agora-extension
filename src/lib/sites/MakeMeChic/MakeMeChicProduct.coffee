define ['scraping/SiteProduct'], (SiteProduct) ->
	class MakeMeChicProduct extends SiteProduct
		variantImage: (variant, cb) ->
			@product.with 'more', (more) =>
				cb more.images?[variant.Color][0].small

		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				for color, colorImages of more.images
					images[color] = for image in colorImages
						small:image.small
						medium:image.big
						large:image.big
						larger:image.big
						full:image.big
				cb images, more.color

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					details: 'Details'
					colors:
						title: 'Colors'
						map: (color) -> color.name
					# reviews:
					# 	obj: reviews
					# 	map:
					# 		review: 'content'
				cb widgets
