define -> d: ['DataDrivenSiteInjector'], c: ->
	parseUrl = (url) ->
		url.match(/[?&]productId=(\d*)/)?[1] ? url.match(/\/pro\/(\d*)/)?[1]
	class ExpressSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a img[src*="images.express.com/is/image/expressfashion/"]:not([src*=swatch])'
			productSid: (href, a, img) -> parseUrl href

		productPage:
			mode: 2
			productSid: -> parseUrl document.location.href

			image: '#flyout img[src^="http://images.express.com/is/image/expressfashion"]'
			attach: '#glo-body-content'
			position: '#flyout'
			overlay: '#flyout'
			hideOverlay:false
			zIndex:999
			variant: -> 
				if $('.selectedColor').text()
					Color:$('.selectedColor').text()