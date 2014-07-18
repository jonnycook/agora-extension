define -> d: ['SiteInjector', 'views/ShoppingBarView', 'views/compare/CompareView', 'views/WebAppView'], c: ->
	class WebAppSiteInjector extends SiteInjector
		siteName: 'WebApp'

		run: ->
			@initPage =>
				if !env.core
					shoppingBarView = new ShoppingBarView @contentScript
					shoppingBarView.el.appendTo document.body
					shoppingBarView.represent()

				params = JSON.parse $('html').attr('agoraparams')

				# resizeTimerId = null
				# resize = =>
				# 	clearTimeout resizeTimerId
				# 	resizeTimerId = setTimeout (=>
				# 		# width = $(window).width() - (106+100)*2
				# 		# $('#agoraCont').width width

				# 		$('#agoraCont').triggerHandler 'resize'
				# 	), 10
				# 	true

				# $(window).resize resize
				# resize()



				matches = document.location.href.match new RegExp("^#{params.base}\/(.*)$")

				# console.log matches
				webAppView = new WebAppView @contentScript
				webAppView.represent matches?[1]

				# compareView = new CompareView @contentScript, $('#agoraCont'), $(document.body)
				# compareView.el.appendTo '#agoraCont'
				# compareView.represent decisionId:1
