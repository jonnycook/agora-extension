define -> d: ['DataDrivenSiteInjector'], c: ->
	class BarnesAndNobleSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="http://www.barnesandnoble.com/w/"] img, a[href^="http://www.barnesandnoble.com/p/"] img, a[href^="http://www.barnesandnoble.com/v/"] img'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.barnesandnoble\.com\/.\/.*?\/([^?]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: -> document.location.href.match(/^http:\/\/www\.barnesandnoble\.com\/.\/.*?\/([^?]+)/)[1]
			imgEl: '#product-image-smaller-1 div img'
			waitFor: '#product-image-smaller-1 div img'
			# overlayEl: '.mousetrap'


			# initPage: ->
			# initProduct: ->