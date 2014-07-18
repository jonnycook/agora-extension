define -> d: ['DataDrivenSiteInjector'], c: ->
	class Forever21SiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a[href^=http://www.forever21.com/Product/Product.aspx"] img'
			productSid: (href, a, img) -> img.attr('src').match(/https:\/\/s7\.jcrew\.com\/is\/image\/jcrew\/([^_]*)_/)?[1]

		productPage:
			test: -> 
			# mode:2
			# productSid: -> $('#pdpMainImg0').attr('src').match(/https:\/\/s7\.jcrew\.com\/is\/image\/jcrew\/([^_]*)_/)?[1]
			# image: '#pdpMainImg0'
			# position: '#pdpMainImg0'
			# attach: '#product0'
			# variant: -> Color: $('.color-name').text().trim()
