scrapers = [{}]
CurrentScraper = {}
setCurrentScraper = (i) ->
	CurrentScraper = scrapers[i]
	resetInterface()

Pages = {}

version = 0

define ['../../lib/scraping/DeclarativeScraper', './interface', './ListInterface'], (DeclarativeScraper, iface, ListInterface) ->
	chrome.storage.local.get 'scrapeDev.scrapers', (data) ->
		scrapers = data['scrapeDev.scrapers'] ? [{}]
		start()

	# $.get 'http://ext.agora.sh/getScrapers.php', ((response) ->
	# 	scrapers = response
	# 	# setCurrentScraper 0
	# 	start()
	# ), 'json'
	save = ->
		data = {}
		data['scrapeDev.scrapers'] = iface.stripUIData scrapers
		chrome.storage.local.set data

	encodeHtml = (html) -> html.replace(/</g, '&lt;').replace(/>/g, '&gt;')

	window.start = (->
		iface.setInputs
			text: (data, binding, element) ->
				el = $ "<input type='text' placeholder='#{element.bind}'>"
				el.val binding.get()
				el.keyup -> binding.set el.val()
				el

			textarea: (data, binding, element) ->
				el = $ "<textarea placeholder='#{element.bind}'></textarea>"
				el.val binding.get()
				el.keyup -> binding.set el.val()
				el

			select: (data, binding, element) ->
				el = $ "<select><option value=''>#{data.emptyLabel ? element.bind}</option></select>"
				for value in data.values
					optionEl = $("<option value='#{value}'>#{value}</option>")
					if binding.get() == value
						optionEl.prop 'selected', true
					el.append optionEl
				el.change -> binding.set el.val()
				el

			checkbox: (data, binding, element) ->
				el = $ "<input type='checkbox'> <label>#{element.bind}</label>"
				if binding.get()
					el.prop 'checked', true
				else
					el.prop 'checked', false

				el.change ->
					binding.set el.prop 'checked'
				el

		addMatchPreview = (el) ->
			el.children('.pattern').before('<div class="matchPreview" />')
			el.children('.pattern').find('input').keyup -> update()

		iface.setInterfaces
			root:
				elements: [
					{
						bind: 'site'
						input: 'text'
					}
					{
						bind: 'name'
						input: 'text'
					}
					{
						bind: 'pages'
						interface: 'pages'
					}
					# {
					# 	bind: 'value'
					# 	interface:'value'
					# }
					# {
					# 	bind:'matches'
					# 	interface:'matches'
					# }
					{
						bind:'properties'
						interface:'properties'
					}
				]
				init: (el) ->
					el.find('.site').keyup -> updateScrapers()
					el.find('.name').keyup -> updateScrapers()

			properties:
				type: 'dictionary'
				valueInterface: 'property'

			property:
				elements: [
					{
						bind: 'value'
						interface:'value'
					}
					{
						bind:'matches'
						interface:'matches'
					}
				]

			pages:
				type:'list'
				elementType: 'page'
			page:
				elements: [
					bind: 'url'
					input: 'text'
				]

				init: (el, data) ->
					page = data.get()
					setTimeout (->
						index = el.parents('li:first').index()

						if page?.url
							currentVersion = version
							$.get page?.url, (response) ->
								return if currentVersion != version

								Pages[index] = response
							el.addClass 'downloaded'


						el.find('[type=text]').change ->
							currentVersion = version
							el.removeClass 'downloaded'
							$.get page?.url, (response) ->
								return if currentVersion != version
								Pages[index] = response
								el.addClass 'downloaded'
					), 0

					el.append $("<input type='radio' name='page'>").change ->
						page = $('[name="page"]:checked').parents('.interface.page').parents('li:first').index()
						$('#pages .source').hide()
						$($('#pages li').get(page)).find('.source').show()
						update()

			value: 
				elements: [
					{
						bind: 'type'
						input:
							# emptyLabel: 'string'
							type: 'select'
							values: ['object', 'array']
					}
					{
						bind: 'name'
						input: 'text'
					}
					{
						bind: 'capture'
						input: 'text'
					}
					{
						bind: 'content'
						input: 'textarea'
					}
				]

			matches:
				type: 'list'
				elementTypes: ['Match', 'MatchAll', 'Or', 'Switch', 'Count']
				map: (el) -> el.type
				initObj: (obj, type) ->
					obj.type = type

			captures:
				type: 'dictionary'
				valueInterface: 'capture'


			capture:
				elements: [
					{
						bind: 'value'
						interface: 'value'
					}
					{
						bind: 'matches'
						interface: 'matches'
					}
				]

			Match:
				init: (el) ->
					addMatchPreview el

				elements: [
					{
						bind: 'disabled'
						input: 'checkbox'
					}
					{
						bind: 'optional'
						input: 'checkbox'
					}
					{
						bind: 'pattern'
						input: 'text'
					}
					{
						bind: 'value'
						interface: 'value'
					}
					{
						bind: 'captures'
						interface: 'captures'
					}
				]

			Or:
				elements: [
					{
						bind: 'disabled'
						input: 'checkbox'
					}
					{
						bind: 'optional'
						input: 'checkbox'
					}
					{
						bind: 'value'
						interface: 'value'
					}
					{
						bind: 'matches'
						interface: 'matches'
					}
				]

			Switch:
				elements: [
					{
						bind: 'disabled'
						input: 'checkbox'
					}
					{
						bind: 'optional'
						input: 'checkbox'
					}
					{
						bind: 'value'
						interface: 'value'
					}
					{
						bind: 'cases'
						interface: 'cases'
					}
				]

			cases:
				type: 'list'
				elementType: 'case'

			case:
				init: (el) ->
					addMatchPreview el

				elements: [
					{
						bind: 'disabled'
						input: 'checkbox'
					}
					{
						bind: 'value'
						interface: 'value'
					}
					{
						bind: 'pattern'
						input: 'text'
					}
					{
						bind: 'matches'
						interface: 'matches'
					}
				]

			MatchAll:
				init: (el) ->
					addMatchPreview el
					el.children('.matchPreview').before $('<input type="text" class="match">').keyup -> update()

				elements: [
					{
						bind: 'disabled'
						input: 'checkbox'
					}
					{
						bind: 'optional'
						input: 'checkbox'
					}
					{
						bind: 'pattern'
						input: 'text'
					}
					{
						bind: 'value'
						interface: 'value'
					}
					{
						bind: 'match.value'
						interface: 'value'
					}

					{
						bind: 'match.captures'
						interface: 'captures'
					}
				]

			Count:
				init: (el) ->
					addMatchPreview el
				elements: [
					{
						bind: 'disabled'
						input: 'checkbox'
					}
					{
						bind: 'optional'
						input: 'checkbox'
					}
					{
						bind: 'pattern'
						input: 'text'
					}
				]
		iface.setOnModified -> save()

		$ ->
			$('body').addClass 'showValues'
			$('body').append '<textarea id="html" style="display:none"/>'
			$('body').append '<div id="topBar" />'

			do ->
				`var el`
				setSelectedScraper = (i) ->
						++version
						CurrentScraper = scrapers[i]
						resetInterface()
						data = {}
						data['scrapeDev.selectedScraper'] = i
						chrome.storage.local.set data

				el = $('<select />')
					.appendTo '#topBar'
					.change ->
						setSelectedScraper parseInt el.val()
						# CurrentScraper = scrapers[el.val()]
						# resetInterface()
						# data = {}
						# data['scrapeDev.selectedScraper'] = el.val()
						# chrome.storage.local.set data

				chrome.storage.local.get 'scrapeDev.selectedScraper', (data) ->
					el.prop 'selectedIndex', data['scrapeDev.selectedScraper']
					setSelectedScraper data['scrapeDev.selectedScraper']


				window.updateScrapers = ->
					selectedIndex = el.prop 'selectedIndex'
					el.html ''
					for scraper,i in scrapers
						optionEl = $ "<option value='#{i}'>#{scraper.site ? '*'} #{scraper.name ? '*'}</option>"
						el.append optionEl
					el.prop 'selectedIndex', selectedIndex if selectedIndex >= 0


				$('<button>+</button>')
					.appendTo '#topBar'
					.click ->
						scrapers.push {}
						save()
						updateScrapers()
						setCurrentScraper scrapers.length - 1
						el.prop 'selectedIndex', scrapers.length - 1


				$('<button>-</button>')
					.appendTo('#topBar')
					.click ->
						scrapers.splice el.val(), 1
						newScraper = Math.max 0, el.prop('selectedIndex') - 1
						save()
						el.prop 'selectedIndex', newScraper
						updateScrapers()
						setCurrentScraper newScraper
				updateScrapers()


			$('<button>Reload CSS</button>')
				.appendTo '#topBar'
				.click ->
					$('link').remove()
					$('<link rel="stylesheet" type="text/css" href="scrapeDev/styles.css?' + new Date().getTime() + '">').appendTo 'head'

			$('<button>Toggle Value</button>')
				.appendTo '#topBar'
				.click ->
					$('body').toggleClass 'showValues'

			$('<button>Execute</button>')
				.appendTo '#topBar'
				.click ->
					doExecuteMatch()

			$('<button>Get Data</button>')
				.appendTo '#topBar'
				.click ->
					el = $('<textarea />')
						.html(JSON.stringify iface.stripUIData Data)
						.appendTo('body')
						.select()
					document.execCommand('copy')
					el.remove()

			$('<button>Upload</button>')
				.appendTo '#topBar'
				.click ->
					data = JSON.stringify iface.stripUIData CurrentScraper
					$.post 'http://ext.agora.sh/uploadScraper.php', data:data

			$('<button>Download All</button>')
				.appendTo '#topBar'
				.click ->
					$.get 'http://ext.agora.sh/getScrapers.php', ((response) ->
						scrapers = response.scrapers
						save()
						updateScrapers()
						setCurrentScraper 0
					), 'json'

			$('<span id="noMatches" />').appendTo '#topBar'

			noMatches = 0

			updateMatches = (matchObjs, content, force=false) ->
				for match in matchObjs
					switch match.type
						when 'Match'
							matchPreviewEl = match['.ui'].el.children('.matchPreview')
							if match.pattern && match.pattern != match['.ui'].lastPattern || force
								match['.ui'].lastPattern = match.pattern
								regExp = new RegExp match.pattern
								matches = content.match regExp
								if matches
									matchPreviewEl.html encodeHtml matches[0] 
									if match.captures
										for group,capture of match.captures
											if capture.matches
												updateMatches capture.matches, matches[parseInt group], true

								else
									matchPreviewEl.html 'no match'
									++ noMatches
							else
								matchPreviewEl.html ''

						when 'MatchAll'
							matchPreviewEl = match['.ui'].el.children('.matchPreview')
							if match.pattern && match.pattern != match['.ui'].lastPattern || force
								match['.ui'].lastPattern = match.pattern
								regExp = new RegExp match.pattern
								matches = content.match new RegExp match.pattern, 'g'
								if matches?.length
									matchNum = parseInt match['.ui'].el.children('.match').val()
									if isNaN matchNum
										matchNum = 0

									matchPreviewEl.html matches.length + ': ' + encodeHtml matches[matchNum]
									if match.match?.captures
										for group,capture of match.match.captures
											if capture.matches
												groupMatches = matches[matchNum].match(regExp)
												if groupMatches
													if parseInt(group) < groupMatches.length
														updateMatches capture.matches, groupMatches[parseInt group], true
													else
														throw new Error "#{group} > #{groupMatches.length}"
												else 
													throw new Error()

								else
									matchPreviewEl.html 'no match'
									++ noMatches
							else
								matchPreviewEl.html ''

						when 'Switch'
							if match.cases
								for caseObj in match.cases
									matchPreviewEl = caseObj['.ui'].el.children('.matchPreview')			
									if caseObj.pattern && caseObj.pattern != caseObj['.ui'].lastPattern || force
										caseObj['.ui'].lastPattern = caseObj.pattern
										regExp = new RegExp caseObj.pattern
										matches = content.match regExp
										if matches
											matchPreviewEl.html encodeHtml matches[0]
											if caseObj.matches
													updateMatches caseObj.matches, content, true

										else
											matchPreviewEl.html 'no match'
											++ noMatches
									else
										matchPreviewEl.html ''

						when 'Or'
							if match.matches
								updateMatches match.matches, content

			getPage = ->
				page = $('[name="page"]:checked').parents('.interface.page').parents('li:first').index()
				Pages[if page == -1 then 0 else page]

			getSubject = ->
				getPage()

			window.update = ->
				# for page in Pages.pages
					# if page.content
				noMatches = 0
				if getSubject()
					for name,property of CurrentScraper.properties
						continue if name == '.ui'
						updateMatches property.matches, getSubject(), true if property.matches
				$('#noMatches').html noMatches


			window.doExecuteMatch = ->
				if getSubject()
					properties = {}
					paths = {}
					for name,property of iface.stripUIData(CurrentScraper.properties)
						scraper = new DeclarativeScraper property
						try
							properties[name] = scraper.scrape(getSubject())[0]?.value
						catch e
							if e.message == 'FailedRequirement'
								console.debug "#{name} failed", scraper.path
							else
								console.debug scraper.path
								throw e
						paths[name] = scraper.path

					console.debug properties, paths
			console.debug 'asdf'
			window.resetInterface = ->
				Pages = {}
				$('body').children('.root').remove()
				$('body').append iface.createInterface 'root', new iface.DataInterface CurrentScraper
				update()

			setCurrentScraper scrapers.length - 1
	)
	# start()