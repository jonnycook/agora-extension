define -> d: ['DataDrivenSiteInjector'], c: ->
	class LLBeanSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a[href*="/llb/shop/"] img'
			productSid: (href, a, img) -> href.match(/\/llb\/shop\/(\d*)/)?[1]

		productPage:
			mode: 2
			productSid: ->
				id = document.location.href.match(/\/llb\/shop\/(\d*)/)?[1]
				color = $('.pdSelectedSwatch:visible').find('img').attr('name')
				if color
					"#{id}-#{color}"
				else
					id

			image: 'img[id^="foreImageSjElement"]'
			attach: 'body'
			overlay: 'div[id^="mapImageSjElement"]'