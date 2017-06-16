define [
		'underscore', 'Debug'
		'client/ContentScript', 'client/SiteInjector'
		'Site', 'siteConfig', 'View', 'clientInterface/ClientValue'
		'models/init', 'model/Event', 'Updater2', 'Public', 'views/ProductPriceView', 'views/ProductMenuView', 'views/SettingsView', 'CodeManager', 'Chat'], (_, Debug, ContentScript, SiteInjector, Site, siteConfig, View, ClientValue, initModels, Event, Updater, Public, ProductPriceView, ProductMenuView, SettingsView, CodeManager, Chat) ->

	class Agora
		constructor: (@background, opts={}) ->
			opts.client ?= true	
			{db:db, modelManager:modelManager} = initModels @background
			@db = db
			@modelManager = modelManager

			window.Debug = Debug

			@public = new Public
			@public.agora = @

			@background.loadVersion = @loadVersion = new Date().getTime()

			@events = onUserChanged:new Event

			lastUpdated = null

			@background.state = 0

			# @tutorialEnded = false

			autoUpdate = opts.autoUpdate
			opts.localTest = env.localTest ? opts.localTest

			@View = View
			View.agora = @
			Site.agora = @
			_.extend @modelManager.getModel('Product'),
				background: background
				agora: @

			@Site = Site

			@siteSettings = new ClientValue @, {}, 'siteSettings'

			@userId = new ClientValue @, {}, 0

			@errorState = new ClientValue @

			settings = ['hideBelt', 'autoFeelings', 'showPreview']

			@settings = {}


			for settingName in settings
				@settings[settingName] = new ClientValue @

			@codeManager = new CodeManager @

			if opts.client && !env.core
				@chat = new Chat @
				@chat.init()

			scrapersTime = null

			if !env.core
				updatingScrapers = false
				updateScrapersId = null
				updateScrapersCbs = []
				@updateScrapers = updateScrapers = (cb=null) =>
					updateScrapersCbs.push cb if cb
					if updatingScrapers
						console.debug 'already updating scrapers'
						return
					background.clearTimeout updateScrapersId
					updatingScrapers = true
					background.httpRequest 'http://ext.agora.sh/getScrapers.php',
						data:
							timestamps:true
							version:@background.getVersion()
							time:scrapersTime ? undefined
						dataType: 'json'
						cb: (response) =>
							background.declarativeScrapers
							toRemove = []
							for newScraper in response.scrapers
								for scraper,i in background.declarativeScrapers
									if scraper.name == newScraper.name && scraper.site == newScraper.site
										toRemove.push i

							if toRemove.length
								for i in [toRemove.length - 1..0]
									background.declarativeScrapers.splice toRemove[i], 1

							background.declarativeScrapers = background.declarativeScrapers.concat response.scrapers

							scrapersTime = response.time
							# console.debug 'scrapers updated'
							updatingScrapers = false
							updateScrapersId = background.setTimeout updateScrapers, 30000
							cb true for cb in updateScrapersCbs
							updateScrapersCbs = []
						error: ->
							updateScrapersId = background.setTimeout updateScrapers, 30000

			onLoaded = (success) =>
				console.debug 'loaded'

				doOnLoaded = =>
					@modelManager.getModel('Product').init()

					if !env.core
						updateScrapers()

						if opts.client
							# save model alterations					
							observeField = (record, field) ->
								record.field(field).observe (mutation) ->
									updater.addUpdate record, field
							
							observeRecord = (record) =>
								if record.table.schema.fields
									for field in record.table.schema.fields
										observeField record, field
							
							for name, table of db.tables
								table.records.each observeRecord
								
								table.records.observe (mutation) ->
									if mutation.type == 'insertion'
										updater.addInsertion mutation.value
										observeRecord mutation.value
									else if mutation.type == 'deletion'
										updater.addDeletion mutation.value

							siteSettings = {}

							for siteName, config of siteConfig
								if !('enabled' of config) || config.enabled == true
									siteSettings[siteName] = enabled: true

							db.tables.site_settings.records.each (record) =>
								siteSettings[record.get 'site'] =
									enabled: record.get 'enabled'
							
							@siteSettings.set siteSettings


							@background.getStorage ['options'], (data) =>
								if data.options
									for setting in settings
										@settings[setting].set data.options[setting]


							db.tables.site_settings.observe (mutation) =>
								switch mutation.type
									when 'deletion'
										delete @siteSettings.get()[mutation.record.get('site')]
									when 'insertion'
										@siteSettings.get()[mutation.record.get('site')] = {}
									when 'update'
										@siteSettings.get()[mutation.record.get('site')][mutation.field] = mutation.record.get(mutation.field)

								@siteSettings.set @siteSettings.get()	
						
							if @updater.userId
								if success
									@user = @modelManager.getModel('User').withId 'G' + @updater.userId, false
									# if !@user.get('belts').length()
									# 	@modelManager.getModel('Belt').create user_id:@user.get('id')



					createView.apply null, args for args in createViewQueue
					delete createViewQueue
					@loaded = true

					opts.onLoaded? @


				if !env.core
					background.httpRequest 'http://ext.agora.sh/getScrapers.php',
						data:
							timestamps:true
							version:@background.getVersion()
						dataType: 'json'
						cb: (response) =>
							background.declarativeScrapers = response.scrapers
							scrapersTime = response.time

							doOnLoaded()
				else
					doOnLoaded()

			createView = (source, args, sendResponse) =>
				id = View.createClientView source.tabId, args.type
				#Debug.log 'CreateView', args, id
				sendResponse id:id
			createViewQueue = []

			@updater = updater = new Updater background, db, @userId, @errorState
			if !autoUpdate
				@updater.autoUpdate = false

			if opts.localTest || opts.core
				@loaded = true
				# db.tables.bags.addRecord name:'All', type:'all'
				if opts.client
					opts.initDb? @
					user = db.tables.users.insert {}
					@user = modelManager.getInstance('User', user.get('id'))
					db.tables.belts.insert user_id:user.get('id')
					@userId.set user.get('id')
				onLoaded()
			else
				if autoUpdate
					@loaded = false
					@background.state = 1
					updater.init onLoaded
					# updater.update onLoaded
				else
					@loaded = true
					onLoaded()

			if opts.client
				@background.listen 'CreateView', (source, args, sendResponse) =>
					if @loaded
						createView.apply @, arguments
					else
						createViewQueue.push arguments
						true
				
				@background.listen 'CallViewBackgroundMethod', (source, args, sendResponse) ->
					# Debug.log "Calling BackgroundViewMethod #{args.view}.#{args.methodName}"
					View.callMethod args.id, args.methodName, args.args, args.timestamp, sendResponse
					false
							
				@background.listen 'ConnectView', (source, args, sendResponse) =>
					View.connect @, args.id, args.args, (success, data) ->
						#Debug.log 'ConnectView', args, data
						if success
							sendResponse data:data
						else
							sendResponse false
					true
						
				@background.listen 'DeleteView', (source, args) =>
					#Debug.log 'DeleteView', args
					View.remove args.id
					false

				@background.listen 'GetClientObjects', (source, ids, sendResponse) ->
					sendResponse View.getClientObjects ids

				@background.listen 'tracking', (source, args) =>
					if !env.core
						if args.type == 'event'
							# ga 'send', 'event', args.args...
							tracking.event args.args...
						else if args.type == 'page'
							tracking.page args.path, args.params, args.title
						else if args.type == 'time'
							tracking.time args.args...
					false

				@background.listen 'tutorialFinished', =>
					if @convert
						delete @convert
						@background.httpRequest @updater.background.apiRoot + 'convert.php'
					@tutorial 'end'
					false

				@background.listen 'tutorialStep', (source, step) =>
					@tutorial 'step', step
					false

				@background.listen 'reloadExtension', =>
					chrome.runtime.reload()
					false

				@background.listen 'siteVisited', (source, site) =>
					tracking.event 'Site', 'visit', site
					if @user
						@updater.transport.ws.send "t#{@user.saneId()}\tvisit\t#{site}"
					false

				tutorialCheck = (tutorial) =>
					if @user.get('tutorials')
						if tutorial in @user.get('tutorials').split ' '
							false
						else
							true
					else
						true

				@background.listen 'tutorialCheck', (source, tutorial, sendResponse) =>
					if env.core
						sendResponse false
					else
						if _.isArray tutorial
							for t in tutorial
								if tutorialCheck t
									sendResponse t
									return
						else
							if tutorialCheck tutorial
								sendResponse tutorial
								return

						sendResponse false

				@background.listen 'tutorialSeen', (source, tutorial, sendResponse) =>
					if @user.get('tutorials')
						if !(tutorial in @user.get('tutorials').split ' ')
							@user.set('tutorials', "#{@user.get('tutorials')} #{tutorial}")
					else
						@user.set('tutorials', tutorial)


		_load: (classes, cb, classDefs = []) ->
			deps = []
			for className, classFactory of classes
				if typeof classFactory == 'string'
					deps.push classFactory
				else
					if typeof classFactory == 'function'
						factory = classFactory
					else
						deps = _.union(deps, classFactory.d) if classFactory.d
						factory = classFactory.c
						

					classDefs.unshift name:className, body:factory.toString()
				
			if deps.length
				@background.require _.map(deps, (className) -> "client/#{className}"), =>
					c = {}
					for i in [0...deps.length]
						className = deps[i]
						if (index = className.lastIndexOf '/') != -1
							className = className.substr index + 1

						classFactory = arguments[i]
						
						c[className] = classFactory
					@_load c, cb, classDefs
			else
				cb classDefs
				
		_compileContentScript: (classDefs, site) ->
			classVars = classDefs.join '\n'

			classCode = "var __classes = {};\n"
			# classCode = ''
			for {name:name, body:body} in classDefs
				classCode += "window.#{name} = __classes.#{name} = (#{body})();\n"

			settingsStr = ''

			for settingName, setting of @settings
				settingsStr += "
					#{settingName}: new ClientValue({
						_id: #{setting._id},
						_scalar: #{JSON.stringify setting.get()},
						contentScript: contentScript
					}),
				"

			"""
			(function() {
				/* content script */
				
				function run() {
					var env = #{JSON.stringify env};
					// CoffeScript system methods
					
					var
					  slice = [].slice,
						extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
					  hasProp = {}.hasOwnProperty;


					#{classCode}
					window.__classes = __classes;

					var contentScript = window.contentScript = new SpecificContentScript;
					contentScript.version = #{@version};

					var Agora = window.Agora = {
						siteSettings: new ClientValue({
							_id: #{@siteSettings._id},
							contentScript: contentScript,
							_scalar:#{JSON.stringify @siteSettings.get()}
						}),
						settings: {
							#{settingsStr}
						},
						userId: new ClientValue({
							_id: #{@userId._id},
							contentScript: contentScript,
							_scalar:#{JSON.stringify @userId.get()}
						}),
						errorState: new ClientValue({
							_id: #{@errorState._id},
							contentScript: contentScript,
							_scalar:#{JSON.stringify @errorState.get()}
						}),
						dev:#{env.dev}
					};

					var siteInjector;

					window.doSiteInjection = function() {
						siteInjector = window.siteInjector = new window.SpecificSiteInjector(contentScript, #{@continueTutorial}, '#{site.name}');

						siteInjector.run();
					}

					doSiteInjection()

					if (window.onAgoraInit) {
						window.onAgoraInit();
					}
				}
				return run();
			})()
			"""

		setAutoShowForSite: (site, value) ->
			record = @db.tables.site_settings.select((record) -> record.get('site') == site)[0]
			unless record
				record = @db.tables.site_settings.addRecord site:site
			
			record.set 'enabled', value

		toggleAutoShow: (site) ->
			@enabledForSite site, (enabled) =>
				@setAutoShowForSite site, if enabled then 0 else 1

		enabledForUrl: (url, cb) ->
			site = Site.siteForUrl url
			if site
				@enabledForSite site.id(), cb
			else
				false

		_setSiteEnabled: (siteID, enabled) ->
			@_sitesEnabledCache ?= {}
			if enabled
				@_sitesEnabledCache[siteID] = true
			else
				delete @_sitesEnabledCache[siteID]

			@siteSettings.get()[siteID] ?= {}
			@siteSettings.get()[siteID].enabled = enabled
			@siteSettings.set @siteSettings.get()

		enabledForSite: (siteID, cb) ->
			record = @db.tables.site_settings.select((record) -> record.get('site') == siteID)[0]
			
			if record
				cb record.get('enabled')
			else
				site = Site.siteById(siteID)

				if site.config.enabled == 'check'
					if @_sitesEnabledCache && siteID of @_sitesEnabledCache
						cb true
					else if !env.dev

						@background.httpRequest @background.apiRoot + 'merchantCheck.php',
							data: host:site.host
							cb: (response) =>
								if response == '1'
									@_setSiteEnabled siteID, true
									cb true
								else
									cb false
							error: ->
								cb false
				else
					cb true


		_getContentScript: (siteInjector, site, cb) ->
			mainScript = styleScript = libsScript = null

			tick = =>
				if mainScript && styleScript && libsScript
					cb "#{libsScript}\n#{styleScript}\n#{mainScript}"

			# styles
			@background.getStyles (styles) =>
				styles = styles.replace(/"/g, '\\"').replace(/\n/g, '\\n')
				styleScript = "$('head').append(\"<style id='agoraStylesheet' type='text/css'>#{styles}</style>\");"
				tick()

			# main script
			classes =
				SpecificSiteInjector: siteInjector
				SiteInjector:SiteInjector
				Debug:'Debug'
				tracking:'tracking'
				TutorialDialog:'TutorialDialog'
				ShoppingBarView:'views/ShoppingBarView'
				ProductPriceView:ProductPriceView.client
				ProductMenuView:ProductMenuView.client
				SettingsView:SettingsView.client
				
				SpecificContentScript: @background.contentScript()			
				ContentScript: ContentScript

			@_load classes, (classDefs) =>
				mainScript = @_compileContentScript classDefs, site
				tick()

			# libs
			@background.httpRequest @background.clientLibsPath(),
				method: 'get'
				cb: (response) ->
					libsScript = response
					tick()

		getContentScript: (url, cb) ->
			@getSiteInjector url, (siteInjector, site) =>
				if siteInjector
					@_getContentScript siteInjector, site, cb
				else 
					console.log "no site injector for #{url}"
					cb ''

		getSiteInjector: (url, cb) ->
			site = Site.siteForUrl url
			if site
				site.getSiteInjector @background, cb
			else
				cb null
				
		getSiteScraper: (url, cb) ->
			site = Site.siteForUrl url
			if site
				site.getSiteScraper @background, (scraperClass) =>
					scraper = new scraperClass @background
					cb scraper
			else
				cb null

		product: (input, cb, create = true) ->
			@modelManager.getModel('Product').get input, cb, create

		tutorial: (state) ->
			if state == 'continue'
				@continueTutorial = true
			else
				delete @continueTutorial

			if state == 'start'
				@tutorialStartTime = new Date().getTime()
			else if state == 'end'
				time = new Date().getTime() - @tutorialStartTime
				delete @tutorialStartTime
				tracking.time 'Tutorial', 'TotalTime', time
			else if state == 'step'
				if @user.get('tutorial_step') < arguments[1]
					@user.set 'tutorial_step', arguments[1]

		setOptions: (options) ->
			@background.getStorage ['options'], (data) =>
				prevOptions = data.options ? {}
				for prop,value of options
					prevOptions[prop] = value
					@settings[prop].set value
				@background.setStorage options:prevOptions

		addTab: (tabId) ->
			if !this.tabs then this.tabs = []
			this.tabs.push(tabId)

			@background.contentScriptListen "ClientObjectEvent:#{@userId._id}", tabId
			@background.contentScriptListen "ClientObjectEvent:#{@errorState._id}", tabId
			@background.contentScriptListen "ClientObjectEvent:#{@siteSettings._id}", tabId

		removeTab: (tabId) -> 
			_.pull(this.tabs, tabId)
			View.deleteClientViewsInTab tabId

		signalReload: ->
			console.log @tabs
			if @tabs
				for tab in @tabs
					chrome.tabs.sendMessage tab, 'needsReload'

		reset: ->
			console.debug 'reset'
			@background.loadVersion = @loadVersion = new Date().getTime()
			@signalReload()
			@View.clear()
			@background.reset()

		onInit: (success) ->
			console.log success
			if @updater.userId
				if success
					@user = @modelManager.getModel('User').withId 'G' + @updater.userId
					if @View.views.ShoppingBar?.null
						@View.views.ShoppingBar.null.setUser @user
						@View.views.Collaborate.ShoppingBar.update()
			else
				delete @user

		# setUserId: 



		getObject: (storeId, object) ->
			if object == '@'
				@db.tables.users.byId "G#{storeId}"
			else if object == '/'
				@db.tables.users.byId "G#{storeId}"
			else
				[table, id] = object.split '.'
				@db.table(table).byId "G#{storeId}"