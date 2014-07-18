define -> ->
	console.debug 'devAction'

	devAction = 
		reloadDevAction: ->
			window.devActionReloaded = true
			chrome.runtime.sendMessage action:'reloadModules', modules:['devAction']

		devAction: ->
			Q.undo()
			View.clear()
			$('.-agora').remove()

			chrome.runtime.sendMessage action:'reloadModules', modules:[
				# 'Frame2'
				# 'SiteInjector'
				'views/SocialShareView'
				# 'views/ChatView'
				'DataDrivenSiteInjector'

				'views/compare/CompareView'
				{module:'../sites/Zappos/ZapposSiteInjector', className:'SpecificSiteInjector'}
				# 'View'
				# 'util'
				# 'util2'
				# 'views/ProductPopupView'
				# 'views/ProductPreviewView'
				# 'views/compare/ProductTileItem'
				# 'views/ShoppingBarView'
			]
			setTimeout (->
				reloadStyles()
				doSiteInjection()
			), 1000
			# console.debug 'reloaded2'


	if window.devActionReloaded
		delete window.devActionReloaded
		devAction.devAction()

	devAction