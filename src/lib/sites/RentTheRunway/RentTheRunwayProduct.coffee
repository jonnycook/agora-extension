define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class RentTheRunwayProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				if more?.images
					images = for image in more.images
						file = /\/([^\/]*)$/.exec(image)[1]

						small:'https://cdn.rtrcdn.com/sites/default/files/imagecache/acsr_small_image/product_images/' + file
						medium:'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file
						large:'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file
						larger:'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file
						full:'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file
					cb {'':images}, ''
				else
					cb()

		reviews: (cb) ->
			@product.with 'reviews', (reveiws) =>
				cb reviews:util.mapObjects reviews, rating: (review) -> review.rating/10 * 5


		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					details: 'Details'
					sizeInfo: 'Size Info'
					sizes: 'Sizes'
					styleNotes: 'Style Notes'
					reviews:
						obj: reviews
						# maxHeight:100
						# count:3
						map:
							# review: 'content'
							rating: (review) -> review.rating/10 * 5
				cb widgets