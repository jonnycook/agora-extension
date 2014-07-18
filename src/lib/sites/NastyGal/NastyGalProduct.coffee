define ['scraping/SiteProduct'], (SiteProduct) ->
	class NastyGirlProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = _.map more.images, (image) -> small:image, medium:image, large:image, larger:image, full:image
				cb {'':images}, ''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description:
						title:'Description'
						maxHeight:'none'
					sizes: 'Sizes'
				cb widgets