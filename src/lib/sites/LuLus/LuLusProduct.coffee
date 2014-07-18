define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class LuLuProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = []
				for image in more.images

					images.push
						small:image
						medium:image
						large:image
						larger:image
						full:image.replace('small', 'xlarge')
				cb {'':images}, ''

		reviews: (cb) ->
			@product.with 'reviews', (reviews) =>
				cb reviews:util.mapObjects reviews, rating: (review) -> review.rating/100 * 5

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					reviews:
						obj: reviews
						map:
							review: 'content'
							rating: (rating) -> rating/100 * 5
				cb widgets
