define -> d: ['DataDrivenSiteInjector'], c: ->
	class SoapSiteInjector extends DataDrivenSiteInjector
		parseUrl: (url) -> /^http:\/\/www\.soap\.com\/p\/.*-(\d*)$/.exec(url)?[1]

		productListing:
			mode:2
			image: 'a[href^="/p/"] img:not(#pdpMainImageImg)'

		productPage:
			imgEl: '#pdpMainImageImg'
			overlayEl: '.MagicZoomPup'