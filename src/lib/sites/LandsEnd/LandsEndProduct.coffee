define ['scraping/SiteProduct', 'util', 'underscore'], (SiteProduct, util, _) ->
	class LandsEndProduct extends SiteProduct
		variantImage: (variant, cb) ->
			@product.with 'more', (more) =>
				for color in more.colors
					if color.name == variant.Color
						cb more.images[color.id][0]
						return
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
				cb images

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>

				defs =
					description: 'Description'
					features: 'Features'
					sizes: 'Sizes'

				for name,values of more.properties
					defs[name] =
						obj:values
						title:name

				_.merge defs, 
					colors:
						title: 'Colors'
						map: 'name'
					reviews:
						obj: reviews
						map:
							review: 'content'


				widgets = @genWidgets more, defs
				cb widgets