define -> d: ['DataDrivenSiteInjector'], c: ->
	class ModClothSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'li[data-id] a img, a img[src^="http://productshots"]'
			productSid: (href, a, img) ->
				if a.parents('li[data-id]').length
					"#{a.parents('li[data-id]').attr('data-id')}:#{href.match(/[^\/]*$/)[0]}"
				else
					if a.attr('data-analytics-ga')

						id = a.attr('data-analytics-ga').match(/\[%22.*?%22,%22.*?%22,%22\d*:(\d*)/)?[1]

						if id
							name = href.match(/\/-?([^\/]*)$/)?[1]

							if name
								"#{id}:#{name.toLowerCase()}"

		productPage:
			initPage: ->
				$('#image-container').after $('<div id="agora" />').css(zIndex:4, position:'absolute', top:0, left:0)

			mode: 2
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: -> "#{$('.wishlist_btn_container').attr('data-product-id')}:#{document.location.href.match(/([^\/]*?)(?:\?|$)/)[1]}"
			attach: '#agora'
			position: '#image-container'
			image: '#zoomable img'
			# overlayEl:

			# initPage: ->
			# initProduct: ->
