define -> d: ['SiteInjector', 'views/ShoppingBarView', 'DataDrivenSiteInjector'], c: ->
	class ZapposSiteInjector extends DataDrivenSiteInjector
		siteName: 'Zappos'

		productListing:
			mode:2
			selectors:
				'a[rel=product] img, a.product img, .productReviews a img':
					productData: (href, a, img, el) ->
						matches = /http:\/\/[^.]*.zassets.com\/images\/[a-z]*\/\d\/.*?\/(\d*)-[a-z]-\w*\.jpg/.exec img.attr 'src'
						if matches
							{productUrl:href, retrievalId:matches[1]}

		productPage:
			mode:2
			test: -> $('#content.productPage').length
			image: '#detailImage img, #detailImage2 img, #actors img'
			attach: '#prdImage'
			productSid: ->
				sku = $('#sku').html().match('^SKU (\\d+)')[1]
				colorId = $('#color').val()
				"#{sku}-#{colorId}"



		initProduct: ->
			sku = $('#sku').html().match('^SKU (\\d+)')[1]
			colorId = $('#color').val()
			
			productSid = "#{sku}-#{colorId}"
			
			@buttonView.represent siteName:@siteName, productSid:productSid
			
			@products '#detailImage img', siteName:@siteName, productSid:productSid
			@products '#detailImage2 img', siteName:@siteName, productSid:productSid
			@bottomBarView.activeProduct = siteName:@siteName, productSid:productSid

		runOff: ->			
			@initPage =>
				@bottomBarView = new ShoppingBarView @contentScript
				@bottomBarView.el.appendTo document.body
				@bottomBarView.represent()
				
				# @buttonView = new ButtonView @contentScript, @button.el
				
				# if @pageType == 'product'
				# 	@initProduct()
					
				# 	$('#color').change => @initProduct()
				# 	$('#stage-swatches a').click => 
				# 		setTimeout (=> @initProduct()), 10
			
				initProduct = (el, retrievalId, url, mousedover) =>
					@initProductEl el, {productUrl:url, retrievalId:retrievalId}, {hovering:mousedover}

				selector = 'a[rel=product] img, a.product img, .productReviews a img'

				window.initProducts = initProducts = ->
					$(selector).each ->
						matches = /http:\/\/[^.]*.zassets.com\/images\/[a-z]*\/\d\/.*?\/(\d*)-[a-z]-\w*\.jpg/.exec $(@).attr 'src'
						if matches
							a = $(@).parents 'a'
							initProduct @, matches[1], a.prop('href'), false
							# @initProductEl @, {productUrl:$(@).prop('href'), productSid:matches[1], siteName:@siteName}

						# unless $(@).data('agora') || $(@).parents('.-agora').length
						# 	img = $(@).find 'img'
						# 	if img.length
						# 		initProduct img, $(@).get(0).href, false
				initProducts()
				# setTimeout initProducts, 5000

				setInterval initProducts, 2000


				currentSid = ->
					sku = $('#sku').html().match('^SKU (\\d+)')[1]
					colorId = $('#color').val()
					
					"#{sku}-#{colorId}"


				$('body').delegate '#actors .actor img', 'mouseover', (e) =>
					@clearProductEl e.target
					@initProductEl e.target, {productSid:currentSid()}, overlay:false 

				$ =>
					@initProductEl $('#protagonist'), {productSid:currentSid()}, image:false, initOverlay: (overlay) ->
						overlay.addAlwaysShow 'productPage'
						overlay.autoFixPosition()

				# $('body').delegate '#naviCenter a, #toggleSaleItems, #breadCrumbs a, #resultWrap .sortby a, #resultWrap .pagination a', 'click', ->
				# 	canaryEl = $ '<div style="display:none" id="agora-canaryEl" />'
				# 	$('#searchResults').append canaryEl
				# 	timerId = setInterval (->
				# 		if !$('#agora-canaryEl').length
				# 			# console.log 'loaded'
				# 			canaryEl.remove()
				# 			clearInterval timerId
				# 			initProducts()
				# 		else 
				# 			console.log 'not loaded'
				# 	), 100
				# 	console.log 'clicked'

# 				$('body').delegate selector, 'mouseover', ->
# 					unless $(@).data('agora') || $(@).parents('.-agora').length
# 						img = $(@).find 'img'
# 						if img.length
# # 							productId = styleId = null
# # 							
# # 							unless productId
# # 								productId = $(@).attr 'data-product-id'
# # 							
# # 							unless productId
# # 								matches = /ProductId-(\d+)/.exec img.attr('class')
# # 								if matches
# # 									productId = matches[1]
# # 								
# # 							unless productId
# # 								matches = /product-(\d+)/.exec $(@).attr('class')
# # 								if matches
# # 									productId = matches[1]
# # 							
# # 							unless productId
# # 								matches = /SKU-(\d+)/.exec $(@).attr('class')
# # 								if matches
# # 									productId = matches[1]
# # 							
# # 							matches = /(\d+)-/.exec img.attr('src')
# # 							styleId = matches[1]
# # 							
# # 							initProduct img, "#{productId}-#{styleId}"
#  							initProduct img, $(@).get(0).href, true
								
# 					$(@).data 'agora', true
					
					
				true
