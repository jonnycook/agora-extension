define -> d: ['DataDrivenSiteInjector'], c: ->
	class MakeMeChicSiteInjector extends DataDrivenSiteInjector
		productListing:
			image: 'a img[src^="http://www.makemechic.com/media/catalog/product"]'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/([^\/]*?)\.html$/)?[1]
				# "#{id}:#{name}"
				name

		productPage:
			mode:2
			test: -> $('meta[property="og:type"]').attr('content') == 'product'
			productSid: -> document.location.href.match(/([^\/]*?)\.html$/)[1]
			image: '#wrap img'
			overlay: '.mousetrap'
			attach: '#image'
			variant: ->
				colorAbbreviation = $('#image img').attr('src').match(/\/\w+-([a-z]+)[^\/]*\.\w*$/)[1]
				className = $('.color-swatch-wrapper').find("img[src*='-#{colorAbbreviation}']").parent().get(0).className
				colorId = className.match(/color-swatch-\d*-(\d*)/)[1]
				colorName = $('#attribute85').find("option[value=#{colorId}]").html()
				Color:colorName
