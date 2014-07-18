define -> d: ['DataDrivenSiteInjector'], c: ->
	class LandsEndSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode:2
			selectors:
				'[data-product-number][data-style-number]':
					productData: (href, a, img, el) ->
						productSid:"#{el.attr('data-product-number')}-#{el.attr('data-style-number')}"
					image: (el) -> el.find('.product-image')
					anchor: (el) -> el.find('.product-image-link')

				'a img[src*="s7.landsend.com/is/image/LandsEnd/"]':
					productData: (href, a, img, el) ->
						style = img.attr('src').match(/\/s7\.landsend\.com\/is\/image\/LandsEnd\/(\d*)/)?[1]
						if style
							productUrl:href, retrievalId:style

					# image: (el) -> el
					# anchor: (el) -> el.find('.product-image-link')

		productPage:
			# test: -> false
			mode:2
			productSid: ->
				id = $('h1[id^="mobileProductName_"]').attr('id').match(/mobileProductName_(\d*)/)?[1]
				style = $("#itemNumber_#{id}").text().match(/\d*/)[0]
				"#{id}-#{style}"
			image: '.pp-image-viewer-column.fn-image-viewer-wrap.pp-product-image-column img[src^="http://s7.landsend.com/is/image/LandsEnd"]:visible'
			overlay: '.pp-image-viewer-column.fn-image-viewer-wrap.pp-product-image-column div[id^="mapImageSjElement"]'
			attach: 'body'
			position: 'div[id^="productImage_"]'

			variant: -> Color:jQuery('span[id^="colorChoice_"]:visible').text()