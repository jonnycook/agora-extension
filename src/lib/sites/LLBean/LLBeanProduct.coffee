define ['scraping/SiteProduct', 'util', 'underscore'], (SiteProduct, util, _) ->
	class LLBeanProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				otherImages = for image in more.images
					small:image
					medium:image
					large:image
					larger:image
					full:image

				images = {}
				for color,image of more.colorImages
					images[color] = [
						small:'http://cdni.llbean.com/is/image/' + image
						medium:'http://cdni.llbean.com/is/image/' + image
						large:'http://cdni.llbean.com/is/image/' + image
						larger:'http://cdni.llbean.com/is/image/' + image
						full:'http://cdni.llbean.com/is/image/' + image
					].concat otherImages

				cb images

		widgets: (cb) ->
			@product.with 'more', 'reviews', (more, reviews) =>
				defs =
					description: 'Description'
					details: 'Details'
					sizes: 'Sizes'

				for name,values of more.properties
					defs[name] =
						obj:values
						title:name

				_.merge defs, 
					colors: 'Colors'
					reviews:
						obj: reviews
						map:
							review: 'content'

				widgets = @genWidgets more, defs

				cb widgets