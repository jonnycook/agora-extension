define -> d: ['DataDrivenSiteInjector'], c: ->
	class AsosSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a img[src^="http://images.asos-media.com/inv/media/"]'
			productSid: (href, a, img) ->
				matches = /^http:\/\/images\.asos-media\.com\/inv\/media\/\d*\/\d*\/\d*\/\d*\/(\d*)/.exec img.attr 'src'
				# if !matches
					# matches = /http:\/\/images\.asos-media\.com\/inv\/groups\/(\d*)/.exec img.attr 'src'

				matches?[1]

		productPage:
			mode:2
			test: -> $('meta[name="og:type"]').attr('content') == 'product'
			productSid: ->
				colorSelect = $('#ctl00_ContentMainPage_ctlSeparateProduct_drpdwnColour')
				if colorSelect.prop('disabled') || colorSelect.val() == "-1"
					document.location.href.match(/(?:\?|&)iid=(\d*)/)[1]
				else
					color = colorSelect.val()
					# console.debug color, $('#dataDictionary').html().match("\"\\d*#{color}\":\\{\"Sku\":\".*(\\d+)\"\\}")
					$('#dataDictionary').html().match("\"\\d*#{color}\":\\{\"Sku\":\".*?(\\d+)\"\\}")[1]

			image: '#productImages img'
			attach: '#productImages'
			position: '#ctl00_ContentMainPage_imgMainImage'


			# initPage: ->
			# 	that = @
			# 	$('body').delegate '#productImages img', 'mouseenter', ->
			# 		that.initProductEl @, {productSid:that.productPage.productSid()}, overlay:false

			# initProduct: ->
			# 	@waitFor '#productImages', (el) =>
			# 		@initProductEl el, {productSid:@productPage.productSid()}, image:false




