define ['scraping/SiteProduct'], (SiteProduct) ->
	class DiapersProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = []
				cb {'':images}, ''