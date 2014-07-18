define -> d: ['DataDrivenSiteInjector'], c: ->
	class HomeDepotSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="http://www.homedepot.com/p/"] img, a[href^="/p/"] img'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.homedepot\.com\/p\/[^\/]*\/(\d+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			# mode:2
			test: -> $('meta[property="og:type"]').attr('content')
			productSid: -> document.location.href.match(/^http:\/\/www\.homedepot\.com\/p\/[^\/]*\/(\d+)/)[1]
			image: '#superPIP__productImage'
			attach: '.product_mainimg'
			overlayEl: '.zoomIt_area'
