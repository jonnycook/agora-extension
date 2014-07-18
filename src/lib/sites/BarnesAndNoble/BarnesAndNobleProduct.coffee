define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class BarnesAndNobleProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for image in more.images
					# zoomUrl = "http://www.rei.com/zoom" + image.match(/media([\S\s]*)/)[1]
					otherImages.push
						small:image
						medium:image
						large:image
						larger:image
						full:image
					console.log otherImages

					# else if webcollage
					# 	newUrl = image.match /([\S\s]*?)w[0-9]+\.jpg$/
					# 	if newUrl
					# 		urlFirst = newUrl[1]
					# 		otherImages.push
					# 			small:urlFirst + "300x.jpg"
					# 			medium:urlFirst + "500x.jpg"
					# 			large:urlFirst + "500x.jpg"
					# 			larger:urlFirst + "500x.jpg"
					# 			full:urlFirst
				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					overview: 'Overview'
					# author: 'Author'
					details: 'Details'
					# uses: 'Uses'
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