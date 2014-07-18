define -> d: ['DataDrivenSiteInjector'], c: ->
	class ReiSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="http://www.rei.com/product/"] img, a[href^="/product/"] img'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.rei\.com\/product\/([^\/]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			test: -> $('meta[content^="/product/"]').length
			productSid: -> document.location.href.match(/^http:\/\/www\.rei\.com\/product\/([^\/]+)/)[1]
			imgEl: '#featuredImg'
			# waitFor: '#featuredImg'
			overlayEl: '#zoomImgOverlay'


			# initPage: ->
			# initProduct: ->