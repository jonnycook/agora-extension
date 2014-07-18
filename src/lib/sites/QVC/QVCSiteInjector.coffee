define -> d: ['DataDrivenSiteInjector'], c: ->
	class QVCSiteInjector extends DataDrivenSiteInjector
		productListing:
			imgSelector: 'a img[src^="http://images.qvc.com/is/image/"]'
			productSid: (href, a, img) -> 
				# id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
				name = href.match(/^http:\/\/www\.qvc\.com\/.*?\.product\.([^\.]+)/)?[1]
				# "#{id}:#{name}"
				name


		productPage:
			initPage: ->
				@colorMap = {}

				matches = document.head.innerHTML.match /var arrSizeValues = new Array([\S\s]*?)<\/script>/
				globalMatches = matches[1].match /arrSizeValues\[.*?\]\[.*?\]="(.*?)"/g
				for match in globalMatches
					match = match.match(/arrSizeValues\[.*?\]\[.*?\]="(.*?)"/)[1]
					matches = match.match /^([^:]*):[^:]*:[^:]*:([^:]*):[^:]*:([^:]*)$/
					@colorMap[matches[3]] = matches[1]

			test: -> $('#imageID').length
			productSid: ->
				id = document.location.href.match(/^http:\/\/www\.qvc\.com\/.*?\.product\.([^\.]+)/)[1]
				id += '-' + @colorMap[$('#spanSelectedSizeColor').text().trim()]
				id
			imgEl: '#imageID'
			waitFor: '#imageID'
			# overlayEl: '.mousetrap'


			# initPage: ->
			# initProduct: ->