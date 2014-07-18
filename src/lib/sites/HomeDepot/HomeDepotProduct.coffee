define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class HomeDepotProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for name, url of more.images
					urlFirst = url
					urlLast = ""
					otherImages.push
						small:urlFirst
						medium:urlFirst + "300-" + urlLast
						large:urlFirst + "500-" + urlLast
						larger:urlFirst + "500-" + urlLast
						full:urlFirst

				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					features: 'Features'
					details: 'Details'
					specifications: 'Specifications'
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