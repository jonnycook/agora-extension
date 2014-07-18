define -> d: ['DataDrivenSiteInjector'], c: ->
	class ToysRUsSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="http://www.toysrus.com/product/"] img, a[href^="/product/"] img'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.toysrus\.com\/product\/index\.jsp\?productId=([^&]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: -> document.location.href.match(/^http:\/\/www\.toysrus\.com\/product\/index\.jsp\?productId=([^&]+)/)[1]
			imgEl: 'img.flyoutZoomImg'
			waitFor: '#marker'
			overlayEl: '#marker'
			overlayZIndex: '999999999'

			# imgEl: '.flyoutZoomImg'
			# waitFor: '.flyoutZoomImg'
			# overlayEl: '#marker'