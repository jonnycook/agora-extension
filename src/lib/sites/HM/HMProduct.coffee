define ['scraping/SiteProduct'], (SiteProduct) ->
	class HMProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}

				for color, colorImages of more.images
					images[color] = for image in colorImages
						small:image
						medium:image
						large:image
						larger:image
						full:image

				cb images, more.color

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description:'Description'
					details: 'Details'
					sizes: 'Sizes'
					colors:
						title: 'Colors'
						map: (color) -> color.name
				cb widgets
