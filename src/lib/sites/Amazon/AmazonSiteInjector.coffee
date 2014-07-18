define -> d: ['BCSiteInjector'], c: ->
	matchProductSid = (url) ->
		matches = new RegExp('(?:/gp/product/|/dp/)([^/]*)').exec url
		if matches
			productSid = matches[1]
			if productSid == 'B004LLIKVU' then return
			productSid

	class AmazonSiteInjector extends BCSiteInjector
		siteName: 'Amazon'
	
		pages: -> `{
			'http://www\.amazon\.com/((.*?/)?dp/|gp/product/)': {
				drag: '#prodImageCell img, .main-image-inner-wrapper img, img#main-image, #imgTagWrapperId img, #imgBlkFront, #fbt_x_img img, #main-image-container .imgTagWrapper img',

				elHook: '.buyingDetailsGrid > tbody',	
				init: function() {
					function onVariationChange() {
						var prevASIN = Client.productID;
						
						var id = setInterval(function() {
							var asin = Client.site.productID();
							
							// The combination selected isn't valid
							if ((!t$('#addToCartButton') || $('#addToCartButton').style.cursor == 'not-allowed') && !t$('.dpSprite.s_seeAllBuying')) {
								clearInterval(id);
								Client.clearProduct();
							}
							
							// Waiting for the combination to load...
							else {
								if (Client.productID) {
									Client.clearProduct(true);
								}
								
								// The combination loaded
								if (asin != prevASIN) {
									Client.productInit();
									clearInterval(id);
								}
							}
						}, 100);
					}
				
					// Variation swatches
					var variations = t$$('.variations .swatchOuter');
					for (var i = 0; i < variations.length; ++ i) {
						var variation = variations[i];
						
						variation.addEventListener('click', function() {
							if (this.firstChild.nextSibling.className == 'swatchSelect') return;
							onVariationChange();
						}, true);
					}
					
					// Variation dropdowns
					variations = t$$('.twister_dropdown');
					for (var i = 0; i < variations.length; ++ i) {
						var variation = variations[i];
						
						variation.addEventListener('change', function() {
							onVariationChange();
						}, true);
					}
					
					
					// Products don't start out with the "real" add to cart button...
					//if (t$('#priceBlock .priceLarge') && $('#priceBlock .priceLarge').textContent.indexOf('-') == -1 || !t$('#priceBlock .priceLarge')) {
					// Products will only start out disabled if there is a dropdown
					if (variations.length == 0) {
						Client.productInit();
					}
					else {
						Client.clearProduct();
					}
				},
				
				productID: function() { var func = function() {
					if (t$('#buyBoxAudible')) {
						return;
					}
					
					//return JSON.parse(t$('#tell-a-friend span.a-declarative').getAttribute('data-a-modal')).url.match(/&id=([^&]*)&/)[1];


					try {
						return t$('#swftext').href.match(/contentID=(.*?)&/)[1]
					}
					catch (e) {
						try {
							return t$('#swfText').href.match(/contentID=(.*?)&/)[1]
						}
						catch (e) {
							throw e;
						}
					}


					http://www.amazon.com/PS3-250GB-Last-Bundle-Playstation-3/dp/B00HK74G2E/?psc=1

					// Some clothes (and possible other types of products) have pages set up for variations, but they don't actually have options (correction: they do have options, but they are hidden swatches...)
					// These pages start out with the wrong ASIN, and switch to it after some indeterminate amount of time. However, the like button starts out with the correct ASIN
					if (t$('.variationSelected') && !(jQuery('.variations .swatchOuter:visible').length || t$('.twister_dropdown'))) {
						return $('.amazonLikeButton').id.split('_')[1];
					}
					else {
						/*if (!this._once || t$('#buyboxDivId') && t$('#buyboxDivId').style.display == 'none') {
							this._once = true;
							
							// Only products with variations have this
							var el = t$('#detail-bullets_feature_div .content > ul');
							if (el) {
								var matches = /<b>ASIN:\s*<\/b>\s*(.*?)<\/li>/.exec(el.innerHTML);
								return matches[1];
							}
							else {
								return $('#ASIN').value;
							}
						}
						else {*/
							return $('#ASIN').value;
						//}
					}
				
					// #ASIN for Amazon Digital Services products starts out as the ASIN for the non-downloadable version, but it seems like this element always contains the correct ASIN
					var alt = t$('#cdPostBoxForm [name=originInstanceID]');
					if (alt) {
						return alt.value;
					}
					else {
						return $('#ASIN').value;
					}
				}
				
				var productID = func();
				console.debug('ProductID:', productID);
				return productID;
				
				}
			}
		}`
		
		initOverlay: (overlayView) ->
			overlayView.el.css 'z-index', 999999

		onInitPage: ->
			$('#page-footer, body').css paddingBottom:74

			$.fn.disableSelection = ->
				# @attr 'unselectable', 'on'
				@css 'user-select', 'none'
				@css '-moz-user-select', 'none'
				@css '-webkit-user-select', 'none'
				# @on('selectstart.disableSelect', false);

			$.fn.enableSelection = ->
				# @unbind('selectstart.disableSelect');
				# @attr 'unselectable', null
				@css 'user-select', ''
				@css '-moz-user-select', ''
				@css '-webkit-user-select', ''

			$('body').delegate '#magnifierLens', 'mouseover', =>
				$('#magnifierLens').unbind '.agora'
				down = false
				event = null
				$('#magnifierLens')
					.bind 'mousedown.agora', (e) ->
						down = true
						$('html').disableSelection()
						event = e
						true
					.bind 'mouseup.agora', ->
						down = false
					.bind 'mousemove.agora', =>
						if down
							down = false
							selector = '#main-image, #landingImage, #prodImageCell img, .main-image-inner-wrapper img, img#main-image, #imgTagWrapperId img, #imgBlkFront, #fbt_x_img img, #main-image-container .imgTagWrapper img'
							@clearProductEl el for el in $ selector
							selector = selector.split(', ').map((str) -> str + ':visible').join ', '
							@products $(selector), {siteName:@siteName, productSid:@Client.site.productID()}, area:'main'

							setTimeout (->
								$('#magnifierLens').remove()
								$('#zoomWindow').hide()
								$(selector).trigger event
								$('html').one 'mouseup', ->
									$('html').enableSelection()
							), 100


			$('body').delegate ':not(.-agora) a img:not([agora])', 'mouseover', ->
				productSid = matchProductSid $(@).parents('a').attr 'href'
				if productSid
					initProduct @, productSid, true
							

				

			initProduct = (el, sid, mousedover) =>
				el = $ el
				extraOverlayElements = null
				if el.parent().hasClass 'imageBox'
					extraOverlayElements = el.parents('a')

				@initProductEl el, {siteName:@siteName, productSid:sid}, {hovering:mousedover, extraOverlayElements:extraOverlayElements, area:'listing'}


			# load products in real time
			window.initProducts = initProducts = ->
				$(':not(.-agora) a img[src^="http://ecx.images-amazon.com/images/I/"]').each ->
						a = $(@).parents('a:first')
						productSid = matchProductSid a.attr 'href'
						if productSid
							initProduct $(@), productSid, false

			window.clearProducts = =>
				for el in $('a img[src^="http://ecx.images-amazon.com/images/I/"]')
					if matchProductSid $(el).parents('a:first').attr 'href'
						@clearProductEl el



			loadRecomendations = ->
				intervalId = setInterval (->
					if !$('#rhf .rhf_loading_outer').length
						clearTimeout intervalId
						initProducts()
				), 500
				
			$('body').delegate '#rvisColumn .rhf-RVIs a img', 'mousedown', ->
				setTimeout loadRecomendations, 100

			loader = (opts) ->
				timerId = null
				load = (el) ->
					clearTimeout timerId
					contEl = $(el).parents("#{opts.container}:first")
					asins = []
					count = 0

					contEl.find("#{opts.slide} > div:first-child").each (i) ->
						asins[i] = $(@).attr 'data-asin'
						++ count

					startOverLink = $(@).hasClass opts.startOver

					func = ->
						contEl.find(opts.slide).each (i) ->
							return if $(@).hasClass opts.empty

							asin = $(@).children('div:first-child').attr 'data-asin'

							if asins[i] != asin
								asins[i] = asin
								-- count

						if count <= 0
							clearTimeout timerId unless startOverLink
							console.log asins
							initProducts()

					if startOverLink
						setTimeout func, 500
					else
						timerId = setInterval func, 100

				$('body').delegate "#{opts.nav}, #{opts.container} #{opts.startOver}", 'mousedown', -> load @


			loader
				container:'.a-carousel-container'
				slide: '.a-carousel-card'
				nav:'.a-carousel-container .a-carousel-goto-nextpage .a-button-inner, .a-carousel-container .a-carousel-goto-prevpage .a-button-inner'
				startOver: '.a-carousel-restart'
				empty: 'a-carousel-card-empty'


			loader
				container: '.shoveler'
				slide: '.shoveler-content ul li'
				nav: '.shoveler span.s_shvlNext, .shoveler .next-button a, .shoveler span.s_shvlBack'
				startOver: 'a.start-over-link'
				empty: 'shoveler-progress'

			# loader
			# 	div: 'div.ima'
			# 	container: '.shoveler'
			# 	slide: '.shoveler-content ul li'
			# 	nav: '.shoveler .next-button a'
			# 	startOver: 'a.start-over-link'
			# 	empty: 'shoveler-progress'

			# brute force product detection
			setInterval initProducts, 2000


			$ -> 
				loadRecomendations()
				initProducts()
				$('body').load initProducts


				loadOtherId = setInterval (->
					if !$('#rhf_container .rhf_loading_outer').length
						clearTimeout loadOtherId
						initProducts()
				), 500


				$('body').delegate '.s9ShovelerBackBookendButton, .s9ShovelerNextBookendButton', 'mousedown', ->
					setTimeout initProducts, 500

				updateSearchResults = ->
					$('#btfResults').append('<div id="agoraTester" />')
					timerId = setInterval (->
						if !$('#agoraTester').length
							clearTimeout timerId
							initProducts()
					), 500


				$('body').delegate '#sort', 'change', updateSearchResults
				$('body').delegate '#pagn a, #refinements a, #kindOfSort_content a, #breadCrumb a, #relatedSearches a', 'mousedown', updateSearchResults
				$('.nav-searchbar-inner.nav-prime-menu').submit updateSearchResults


