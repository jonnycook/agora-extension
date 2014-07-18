define ['scraping/SiteProduct', 'underscore'], (SiteProduct, _) ->
	class AsosProduct extends SiteProduct
		images: (cb) ->
			@product.with 'more', (more) =>
				if more.color
					otherImages = _.map more.images, (image) ->
						small:image.small
						medium:image.medium
						large:image.large
						larger:image.large
						full:image.large

					images = _.mapValues more.colorImages, (image) ->
						[
							small:image.small
							medium:image.xlarge
							large:image.xlarge
							larger:image.xlarge
							full:image.xxlarge
						].concat otherImages
					cb images, more.color.toLowerCase().replace(/\s+/g, '')
				else
					image = more.colorImages[_.keys(more.colorImages)[0]]
					images = [
						small:image.small
						medium:image.xlarge
						large:image.xlarge
						larger:image.xlarge
						full:image.xxlarge
					].concat _.map more.images, (image) ->
						small:image.small
						medium:image.medium
						large:image.large
						larger:image.large
						full:image.large

					cb {'':images}, ''

		widgets: (cb) ->
			@product.with 'more', (more) =>
				widgets = @genWidgets more,
					description:
						title:'Description'
						maxHeight:'none'
					aboutMe: 'About Me'
					lookAfterMe: 'Look After Me'
					sizes: 'Sizes'
				cb widgets