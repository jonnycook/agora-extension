define -> d: ['DataDrivenSiteInjector'], c: ->
	class SearsSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a img[src^="http://c.shld.net/rpx/"]'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.sears\.com\/[^\/]*\/p-([^?]*)/)?[1]
				if !name
					name = href.match(/^http:\/\/www\.sears\.com\/shc\/s\/p_.*?_.*?_([^_?]*)(?:\?|$)/)?[1]


				sid = name
				if !sid
					href = unescape href
					match = /(www\.sears\.com\/.*?)/.exec(href)?[1]
					if match
						sid = match
					# console.debug "asdf" , href		
				sid



		productPage:
			test: -> $('meta[name="viewport"]').length
			productSid: -> 
				sid = document.location.href.match(/^http:\/\/www\.sears\.com\/shc\/s\/p_.*?_.*?_([^_?]*)(?:\?|$)/)?[1]
				if !sid
					sid = document.location.href.match(/^http:\/\/www\.sears\.com\/[^\/]*\/p-([^?]*)/)?[1]
				sid
			imgEl: 'div[data-id="product-image-main"] img'
			waitFor: 'div[data-id="product-image-main"] img'
			# overlayEl: '.mousetrap'

		# productPage:
		# 	mode:2
		# 	test: -> $('.productoverview-page').length
		# 	productSid: -> document.location.href.match(/^http:\/\/www\.costco\.com\/[^\.]*?\.product\.([^\.]+)/)[1]
		# 	image: '#large_images li img'
		# 	attach: '.gallery_box.thumbnail-viewer'
