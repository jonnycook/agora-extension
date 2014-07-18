define ['scraping/SiteProduct', 'util', 'underscore'], (SiteProduct, util, _) ->
	class BloomingdalesProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				for color, colorImages of more.images
					images[color] = for image in colorImages
						small:"http://images.bloomingdales.com/is/image/BLM/products/#{image}?wid=325&qlt=90,0&layer=comp&op_sharpen=0&resMode=sharp2&op_usm=0.7,1.0,0.5,0&fmt=jpeg"
						medium:"http://images.bloomingdales.com/is/image/BLM/products/#{image}?wid=325&qlt=90,0&layer=comp&op_sharpen=0&resMode=sharp2&op_usm=0.7,1.0,0.5,0&fmt=jpeg"
						large:"http://images.bloomingdales.com/is/image/BLM/products/#{image}?wid=325&qlt=90,0&layer=comp&op_sharpen=0&resMode=sharp2&op_usm=0.7,1.0,0.5,0&fmt=jpeg"
						larger:"http://images.bloomingdales.com/is/image/BLM/products/#{image}?wid=325&qlt=90,0&layer=comp&op_sharpen=0&resMode=sharp2&op_usm=0.7,1.0,0.5,0&fmt=jpeg"
						full:"http://images.bloomingdales.com/is/image/BLM/products/#{image}?wid=325&qlt=90,0&layer=comp&op_sharpen=0&resMode=sharp2&op_usm=0.7,1.0,0.5,0&fmt=jpeg"
				cb images, more.color

		reviews: (cb) ->
			@product.with 'reviews', (reviews) ->
				cb reviews:reviews ? []

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					details: 'Details'
					sizes: 'Sizes'
					colors: 'Colors'
					reviews:
						obj:reviews
				cb widgets