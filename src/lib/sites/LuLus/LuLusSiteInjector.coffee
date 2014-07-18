define -> d: ['DataDrivenSiteInjector'], c: ->
	class LulusSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode:2
			selectors:
				'div.category div.category-image':
					image: (el) -> el.find('.image img:first')
					anchor: (el) -> el.find('.mousetrap .trap-link')
					anchorProxy:true
					productData: (href, a, img, el) ->
						matches = href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html")
						if matches
							productSid:matches?[1]


				'a img[src^="http://cdn.lulus.com/images/product/"], a img[src^="/images/product/"]':
					productData: (href, a, img) ->
						matches = href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html")
						if matches
							productSid:matches?[1]


		productPage:
			mode: 2
			test: -> document.location.href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html")
			productSid: -> document.location.href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html")[1]

			image: '#zoom1 img'
			overlay: '.mousetrap'
			attach: 'body'
			zIndex:9999
