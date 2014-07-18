define -> d: ['DataDrivenSiteInjector'], c: ->
	class CostcoSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a:not([href="#"]) img[src^="http://images.costco.com/image/media/"]'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.costco\.com\/[^\.]*?\.product\.([^\.]+)/)?[1]
				# "#{id}:#{name}"

				sid = name
				if !sid
					href = unescape href
					match = /(http:\/\/www\.costco.com\/.*?)(?:&|$)/.exec(href)?[1]
					if match
						sid = match
				sid



		productPage:
			mode:2
			test: -> $('#large_images').length
			productSid: -> document.location.href.match(/^http:\/\/www\.costco\.com\/[^\.]*?\.product\.([^\.]+)/)[1]
			image: '#large_images li img'
			attach: '.gallery_box.thumbnail-viewer'
			# overlayEl: '.mousetrap'


			# initPage: ->
			# initProduct: ->
