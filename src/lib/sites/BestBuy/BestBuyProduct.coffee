define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class BestBuyProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for name, image of more.images
					orig = image
					image = image.match(/^(.*?);/)[1]
					size = orig.match(/;(.*)/)[1]
					[height, width] = size.split ';'
					height = height.match(/^canvasHeight=(.*)/)[1]
					width = width.match(/^canvasWidth=(.*)/)[1]
					smallH = Math.floor(height/6)
					mediumH = Math.floor(height/4)
					largeH = Math.floor(height/2)
					smallW = Math.floor(width/6)
					mediumW = Math.floor(width/4)
					largeW = Math.floor(width/2)

					otherImages.push
						small:image + ";canvasHeight=#{smallH};canvasWidth=#{smallW}"
						medium:orig
						large:orig
						larger:orig
						full:image

				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description: 'Description'
					features: 'Features'
					specifications: 'Specifications'
					# warnings: 'Warnings'								
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