define -> d: ['DataDrivenSiteInjector'], c: ->
	class HMSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode: 2
			selectors:
				'a[href^="http://www.hm.com/us/product/"] img':
					productData: (href, a, img) ->
						matches = href.match /[?&]article=(.*?)(?:$|&)/
						if matches
							productSid:matches[1]


				'a[href^="http://www.hm.com/us/product/"] + .image':
					image: (el) -> el.find('img:last')
					anchor: (el) -> el.prev()
					anchorProxy: true
					productData: (href) ->
						matches = href.match /[?&]article=(.*?)(?:$|&)/
						if matches
							productSid:matches[1]

		productPage:
			mode:2
			test: -> $('meta[property="og:type"]').attr('content') == 'website'
			productSid: ->
				matches = document.location.href.match /#article=(.*)/
				if matches
					matches[1]
				else
					matches = document.location.href.match /[?&]article=(.*?)(?:#|$|&)/
					if matches
						matches[1]

			image: '#product-image-box > .zoom-pan > img'
			attach: '#content'
