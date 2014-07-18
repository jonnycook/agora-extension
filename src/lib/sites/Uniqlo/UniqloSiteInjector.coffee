define -> d: ['DataDrivenSiteInjector'], c: ->
	class UniqloSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a img[src^="//uniqlo.scene7.com/is/image/UNIQLO/goods_"], a img[src^="http://uniqlo.scene7.com/is/image/UNIQLO/goods_"]'
			productSid: (href, a, img) ->
				matches = /^(?:http:)?\/\/uniqlo\.scene7\.com\/is\/image\/UNIQLO\/goods_(\d+)_(\d+)/.exec img.attr 'src'
				if matches
					"#{matches[2]}-#{matches[1]}"

		productPage:
			mode:2
			image: '.pdp-images img'
			attach: 'body'
			# position: '.pdp-images img'
			test: -> $('meta[property="og:type"]').attr('content') == 'og:product'
			productSid: ->
				matches = $('.pdp-image-main-media [itemprop=image]').attr('src').match(/UNIQLO\/goods_(\d*)_(\d*)/)		
				"#{matches[2]}-#{matches[1]}"
