define -> d: ['DataDrivenSiteInjector'], c: ->
	class BloomingdalesSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode:2
			image: 'a img[src^="http://images.bloomingdales.com/is/image/BLM/"]'
			position: (el) -> 
				parent = el.parents('.productImages')
				if parent.length
					parent
				else 
					el
			overlayZIndex:999
			productSid: (href, a, img) ->
				matches = href.match /[?&]ID=(.*?)(?:$|&|#)/
				if matches
					matches[1]

		productPage:
			mode:2
			initPage: ->
				skus = JSON.parse $('body').html().match(/BLOOMIES.pdp.upcmap\["\d*"\] = (\[[^\]]*\])/)[1]
				@map = {}
				@colorMap = {}
				for sku in skus
					if !@colorMap[sku.color]
						@colorMap[sku.color] = sku.upcID
					@map["#{sku.color}.#{sku.size}"] = sku.upcID


			# test: -> false
			productSid: ->
				id = document.location.href.match(/[?&]ID=(.*?)(?:$|&|#)/)[1]
				color = $('#colorHeadersDiv .pdpColorDesc').html().trim()
				size = $('.pdp_member_size .pdpSizeDesc').html().trim()
				# if size == 'select size'
				id + '-' + @colorMap[color]
				# else
				# 	if @map["#{color}.#{size}"]
				# 		id + '-' + @map["#{color}.#{size}"]
				# 	else
				# 		id + '-' + @colorMap[color]

			image: '#productImage'
			attach: '#pdpContainer'
