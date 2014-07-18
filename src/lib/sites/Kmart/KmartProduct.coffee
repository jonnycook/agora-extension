define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class KmartProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				otherImages = []
				for image in more.images
					for img, url of image
						otherImages.push
							small:url['primaryImg'] + '?hei=100&wid=100&op_sharpen=1'
							medium:url['primaryImg'] + '?hei=300&wid=300&op_sharpen=1'
							large:url['primaryImg'] + '?hei=500&wid=500&op_sharpen=1'
							larger:url['primaryImg'] + '?hei=1000&wid=1000&op_sharpen=1'
							full:url['primaryImg'] + '?op_sharpen=1' #I've noticed that the portal just waits and loads full, without showing lower res versions first. bug?
				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description: 'Description'
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