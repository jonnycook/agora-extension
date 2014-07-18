define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class JCPenneySiteInjector extends SiteInjector
		siteName: 'JCPenney'
		run: ->
			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript
				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				parseSid = (href) ->
					matches = /^http:\/\/www\.jcpenney\.com\/.*?\/prod\.jump\?ppId=([a-z]*\d+)/.exec href
					if matches
						matches[1]

				window.initProducts = initProducts = =>
					for img in $('a img')
						a = $(img).parents 'a'
						if a.attr('href') && a.attr('href')[0] != '#'
							href = a.prop 'href'
							sid = parseSid href
							if !sid
								match = /(http:\/\/www\.jcpenney.com\/.*?)(?:&|$)/.exec(unescape href)?[1]
								if match
									sid = parseSid match

							if sid
								console.log sid, href
								@initProductEl img, productSid:sid
						
				$ initProducts
				$(window).load initProducts

				setInterval initProducts, 2000

				$ =>
					if $('#izView').length
						currentSid = -> /[?&]ppId=(.*?)(?:&|$)/.exec(document.location.href)[1]
						@waitFor '#izView img', =>
							for img in $('#izView img')
								@initProductEl img, productSid:currentSid()