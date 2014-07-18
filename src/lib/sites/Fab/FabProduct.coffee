define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class FabProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for image in more.images
					urlFirst = image.match(/([^-]*)/)[1]
					urlLast = image.match(/([^-]*)-([^-]*)-(.*)/)[3]
					otherImages.push
						small:urlFirst + "-70x70-" + urlLast
						medium:urlFirst + "-90x90-" + urlLast
						large:urlFirst + "-300x300-" + urlLast
						larger:urlFirst + "-610x610-" + urlLast
						full:urlFirst + "-original-" + urlLast

				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					overview: 'Overview'
					details: 'Details'
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