		excludedFeatures: ['offers', 'deals', 'reviews', 'rating']
		hasProductClass:true
		slug: 'sears'
		hosts: ['www.sears.com']
		currency: 'dollar'
		scraper: true
		hasMore:true
		icon: 'http://www.sears.com/favicon.ico'
		productUrl: (sid) -> "http://www.sears.com/-/p-#{sid}"
