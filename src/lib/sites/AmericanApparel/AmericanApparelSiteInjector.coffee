define -> d: ['DataDrivenSiteInjector'], c: ->
	class AmericanApparelSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode:2
			image: 'a:not(#zoom1) img[src^="http://s7d9.scene7.com/is/image/AmericanApparel/"]'

			overlay: '.product .slashes'
			overlayImage: (overlay) ->
				overlay.parent().find 'img[src^="http://s7d9.scene7.com/is/image/AmericanApparel/"]'

			each: (img) ->
				console.log img

			productSid: (href, a, img) ->
				matches = /^http:\/\/s7d9\.scene7\.com\/is\/image\/AmericanApparel\/([^_]*)_(.*?)(?:\?|$)/.exec(img.attr('src'))
				if matches
					"#{matches[1]}-#{matches[2]}"

		productPage:
			test: -> $('#product_img').length
			productSid: ->
				matches = /^http:\/\/s7d9\.scene7\.com\/is\/image\/AmericanApparel\/([^_]*)_(.*?)(?:\?|$)/.exec($('#product_img').attr('src'))
				"#{matches[1]}-#{matches[2]}"
			imgEl: '#product_img'
			overlayEl: '.mousetrap'