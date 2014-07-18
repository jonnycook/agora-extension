define -> d: ['DataDrivenSiteInjector'], c: ->
	parseImgSrc = (src) ->
		matches = src.match(/http:\/\/s7d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/)
		if !matches
			matches = src.match(/http:\/\/a248\.e\.akamai\.net\/f\/248\/9086\/10h\/origin-d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/)
			if !matches
				return null
		"#{matches[1]}_#{matches[2]}"
	class KateSpadeSiteInjector extends DataDrivenSiteInjector
		productListing:
			container: '.product-image'
			overlayZIndex:1
			image: 'a:not(.swatchanchor) img[src^="http://s7d4.scene7.com/is/image/KateSpade/"], a:not(.swatchanchor) img[src^="http://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/KateSpade/"]'
			productSid: (href, a, img) ->
				matches = img.attr('src').match(/http:\/\/s7d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/)
				if !matches
					matches = img.attr('src').match(/http:\/\/a248\.e\.akamai\.net\/f\/248\/9086\/10h\/origin-d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/)
					if !matches
						return null

				"#{matches[1]}_#{matches[2]}"


		productPage:
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: -> 
				id = $('.product-primary-image img').attr('src').match(/\/KateSpade\/([^_]*)_/)[1]
				color = $("input[type=hidden][name=dwvar_#{id}_color]").val()
				"#{id}_#{color}"

			imgEl: '.product-primary-image img'
			waitFor: '.product-primary-image img'
			overlayEl: '.s7zoomview'

			# initPage: ->
			# initProduct: ->