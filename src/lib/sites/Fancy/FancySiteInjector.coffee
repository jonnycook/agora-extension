define -> d: ['DataDrivenSiteInjector'], c: ->
	class FancySiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="/things/"] span.back, a[href^="http://fancy.com/things/"] span.back'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/fancy\.com\/things\/([^&]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			test: -> $('#quantity').length
			productSid: -> document.location.href.match(/^http:\/\/fancy\.com\/things\/([^&]+)/)[1]
			imgEl: '.figure img'
			# waitFor: '#product-image-smaller-1 div img'
			# overlayEl: '.mousetrap'


			# initPage: ->
			# initProduct: ->