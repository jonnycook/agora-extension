define ['scraping/SiteProduct'], (SiteProduct) ->
	class Singer22Product extends SiteProduct
		variantImage: (variant, cb) ->
			@product.with 'more', (more) =>
				if more
					cb more.colorImages?[variant.Color].main
				else
					cb()

		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				# for color in more.colors
				for image in more.images
					images[image.color] ?= [
						# small:more.colorImages[color].main
						# medium:more.colorImages[color].main
						# large:more.colorImages[color].main
						# larger:more.colorImages[color].main
						# full:more.colorImages[color].main
					]

					images[image.color].push
						small:image.full
						medium:image.full
						large:image.full
						larger:image.full
						full:image.full
				cb images

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					colors: 'Colors'
				cb widgets
