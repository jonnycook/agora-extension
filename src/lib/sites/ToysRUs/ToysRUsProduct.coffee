define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class ToysRUsProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for image in more.images
					legacyImg = image.match /([\S\s]*?)dt\.jpg/
					webcollage = image.match /([\S\s]*?)webcollage\.net/
					if legacyImg
						urlFirst = legacyImg[1]
						otherImages.push
							small:urlFirst + "v150.jpg"
							medium:urlFirst + "reg.jpg"
							large:urlFirst + "dt.jpg"
							larger:urlFirst + "dt.jpg"
							full:urlFirst + "enh-z6.jpg"
					else if webcollage
						newUrl = image.match /([\S\s]*?)w[0-9]+\.jpg$/
						if newUrl
							urlFirst = newUrl[1]
							otherImages.push
								small:urlFirst + "w240.jpg"
								medium:urlFirst + "w480.jpg"
								large:urlFirst + "w960.jpg"
								larger:urlFirst + "w960.jpg"
								full:urlFirst
				cb {'':otherImages},''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description: 'Description'
					# details: 'Details'
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