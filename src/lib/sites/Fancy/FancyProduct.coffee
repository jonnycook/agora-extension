define ['scraping/SiteProduct'], (SiteProduct) ->
	class FancyProduct extends SiteProduct
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
				# console.debug more
				otherImages = []
				for image in more.images
					urlFirst = image.match(/([\S\s]*?)commerce/)[1]
					urlLast = image.match(/commerce\/([\S\s]*?)\/(.*)/)[2]
					otherImages.push
						small:urlFirst + "commerce/200/" + urlLast
						medium:urlFirst + "commerce/310/" + urlLast
						large: "http://resize-ec1.thefancy.com/resize/500/thefancy/commerce/original/" + urlLast
						larger: "http://resize-ec1.thefancy.com/resize/700/thefancy/commerce/original/" + urlLast
						full:urlFirst + "commerce/original/" + urlLast

				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				console.debug more
				widgets = @genWidgets more,
					description: 'Description'
					select: 'Options'
					reacts: 'Reacts'
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
