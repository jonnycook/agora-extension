define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class SearsProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				if more.images.alternate
					otherImages = for image in more.images.alternate				
						small:image + '?hei=100&wid=100&op_sharpen=1'
						medium:image + '?hei=300&wid=300&op_sharpen=1'
						large:image + '?hei=500&wid=500&op_sharpen=1'
						larger:image + '?hei=1000&wid=1000&op_sharpen=1'
						full:image + '?op_sharpen=1' #I've noticed that the portal just waits and loads full, without showing lower res versions first. bug?

				for name, image of more.images.colors
					images[name] = [
						small:image + '?hei=100&wid=100&op_sharpen=1'
						medium:image + '?hei=300&wid=300&op_sharpen=1'
						large:image + '?hei=500&wid=500&op_sharpen=1'
						larger:image + '?hei=1000&wid=1000&op_sharpen=1'
						full:image + '?op_sharpen=1' #I've noticed that the portal just waits and loads full, without showing lower res versions first. bug?
					].concat otherImages ? []	

				cb images, more.color


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