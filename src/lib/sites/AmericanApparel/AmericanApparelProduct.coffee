define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class AmericanApparelProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				otherImages = for image in more.images
					small:image.replace(/(_\d{2})/, "$1t")
					medium:image
					large:image
					larger:image
					full:image

				for color in more.colors
					images[color.name] = [
						small:color.image.replace(/(_\d{2})/, "$1t")
						medium:color.image
						large:color.image
						larger:color.image
						full:color.image
					].concat otherImages

				cb images, more.color

		reviews: (cb) ->
			@product.with 'reviews', (reviews) ->
				cb reviews:reviews ? []

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
				cb widgets
