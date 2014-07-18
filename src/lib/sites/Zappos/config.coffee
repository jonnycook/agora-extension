excludedFeatures: ['deals', 'offers']
hasProductClass: true
slug: 'zappos'
hosts: ['www.zappos.com']
currency: 'dollar'
scraper: true
hasMore: true
icon: 'http://www.zappos.com/favicon.ico'

productUrl: (sid) -> 
	[productId, colorId] = sid.split('-')
	if colorId
		"http://www.zappos.com/viewProduct.do?productId=#{productId}&colorId=#{colorId}"
	else
		"http://www.zappos.com/viewProduct.do?productId=#{productId}"

query: (product) -> brand:product.get('more').brand.name, title:product.get('more').name
