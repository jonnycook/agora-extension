define -> d: ['DataDrivenSiteInjector'], c: ->
	class JCPenneySiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a img[src^="http://s7d9.scene7.com/is/image/JCPenney/"]'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.jcpenney\.com\/.*?\/prod\.jump\?ppId=([a-z]*\d+)/)?[1]
				# "#{id}:#{name}"
				sid = name
				if !sid
					href = unescape href
					match = /(http:\/\/www\.jcpenney.com\/.*?)(?:&|$)/.exec(href)?[1]
					if match
						sid = match
				sid


		productPage:
			test: -> $('meta[name="keywords"]').attr('content')
			productSid: -> document.location.href.match(/^http:\/\/www\.jcpenney\.com\/.*?\/prod\.jump\?ppId=([a-z]*\d+)/)[1]
			imgEl: '#izView img'
			waitFor: '#izView img'
			overlayEl: '#myZoomView'


			# initPage: ->
			# initProduct: ->
