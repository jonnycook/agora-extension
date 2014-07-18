define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class RakutenProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for image in more.images
					# urlFirst = "http://images.costco.com/image/media/"
					# urlLast = image.match(/-(.*)/)[1]
					otherImages.push
						small:image
						medium:image
						large:image
						larger:image
						full:image

				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					# features: 'Features'
					# details: 'Details'
					# specifications: 'Specifications'
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