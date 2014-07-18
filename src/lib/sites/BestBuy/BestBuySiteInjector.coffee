define -> d: ['DataDrivenSiteInjector'], c: ->
	class BestBuySiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a img[src^="http://images.bestbuy.com/BestBuy_US/images/products/"]'
			productSid: (href, a, img) -> 
				matches = href.match /^http:\/\/www\.bestbuy\.com\/site\/.*?\/([^\.]+)\.p\?id=([^\&]+)/
				id = matches[1] + "-" + matches[2]


		productPage:
			test: -> $('#product-media-content').length
			productSid: -> 
				matches = document.location.href.match /^http:\/\/www\.bestbuy\.com\/site\/.*?\/([^\.]+)\.p\?id=([^\&]+)/
				id = matches[1] + "-" + matches[2]

			imgEl: '.image-gallery-main-slide a img'
			waitFor: '.image-gallery-main-slide a img'
			# overlayEl: '.mousetrap'


			# initPage: ->
			# initProduct: ->