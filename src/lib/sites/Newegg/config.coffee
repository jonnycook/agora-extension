		excludedFeatures: ['offers', 'deals', 'reviews', 'rating']
		hasMore: false
		slug: 'newegg'
		hosts: ['www.newegg.com']
		currency: 'dollar'
		scraper: true
		icon: 'http://www.newegg.com/favicon.ico'
		productUrl: (sid) ->
		query: (product) -> 
			more = product.get('more')
			model = null

			for section,details of more.details
				for name,value of details
					if name == 'Model'
						model = value
						break
				break if model
			sku:product.get('productSid')
			brand:product.get('more').brand.name
			model:model
