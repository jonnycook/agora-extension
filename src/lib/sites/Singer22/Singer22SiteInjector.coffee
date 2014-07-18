define -> d: ['DataDrivenSiteInjector'], c: ->
	class Singer22SiteInjector extends DataDrivenSiteInjector
		productListing:
			init: ->
				if $('#category-rotator-category-container')
					parseUrl = (url) ->
						id = null
						if !id
							id = url.match(/http:\/\/cdn2\.singer22\.com\/static\/insets\/[^\/]*\/([^_]*)/)?[1]
						if !id 
							id = url.match(/^http:\/\/\d*\.images\.singer22\.com\/static\/(?:products|insets)\/[^\/]*\/([^.]*)/)?[1]
						if !id
							id = url.match(/^http:\/\/cdn2\.singer22\.com\/static\/(?:products|insets)\/[^\/]*\/([^.]*)/)?[1]

						id.toLowerCase() if id

					Q.setInterval (=>
						for el in $('#category-rotator-category-container img')
							el = $ el
							id = parseUrl el.attr 'src'
							if id
								if el.data('agora-productSid') != id
									el.parent().css 'position', 'relative'
									el.parent().removeAttr 'agora'
									@removeOverlay el.parent()
									@attachOverlay
										attachEl:el.parent()
										positionEl:el
										productData:{productSid:id}

									@clearProductEl el
									@initProductEl el, {productSid:id}, overlay:false
									Q(el).data('agora-productSid', id)
					), 500

			mode: 2
			selectors:
				'a[href*="sku="] img':
					overlayPosition: 'topLeft'
					productData: (href, a, img) ->
						matches = href.match /[?&]sku=(.*?)(?:$|&|#)/
						if matches
							productSid:matches[1]


				'.item.pinproduct':
					image: (el) -> el.find('.rotator ul li:first img')
					anchor: (el) -> el.find('.rotator .mask')
					anchorProxy: true
					productData: (href, a, img, el) ->
						href = el.find('[itemprop="url"]').attr 'href'
						matches = href.match /[?&]sku=(.*?)(?:$|&|#)/
						if matches
							productSid:matches[1]
					overlayPosition: 'topLeft'

		productPage:
			mode:2
			test: -> $('div#styleData[itemtype="http://schema.org/Product"]').length
			productSid: ->
				matches = document.location.href.match /[?&]sku=(.*?)(?:$|&|#)/
				if matches
					matches[1]

			variant: -> 
				if $('#productColors .productColorSelected').attr('title')
					Color:$('#productColors .productColorSelected').attr('title')

			image: '#productMainThumb'
			attach: '#styleData'
			zIndex:999
