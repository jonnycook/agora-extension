define -> d: ['DataDrivenSiteInjector'], c: ->
	class FreePeopleSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode:2
			image: 'a:not(.option):not([rel="hoverzoom"]):not([data-image]) img'
			productData: (href, a, img) ->
				if matches = /^http:\/\/images\d*\.freepeople\.com\/is\/image\/FreePeople\/([^_]*)/.exec img.attr 'src'
					{productUrl:href, retrievalId:matches[1]}

		productPage:
			productSid: ->
				name = $('meta[property="og:url"]').attr('content').match(/^http:\/\/www\.freepeople\.com\/([^\/]*)\/$/)[1]
				id = $('form[name=productsDetailOptionsForm] input[name=productID]').val()
				options = $('#productsDetailOptionsForm [name="productOptionIDs"]').val()
				sid = "#{id}:#{name}"
				if options
					sid += ":#{options}"
				sid

			imgEl: 'img[itemprop="image"]'
			overlayEl: '.lens'
			overlayZIndex:9999