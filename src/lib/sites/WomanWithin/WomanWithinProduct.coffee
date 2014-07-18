define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class WomanWithinProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}

				otherImages = for image in more.images
					small:image
					medium:image
					large:image
					larger:image
					full:image

				for color in more.colors
					images[color.name] = [
						small:color.image
						medium:color.image
						large:color.image
						larger:color.image
						full:color.image
					].concat otherImages

				cb images, more.color

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					colors:
						title: 'Colors'
						map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews
				cb widgets
