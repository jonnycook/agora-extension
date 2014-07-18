define ['scraping/SiteProduct'], (SiteProduct) ->
	class EtsyProduct extends SiteProduct
		constructor: (@product) ->
		previewLayout: 'generic'

		# imageWithSize: (url) ->
		# colors: (cb) ->
		# 	@product.field('more').with (more) =>
		# 		colors = {}
		# 		for name,images of more.images 
		# 			colors[name] = images.large.match('$(.*?)\.jpg^')[1] + '_SL100_.jpg'

		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				images[''] = []
				for image in more.images 
					# images[color] = []
					images[''].push
						small:image.largeUrl
						medium:image.fullUrl
						large:image.fullUrl
						larger:image.fullUrl
						full:image.fullUrl
				cb images, ''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				console.debug more
				widgets = @genWidgets more,
					options: 'Options'
					description: 'Description'
					materials: 'Materials'
					tags: 'Tags'
					# sizes: 'Sizes'
					# colors:
					# 	title: 'Colors'
					# 	map: (color) -> util.ucfirst color.name
					# reviews:
					# 	obj: reviews
					# 	# maxHeight:100
					# 	map:
					# 		review: 'content'
				cb widgets
