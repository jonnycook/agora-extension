# define -> d: ['DataDrivenSiteInjector'], c: ->
# 	class DiapersSiteInjector extends DataDrivenSiteInjector
# 		productListing:
# 			imgSelector: 'a img'
# 			productSid: (href, a, img) ->

# 		productPage:
# 			test: -> false
# 			productSid: -> 0
# 			imgEl: ''


define -> d: ['DataDrivenSiteInjector'], c: ->
	class DiapersSiteInjector extends DataDrivenSiteInjector
		parseUrl: (url) -> /^http:\/\/www\.diapers\.com\/p\/.*-(\d*)$/.exec(url)?[1]

		productListing:
			mode:2
			image: 'a[href^="/p/"] img:not(#pdpMainImageImg)'

		productPage:
			imgEl: '#pdpMainImageImg'
			overlayEl: '.MagicZoomPup'