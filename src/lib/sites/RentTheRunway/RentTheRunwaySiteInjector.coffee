define -> d: ['DataDrivenSiteInjector'], c: ->
	class RentTheRunwaySiteInjector extends DataDrivenSiteInjector
		productListing:
			mode: 2
			image: 'a[href^="/shop/designers/"]:not(.product-thumbnail) img'
			productSid: (href, a, img) -> href.match(/https:\/\/www\.renttherunway\.com\/shop\/designers\/([^\/]*\/.*)/)?[1]

		productPage:
			mode:2
			test: -> document.location.href.match(/https:\/\/www\.renttherunway\.com\/shop\/designers\/([^\/]*\/.*)/)
			productSid: -> document.location.href.match(/https:\/\/www\.renttherunway\.com\/shop\/designers\/([^\/]*\/.*)/)[1]
			image: '.featured-image.cloudzoom:visible'
			overlay: '.cloudzoom-zoom-inside'
			attach: 'body'