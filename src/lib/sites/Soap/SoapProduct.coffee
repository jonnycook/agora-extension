define ['scraping/SiteProduct'], (SiteProduct) ->
	class SoapProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				images = []
				cb {'':images}, ''