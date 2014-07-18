define -> d: ['DataDrivenSiteInjector'], c: ->
	class WalgreensSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a img[src^="//pics.drugstore.com/prodimg"]'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.walgreens\.com\/store\/c\/.*?\/ID=prod([^-]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: -> document.location.href.match(/^http:\/\/www\.walgreens\.com\/store\/c\/.*?\/ID=prod([^-]+)/)[1]
			imgEl: '#viewL img'
			waitFor: '#viewL img'