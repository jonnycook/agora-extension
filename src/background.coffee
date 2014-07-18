# 'UA-48396911-1' prod
# 'UA-48396911-4' dev
if ga?
	ga 'create', env.trackingId, 'auto'
	ga 'set', 'forceSSL', true
	ga 'set', 'checkProtocolTask', ->

installed = null

showConnect = ->
	if typeof agora != 'undefined' && installed != null
		if installed
			agora.background.getCookie agora.background.apiRoot, 'userId', (cookie) =>
				if !cookie
					chrome.tabs.create url:'http://agora.sh/connect.html'


require ['Agora', 'ChromeBackground', '../../libs/md5'], (Agora, ChromeBackground, md5) ->
	console.debug 'ok'
	window.background = background = new ChromeBackground

	window.onerror = (message, file, line, column, error) ->
		if message != 'Script error.'
			background.logError 'Error', message, file, line, column, error?.stack, error?.info


	# console.log md5 "#{new Date().getTime()} #{Math.random()}"
	background.getStorage 'instanceId', (data) ->
		if data.instanceId
			background.instanceId = data.instanceId
		else
			background.instanceId = md5 "#{new Date().getTime()} #{Math.random()}"
			background.setStorage instanceId:background.instanceId

		background.log 'started'

		window.agora = agora = new Agora background,
			localTest:false
			autoUpdate:env.autoUpdate
			initDb: (agora) ->

		background.ping()
		setInterval (-> background.ping()), 60*1000

		showConnect()

chrome.runtime.onMessage.addListener (message, sender, sendResponse) =>
	if message.action == 'getScriptFor'
		agora.enabledForUrl message.url, (enabled) ->
			if enabled
				agora.addTab sender.tab.id
				agora.getContentScript message.url, sendResponse
			else
				sendResponse()
		true
	else if message == 'getScript' && sender.tab
		__ = ->
			agora.enabledForUrl sender.tab.url, (enabled) ->
				if enabled
					agora.getContentScript sender.tab.url, sendResponse
					agora.addTab sender.tab.id
				else
					sendResponse()
		if agora?
			__()
		else
			id = setInterval (->
				if agora?
					__()
					clearInterval id
			), 10
		true
	else if message is "getStyles" and sender.tab
		agora.background.getStyles (styles) ->
			sendResponse styles
		true

	else if message == 'init' && sender.tab
		agora.addTab sender.tab.id
		agora.getContentScript sender.tab.url, (script) ->
			chrome.tabs.executeScript sender.tab.id, code:script, runAt:'document_start'
	else if message == 'startTutorial'
		agora.tutorial 'start'
	else if message == 'continueTutorial'
		agora.tutorial 'continue'
	else if message == 'endTutorial'
		agora.tutorial 'end'
	else if message.message is "code_get"
		$.get message.url, sendResponse
		true
	else if message.action is "reloadModules"
  	i = 0
  	while i < message.modules.length
    	agora.codeManager.reload message.modules[i]
    	++i


chrome.runtime.onMessageExternal.addListener (message) =>
	if message == 'endTutorial'
		agora.endTutorial()
	else if message == 'startContentClipping'
		chrome.tabs.query active:true, currentWindow:true, (tabs) ->
			chrome.tabs.sendMessage tabs[0].id, 'startContentClipping'
	else if message == 'facebookShare'
		tracking.event 'SocialShare', 'Facebook'


chrome.browserAction.onClicked.addListener (tab) ->
	chrome.tabs.query active:true, currentWindow:true, (tabs) ->
		chrome.tabs.sendMessage tabs[0].id, 'toggle'

	# agora.getContentScript tab.url, (script) ->
	# 	chrome.tabs.executeScript tab.id, code:script, runAt:'document_start'

chrome.tabs.onRemoved.addListener (tabId) ->
	agora.removeTab tabId
	agora.background.unregisterTab tabId

chrome.runtime.onInstalled.addListener (details) ->
	installed = details.reason == 'install'
	showConnect()

props = ['title', 'price', 'image', 'rating', 'ratingCount', 'more', 'reviews']


lastProduct = null
scrapeProduct = (site, sid, json=false) ->
	lastProduct = site:site, sid:sid
	agora.Site.site(site).productScraper agora.background, sid, (scraper) ->
		scraper.scrape props, (properties) ->
			console.debug if json then JSON.stringify properties else properties

