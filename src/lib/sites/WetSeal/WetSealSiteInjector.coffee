define -> d: ['DataDrivenSiteInjector'], c: ->
	parseImageUrl = (url) ->
		matches = url.match /Sites-wetseal-Site\/Sites-WS-MASTER\/default\/v[^\/]*\/(\d{8})(\d*)_/i
		return null if !matches
		"#{matches[1]}_#{matches[2]}"
	class WetSealSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode: 2
			overlayZIndex:1
			image: 'a:not(.thumbnail-link) img[src^="http://demandware.edgesuite.net/sits_pod21/dw/image/v2/AANJ_PRD/on/demandware.static/Sites-wetseal-Site/Sites-WS-MASTER"]'
			productSid: (href, a, img) ->
				parseImageUrl img.attr('src')

		productPage:
			mode: 2
			test: -> $('h1.product-name').length
			productSid: -> parseImageUrl $('img[itemprop="image"]').attr 'src'
			image: 'img[itemprop="image"]'
			attach: 'body'
			position: 'img[itemprop="image"]'
			zIndex:999

			# initPage: ->
			# initProduct: ->