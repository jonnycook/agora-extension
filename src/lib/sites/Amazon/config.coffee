hasProductClass: true
slug: 'amazon'
hosts: ['www.amazon.com']
scraper: true
currency: 'dollar'
icon: 'http://www.amazon.com/favicon.ico'
productUrl: (sid) -> "http://www.amazon.com/gp/product/#{sid}"
query: (product) -> sku:product.get 'productSid'