define ['scraping/SiteProduct', 'underscore', 'util'], (SiteProduct, _, util) ->
	class NordstromProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				otherImages = _.map more.images, (image) ->
					small:image.replace /mini/i, 'thumbnail'
					medium:image.replace /mini/i, 'large'
					large:image.replace /mini/i, 'large'
					larger:image.replace /mini/i, 'large'
					full:image.replace /mini/i, 'zoom'

				images = _.mapValues more.colorImages, (image) ->
					[
						small:image#.replace /thumbnail/i, 'large'
						medium:image.replace /thumbnail/i, 'large'
						large:image.replace /thumbnail/i, 'large'
						larger:image.replace /thumbnail/i, 'large'
						full:image.replace /thumbnail/i, 'zoom'
					].concat otherImages
				cb images, more.color

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					details: 'Details'
					sizeInfo: 'Size Info'
					sizes: 'Sizes'
					colors:
						title: 'Colors'
						map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews
						# maxHeight:100
						map:
							review: 'content'



				cb widgets
