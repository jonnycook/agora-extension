define ['scraping/SiteProduct', 'underscore', 'util'], (SiteProduct, _, util) ->
	class FreePeopleProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = _.mapValues more.images, (images) ->
					_.map images, (image) ->
						small:image.detailSize
						medium:image.detailSize
						large:image.detailSize
						larger:image.zoomSize
						full:image.zoomSize
				cb images, more.color


		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				cb @genWidgets more,
					description:'Description'
					sizingDescription: 'Sizing'
					sizes:'Sizes'
					colors:
						title: 'Colors'
						map: 'name'
					reviews:
						obj:reviews