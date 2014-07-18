define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class WetSealProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				allImages = {}
				for colorId,images of more.images
					allImages[colorId] = for image in images
						small:image
						medium:image
						large:image
						larger:image
						full:image
				cb allImages, @product.get('productSid').split('_')[1]

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					details: 'Details'
					colors:
						title: 'Colors'
						map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews
						map:
							review: 'content'
				cb widgets
