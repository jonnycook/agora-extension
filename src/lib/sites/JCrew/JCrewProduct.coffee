define ['scraping/SiteProduct', 'util'], (SiteProduct, util) ->
	class JCrewProduct extends SiteProduct
		variantImage: (variant, cb) ->
			@product.with 'more', (more) =>
				if more
					cb more.colorImages?[variant.Color]
				else
					cb()

		images: (cb) ->
			@product.with 'more', (more) =>
				if more
					otherImages = _.map more.images, (image) ->
						small:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=10'
						medim:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=6'
						large:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=3'
						larger:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=2'
						full:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=1'

					images = _.mapValues more.colorImages, (image) ->
						[
							small:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=10'
							medium:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=6'
							large:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=3'
							larger:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=2'
							full:image.match(/^([^?]*)/)[1] + '?fmt=jpeg&op_sharpen=0&resMode=sharp2&scl=1'
						].concat otherImages
					cb images, more.color
				else
					cb()

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					colors:
						title: 'Colors'
						map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews
				cb widgets