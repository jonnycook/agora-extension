define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class ModClothProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = _.map more.images, (image) ->
					small:image.pdp, medium:image.pdp, large:image.pdp, larger:image.pdp, full:image.hiRes ? image.pdp
				cb {'':images}, ''

		reviews: (cb) ->
			@product.with 'reviews', (reviews) =>
				cb reviews:util.mapObjects reviews, review:'comment'

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					details: 'Details'
					'details.features': 'Features'
					'details.material': 'Material'
					reviews:
						obj: reviews
						# maxHeight:100
						map:
							review: 'comment'
							title: -> ''
				cb widgets