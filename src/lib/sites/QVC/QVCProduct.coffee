define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class QVCProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				otherImages = []
				for image in more.images.pics
					image = image.match(/^(.*?)\?/)[1]
					otherImages.push
						small:image + '?scl=1&fmt=jpeg'
						medium:image + '?scl=1&fmt=jpeg'
						large:image + '?scl=1&fmt=jpeg'
						larger:image + '?scl=1&fmt=jpeg'
						full:image + '?scl=1&fmt=jpeg'

				images = {}
				for color, image of more.images.colorPics
					imgs = []
					image = image.match(/^(.*?)\?/)[1]
					imgs.push
						small:image + '?scl=10&fmt=jpeg'
						medium:image + '?scl=6&fmt=jpeg'
						large:image + '?scl=3&fmt=jpeg'
						larger:image + '?scl=2&fmt=jpeg'
						full:image + '?scl=1&fmt=jpeg'

					imgs = imgs.concat otherImages
					images[color] = imgs


				longId = @product.get('productSid').split('-')[1]
				shortId = null
				if longId
					for color in more.colors
						if color.longId == longId
							shortId = color.shortId
							break

				cb images, shortId	