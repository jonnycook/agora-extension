define -> d: ['DataDrivenSiteInjector'], c: ->
	class SixPMSiteInjector extends DataDrivenSiteInjector
		productListing: ->
			initProduct = (el, retrievalId, url, mousedover) =>
				@initProductEl el, {productUrl:url, retrievalId:retrievalId}, {hovering:mousedover}

			selector = 'a[rel=product] img, a.product img, .productReviews a img'

			that = @
			window.initProducts = initProducts = ->
				$(selector).each ->
					matches = /http:\/\/(?:[^.]*.zassets.com|www\.6pm\.com)\/images\/[a-z]*\/\d\/.*?\/(\d*)-[a-z]-\w*\.jpg/.exec $(@).attr 'src'
					if matches
						a = $(@).parents 'a'
						m = /http:\/\/www\.6pm\.com\/product\/(\d*)\/color\/(\d*)/.exec(a.prop('href'))
						if m
							that.initProductEl @, {productSid:"#{m[1]}-#{m[2]}"}
						else
							initProduct @, matches[1], a.prop('href'), false
			initProducts()
			Q.setInterval initProducts, 2000


		productPage:
			productSid: ->
				color = $('#color').val()
				sku = $('#sku').text().match(/^SKU: #(\d*)$/)[1]
				"#{sku}-#{color}"
			imgEl: '#detailImage img'