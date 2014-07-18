define -> d: ['DataDrivenSiteInjector'], c: ->
	class FabSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a[href^="http://fab.com/product/"] img, a[href^="/product/"] img'
			overlayPosition: 'topLeft'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/fab\.com\/product\/.*-(\d*)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			mode:2
			test: -> $('meta[property="og:type"]').attr('content') == 'fab_graph_dev:product'
			productSid: -> document.location.href.match(/^http:\/\/fab\.com\/product\/.*-(\d*)/)[1]
			overlayPosition: 'topLeft'
			image: '.productPgMainImage'
			attach: '#productpgSliderWrap'
			# overlayEl: '.mousetrap'


			# initPage: ->
			# initProduct: ->