define -> d: ['DataDrivenSiteInjector'], c: ->
	class NastyGirlSiteInjector extends DataDrivenSiteInjector
		productListing:
			mode: 2
			image: 'a img'
			positionA: true
			productSid: (href, a, img) ->
				# http://images01.nastygal.com/resources/nastygal/images/products/processed/40170.0.browse-l.jpg
				if matches = img.attr('src').match /(?:http:)?\/\/images\d*\.nastygal\.com\/resources\/nastygal\/images\/products\/processed\/(\d*)/
					name = a.attr('href').match(/[^\/]*$/)?[0]

					if name
						return "#{matches[1]}:#{name}"

		productPage:
			mode: 2
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: ->
				name = document.location.href.match(/[^\/]*$/)?[0]
				style = $('.product-style').text().match(/(\d*)$/)[1]
				"#{style}:#{name}"

			attach: '.product-images'
			position: '.product-images'
			image: '#product-images-carousel img'

			# initPage: ->
			# initProduct: ->