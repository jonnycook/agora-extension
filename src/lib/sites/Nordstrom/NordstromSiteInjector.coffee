define -> d: ['DataDrivenSiteInjector'], c: ->
	parseUrl = (url) -> url.match(/^http:\/\/shop\.nordstrom\.com\/s\/(?:[^\/]*\/)?(\d*)/i)?[1]

	class NordstromSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode:2
			image: 'a img[src^="http://g.nordstromimage.com/imagegallery/store/product/"]'
			productSid: (href, a, img) ->
				sid = parseUrl href
				if !sid
					href = unescape href
					match = /(http:\/\/shop\.nordstrom\.com\/.*?)(?:&|$)/.exec(href)?[1]
					if match
						sid = parseUrl match
				sid

		productPage:
			test: -> document.location.href.match(/^http:\/\/shop\.nordstrom\.com\/s\/(?:[^\/]*\/)?(\d*)/i)
			productSid: ->
				id = document.location.href.match(/^http:\/\/shop\.nordstrom\.com\/s\/(?:[^\/]*\/)?(\d*)/i)[1]
				if $('.selector.color.narrow select').prop('selectedIndex')
					color = $('.selector.color.narrow select option:selected').text().trim()
					"#{id}-#{color}"
				else
					id

			imgEl: '#advancedImageViewer .fashion-photo-wrapper img'
			overlayEl: '#advancedImageViewer .dragImage'
