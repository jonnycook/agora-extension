define ['scraping/SiteProduct'], (SiteProduct) ->
	class TheLimitedProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}

				num = more.images[more.color].large.length

				for color in more.colors
					images[color.name] = for i in [0...num]
						small:more.images[color.name].small[i]
						medium:more.images[color.name].medium[i]
						large:more.images[color.name].large[i]
						larger:more.images[color.name].xlarge[i]
						full:more.images[color.name].xlarge[i]

				cb images, more.color

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					salesDescription: 'Description'
					sizes: 'Sizes'
					longDescription: 'Details'
					colors:
						title: 'Colors'
						map: (color) -> color.name
					reviews:
						obj: reviews
						map:
							review: 'content'
				cb widgets
