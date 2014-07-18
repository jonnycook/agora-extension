define ['scraping/SiteProduct', 'ext/AmazonProductWidgets'], (SiteProduct, AmazonProductWidgets) ->
	class AmazonProduct extends SiteProduct
		matchFeature: (cb, predicate) ->
			@product.with 'more', (more) =>
				if more.features
					for feature in more.features
						value = predicate feature
						if value
							cb value
							return
				cb()

		widgets:AmazonProductWidgets

		# imageWithSize: (url) ->
		# colors: (cb) ->
		# 	@product.with 'more', (more) =>
		# 		colors = {}
		# 		for name,images of more.images 
		# 			colors[name] = images.large.match('$(.*?)\.jpg^')[1] + '_SL100_.jpg'

		images: (cb) ->
			@product.with 'more', (more) =>
				images = {}
				for color,colorImages of more.images 
					images[color] = []
					for image in colorImages
						images[color].push
							small:image.large.match('^(.*?)\.jpg$')[1] + '._SL100_.jpg'
							medium:image.large
							large:image.hiRes ? image.large
							larger:if image.hiRes then image.hiRes.replace(/(\.[^.]*)(\.jpg)$/, '._SL1000_$2') else image.large
							full:if image.hiRes then image.hiRes.replace(/(\.[^.]*)(\.jpg)$/, '$2') else image.large
				cb images, more.currentStyle

		reviews: (cb) -> @product.with 'reviews', cb

		type: (cb) ->
			map =
				'Nursing & Maternity Bras': 'brassiere'

			@product.with 'more', (more) =>
				cb map[more.category[more.category.length - 1]]

		types:
			garment:
				'Wash Instructions': (cb) ->
					@product.with 'more', (more) =>
						if more.features
							for feature in more.features
								if feature.toLowerCase().match('wash') || feature.toLowerCase().match('dry clean')
									cb feature
									return
						cb undefined

				'Origin': (cb) ->
					@product.with 'more', (more) =>
						if more.features
							for feature in more.features
								if feature.toLowerCase().match('china|made in|imported')
									cb feature
									return
						cb more.details?.Origin


				'Materials': (cb) ->
					@product.with 'more', (more) =>
						materialSample = 'polyester|cotton|polyamide|elastane|nylon|spandex|rayon|Lycra&reg;|spandex|viscose|recycled|polyester|linen|Tactel&reg;|nylon|acrylic|down|feather|polyurethane|cashmere|corduroy|denim|angora|wool|satin|taffeta|leather|twill|acetate|lycra|lyocell|tweed|canvas|ripstop|sheepskin|silk|velvet|chiffon|jersey|suede|velour|vinyl|tricot|fleece|modal|microfiber|mesh'
						highest = 0
						highestIndex = -1
						if more.features
							for item, i in more.features
								# if item.indexOf('%') != -1
									matches = item.toLowerCase().match materialSample, 'g'
									if matches
										if matches.length > highest
											highestIndex = i
											highest = matches.index

							if highestIndex != -1
								cb more.features[highestIndex]
							else
								cb undefined
						else
							cb undefined

			trousers: 
				'Closure': (cb) ->
					@product.with 'more', (more) =>
						if more.features
							for feature in more.features
								if feature.toLowerCase().match('closure')
									cb feature
									return
						cb()

			brassiere:
				'Closure': (cb) ->
					@product.with 'more', (more) =>
						if more.feature
							for feature in more.features
								if feature.toLowerCase().match('closure')
									cb feature
									return
						cb()
				'Straps': (cb) ->
					@product.with 'more', (more) =>
						if more.features
							for feature in more.features
								if feature.toLowerCase().match('straps')
									cb feature
									return
						cb()


			'video card':
				'Core Clock': (cb) ->
					@matchFeature cb, (feature) -> feature.match(/^Core Clock: (.*)$/)?[1]

				'Boost Clock': (cb) ->
					@matchFeature cb, (feature) -> feature.match(/^Boost Clock: (.*)$/)?[1]

				'GPU': (cb) ->
					@matchFeature cb, (feature) -> feature.match(/^Chipset: (.*)$/)?[1]

				'Interface': (cb) ->
					@matchFeature cb, (feature) -> if feature.toLowerCase().match('pci express') then feature


			# trousers:
			# 	'Materials': (cb) ->
			# 		cb 'materials'
