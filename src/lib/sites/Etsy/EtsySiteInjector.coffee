define -> d: ['DataDrivenSiteInjector'], c: ->
	class EtsySiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="/listing/"] img, a[href^="http://www.etsy.com/listing/"] img, a[href^="https://www.etsy.com/listing/"] img, a[href^="//www.etsy.com/listing/"] img'
			overlayPosition: 'topLeft'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/etsy\.com\/listing\/([^\/]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			mode: 2
			test: -> $('meta[name="twitter:card"]').attr('value') == 'product'
			productSid: -> document.location.href.match(/etsy\.com\/listing\/([^\/]+)/)[1]
			image: '#image-0 img'
			attach: '#image-main'
			# waitFor: '#featuredImg'
			# overlayEl: '#zoomImgOverlay'


			# initPage: ->
			# initProduct: ->