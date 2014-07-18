define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class WalgreensProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				# console.debug more
				otherImages = []
				for image in more.images
					id = image.match(/http:\/\/pics\.drugstore\.com\/prodimg\/([^\/]*)/)[1]
					# console.log id
					urlFirst = "http://pics.drugstore.com/prodimg/" + id + "/"
					image = image.match(/http:\/\/pics\.drugstore\.com\/prodimg\/[^\/]*\/([\S\s]*?)\.jpg/)[1]
					us = image.match /(_)/
					if us
						otherImages.push
							small:urlFirst + image.match(/([^_]*)/)[1] + "_50.jpg"
							medium:urlFirst + image.match(/([^_]*)/)[1] + "_220.jpg"
							large:urlFirst + image.match(/([^_]*)/)[1] + "_450.jpg"
							larger:urlFirst + image.match(/([^_]*)/)[1] + "_450.jpg"
							full:urlFirst + image.match(/([^_]*)/)[1] + "_450.jpg"
						console.log 'qwet'
						console.log otherImages
					else
						otherImages.push
							small:urlFirst + "50.jpg"
							medium:urlFirst + "220.jpg"
							large:urlFirst + "450.jpg"
							larger:urlFirst + "450.jpg"
							full:urlFirst + "450.jpg"

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
					description: 'Description'
					ingredients: 'Ingredients'
					uses: 'Uses'
					warnings: 'Warnings'								
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