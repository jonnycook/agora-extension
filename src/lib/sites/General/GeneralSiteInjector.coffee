define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class GeneralSiteInjector extends SiteInjector
		siteName: 'General'
		config:
			productBadges: false

		run: ->			
			@initPage =>
				shoppingBarView = new ShoppingBarView @contentScript
				shoppingBarView.el.appendTo document.body
				shoppingBarView.represent()
											
				initProduct = (el, pageUrl, linkUrl, image) =>
					@products el, siteName:@siteName, pageUrl:pageUrl, linkUrl:linkUrl, image:image
				
				$('body').delegate 'img', 'mouseover', ->
					unless $(@).data('agora') || $(@).parents('.-agora').length
						a = $(@).parents('a')
						linkUrl = null
						if a.length && a.prop('href') && a.prop('href').match '^http'
							linkUrl = a.prop 'href'


						initProduct $(@), document.location.href, linkUrl, $(@).prop 'src'
					$(@).data 'agora', true
				true