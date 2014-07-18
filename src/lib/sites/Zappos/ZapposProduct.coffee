define ['scraping/SiteProduct'], (SiteProduct) ->
	class ZapposProduct extends SiteProduct
		baseUrl: 'http://www.zappos.com'
		
		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				for id,style of more.styles
					images[id] = []
					for name,image of style.images
						if image.MULTIVIEW
							images[id].push 
								small:image.MULTIVIEW
								medium:image.MULTIVIEW
								large:image['4x']
								larger:image['4x']
								full:image['4x']

				cb images, more.currentStyle

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				colors = []
				for id, style of more.styles
					colors.push style.color.name

				widgets = @genWidgets more,
					description: 'Description'
					sizes: 'Sizes'
					# details: 'Details'
					colors:
						obj: colors
						title: 'Colors'
						# map: (color) -> util.ucfirst color.name
					reviews:
						obj: reviews

				cb widgets