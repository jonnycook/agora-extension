define ['scraping/SiteProduct'], (SiteProduct) ->
	class SixPMProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				for id,style of more.styles
					images[id] = []
					for name,image of style.images
						if image.MULTIVIEW
							images[id].push 
								small:image.MULTIVIEW
								medium:image.MULTIVIEW
								large:image['4x']
								larger:image['4x']
								full:image['4x']

				cb images, more.currentStyle

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					productDetails: 'Description'
					sizes: 'Sizes'
					colors:
						title: 'Colors'
						map: (color) -> color.name
				cb widgets