images = (siteName, id) ->
	site = agora.Site.site(siteName)
	product = agora.modelManager.getModel('Product').getBySid siteName, id
	site.product agora.background, product, (siteProduct) ->
		siteProduct.images (images, currentStyle) ->
			console.debug images, currentStyle



scrapeTestProducts = (siteName, json=false) ->
	$.get "http://ext.agora.sh/ext/getTestProducts.php?site=#{siteName}", (response) ->
		products = JSON.parse response
		console.debug products
		testProducts = products[siteName] ? {}

		site = agora.Site.site(siteName)
		site.productScraperClass agora.background, (scraperClass) ->
			count = 0
			products = {}
			for sid,_ of testProducts
				++ count
				do (sid) ->
					scraper = new scraperClass site, sid, agora.background
					scraper.scrape props, (properties) ->
						-- count
						products[sid] = properties

						if !count
							console.debug if json then JSON.stringify products else products

testScraper = (siteName) ->
	$.get "http://ext.agora.sh/ext/getTestProducts.php?site=#{siteName}", (response) ->
		products = JSON.parse response
		testProducts = products[siteName] ? {}

		site = agora.Site.site(siteName)
		site.productScraperClass agora.background, (scraperClass) ->

			skips = {}
			if scraperClass.testing?.skipTest
				for prop in scraperClass.testing.skipTest
					parts = prop.split '.'
					skips[parts[0]] = parts.slice 1

			count = 0
			products = {}
			for sid,correctProperties of testProducts
				++ count
				do (sid, correctProperties) ->
					correctProperties = JSON.parse correctProperties
					scraper = new scraperClass site, sid, agora.background
					scraper.scrape props, (properties) ->
						failed = 0
						for name,value of correctProperties
							continue if name in ['rating', 'ratingCount', 'reviews']

							if s = skips[name]
								if !s.length
									continue
								delete value[s[0]]
								delete properties[name][s[0]]


							if JSON.stringify(value) != JSON.stringify properties[name]
								++ failed
								console.debug "mismatched #{sid} #{name} actual:#{JSON.stringify properties[name]} correct:#{JSON.stringify(value)} "
								console.debug properties[name], value

						if !failed
							console.debug "passed #{sid}"

uploadTestProduct = (site, sid) ->
	if !site && !sid && lastProduct
		{site:site, sid:sid} = lastProduct

	agora.Site.site(site).productScraper agora.background, sid, (scraper) ->
		scraper.scrape props, (properties) ->
			$.post 'http://ext.agora.sh/ext/uploadTestProduct.php', data:JSON.stringify(properties), site:site, sid:sid, ->
				console.debug 'done'



window._activity = (type, object, args...) ->
	storeId = object.record.storeId
	object = switch object.modelName
		when 'RootElement'
			parent = object.get('parent')
		when 'ListElement'
			parent = object.get('parent')
			agora.modelManager.getModel('Decision').find(list_id:parent.record.globalId()) ? parent
		when 'BundleElement'
			object.get('parent')			
		when 'BeltElement'
			object.get('parent')			
		else
			object

	if object != '/'
		object = model:object.modelName, id:object.record.globalId()

	for arg,i in args
		if arg?.modelName
			args[i] = model:arg.modelName, id:arg.record.globalId()

	activity = agora.db.tables.activity.insert
		user_id:"G#{storeId}"
		generator_id:agora.user.get('id')
		type:type
		object_type:object.model
		object_id:object.id
		args:args
		timestamp:Math.floor new Date().getTime()/1000

	activity.storeId = storeId

	# console.debug '::activity', type, object, args...

window.getActivity = ->
	object = agora.modelManager.getInstance('User', 'G1')
	# console.log object

	agora.db.tables.activity.records.each (record) ->
		obj = agora.modelManager.getInstance(record.get('object_type'), record.get('object_id'), false)
		while obj
			if obj.isA(object.modelName) && obj.get('id') == object.get 'id'
				console.debug record.get('timestamp'), record.get('type'), record.get('object_type'), record.get('object_id'), record.get('args')
				return
			parent = obj.record.owner()
			if parent
				# console.log 'parent', parent
				obj = agora.modelManager.instanceForRecord parent
			else
				break
		# console.log record.get('timestamp'), record.get('type'), record.get('object_type'), record.get('object_id'), record.get('args')

