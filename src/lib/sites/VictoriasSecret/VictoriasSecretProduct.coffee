define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class VictoriasSecretProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				if more.images.alternate
					otherImages = for image in more.images.alternate
						small: "https://dm.victoriassecret.com/product/63x84/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						medium: "https://dm.victoriassecret.com/product/240x320/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						large: "https://dm.victoriassecret.com/product/404x539/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						larger: "https://dm.victoriassecret.com/product/760x1013/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						full: "https://dm.victoriassecret.com/product/760x1013/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]

				for name, image of more.images.colors
					images[name] = [
						small: "https://dm.victoriassecret.com/product/63x84/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						medium: "https://dm.victoriassecret.com/product/240x320/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						large: "https://dm.victoriassecret.com/product/404x539/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						larger: "https://dm.victoriassecret.com/product/760x1013/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
						full: "https://dm.victoriassecret.com/product/760x1013/" + image.match(/product\/[^\/]+\/([\S\s]*)/)[1]
					].concat otherImages ? []

				cb images, more.color

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