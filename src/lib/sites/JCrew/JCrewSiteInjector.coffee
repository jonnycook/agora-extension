define -> d: ['DataDrivenSiteInjector'], c: ->
	class JCrewSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a img[src^="https://s7.jcrew.com/is/image/jcrew/"]:not(.product-detail-images):not(#pdpMainImg0)'
			productSid: (href, a, img) -> 
				if img.attr('src').indexOf('italicloader') == -1
					img.attr('src').match(/https:\/\/s7\.jcrew\.com\/is\/image\/jcrew\/([^_]*)_/)?[1]

		productPage:
			# test: -> 
			mode:2
			productSid: -> $('#pdpMainImg0').attr('src').match(/https:\/\/s7\.jcrew\.com\/is\/image\/jcrew\/([^_]*)_/)?[1]
			image: '#pdpMainImg0'
			position: '#pdpMainImg0'
			attach: '#product0'
			variant: -> Color: $('.color-name').text().trim()
