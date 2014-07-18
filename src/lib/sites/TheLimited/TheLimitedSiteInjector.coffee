define -> d: ['DataDrivenSiteInjector'], c: ->
	class TheLimitedSiteInjector extends DataDrivenSiteInjector
		parseUrl: (url) ->
			id = /\/(\d+)[^\/]*?.html/.exec(url)?[1]
			if !id
				return null
			color = /_colorCode=(\d*)/.exec(url)?[1]
			if !color
				return id

			size = /_size=(\w*)/.exec(url)?[1]
			if !size
				return "#{id}-#{color}"

			"#{id}-#{color}-#{size}"

		productListing:
			mode: 2
			image: 'a:not(.swatchanchor) img'

		productPage:
			test: -> $('#printProductSetImages').length
			productSid: ->
				if $('.zoomPad > img').length
					[__, id, color] = /([^\/]*?)_(\d*)_\d*\.jpg/.exec($('.zoomPad > img').attr('src'))
					parts = [id, color]
					size = $('.swatches.size li.selected a').attr('rel')
					parts.push size if size
					parts.join '-'
			imgEl: '.zoomPad > img'
			overlayEl: '.zoomPup'

			# initPage: ->
			# initProduct: ->