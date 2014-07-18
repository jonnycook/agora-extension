define -> d: ['DataDrivenSiteInjector'], c: ->
	class WomanWithinSiteInjector extends DataDrivenSiteInjector
		parseUrl: (url) ->
			id = url.match(/[?&]pfid=(\d+)/i)?[1]
			if id
				style = url.match(/[?&]styleno=(\d+)/i)?[1]
				if style
					"#{id}-#{style}"
				else
					id

		productListing:
			mode: 2
			overlayZIndex:1
			image: 'a img[src^="http://media.plussizetech.com/womanwithin/"]'
			forcePositioned: true

		productPage:
			mode: 2
			productSid: ->
				if $('#Main_Image_0').length
					id = document.location.href.match(/[?&]pfid=(\d+)/i)?[1]
					style = $('#Main_Image_0').attr('src').match(/.*?\_(\d*).jpg?[^']*/)?[1] 
					if style
						"#{id}-#{style}"
					else
						id
			image: '#Main_Image_0'
			overlay: '#alt_main_image_0 .zoomLink span'
			attach: 'body'
