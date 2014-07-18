define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class SamsClubSiteInjector extends SiteInjector
		siteName: 'SamsClub'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				#for product images on search pages and other pages
				parseSid = (href) ->
					matches = /^http:\/\/www\.samsclub\.com\/sams\/[^\/]*?\/prod([^\.]+)/.exec href
					if matches
						matches[1]

				window.initProducts = initProducts = =>
					for img in $('a:not(.BVRRSocialBookmarkingSharingLink) img')
						a = $(img).parents 'a'
						if a.attr('href') && a.attr('href')[0] != '#'
							href = a.prop 'href'

							#for parsing richrelevance urls, rich relevance
							sid = parseSid href
							if !sid
								href = unescape href
								match = /(http:\/\/www\.samsclub.com\/.*?)(?:&|$)/.exec(href)?[1]
								if match
									sid = parseSid match

							if sid
								console.log sid, href
								@initProductEl img, productSid:sid
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000

				# for product image on the product page
				$ =>
					if $('#plImageHolder').length
						currentSid = -> /^http:\/\/www\.samsclub\.com\/sams\/.*?\/prod([^\.]+)/.exec(document.location.href)[1] #not functional - see research.txt
						# @waitFor '#plImageHolder img', => #img tag that is child of #viewL element
						@initProductEl $('#plImageHolder img'), productSid:currentSid()