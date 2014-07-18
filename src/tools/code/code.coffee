load = (name, cb) ->
	chrome.storage.local.get 'codeDev', (data) -> cb data.codeDev?[name]

save = (name, value) ->
	chrome.storage.local.get 'codeDev', (data) ->
		data.codeDev ?= {}
		data.codeDev[name] = value
		chrome.storage.local.set codeDev:data.codeDev


$ ->
	evalEl = $('<iframe src="scrapeDev/eval.html" />').appendTo('body').hide()
	usingSite = 0

	do ->
		el = $('<div id="sitesArea">
			<input type="text" name="usingSite" value="0">
			<textarea id="sites" />
		</div>').appendTo 'body'


		$('#sites').change -> 
			Sites.updateSites $(@).val()
			save 'sites', $(@).val()

		$('[name=usingSite]').keyup ->
			usingSite = parseInt $(@).val()
			update()

	load 'sites', (sites) ->
		$('#sites').val sites
		Sites.updateSites sites

	encodeHtml = (html) -> html.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

	update = ->
		if Sites.siteList[usingSite]?.content
			$('#html').html encodeHtml Sites.siteList[usingSite].content
			doRun()

	Sites =
		sites:{}
		siteList:[]
		downloadSite: (site) ->
			console.debug "downloading site #{site}"
			@sites[site] = index:@siteList.length
			@siteList[@sites[site].index] = @sites[site]
			$.get site, ((response) =>
				@sites[site].content = response
				update()
			), 'text'
		updateSites: (sitesString) ->
			sites = sitesString.split /\s+/g
			for site in sites
				site = site.trim()
				if site
					if !@sites[site]
						@downloadSite site



	$('
		<div id="area">
			<div id="html" />
			<div id="editor" />
			<div id="outputPanel">
				<input type="text">
				<div id="output" />
			</div>
		</div>
	').appendTo 'body'

	$('#outputPanel > input').keyup ->
		save 'filter', $(@).val()
		updateOutput()

	load 'filter', (filter) -> $('#outputPanel > input').val filter


	doRun = ->
		if Sites.siteList[usingSite]
			code = CoffeeScript.compile editor.getValue(), bare:on
			run code

	run = (code) ->
		code = code.replace /(.*?)\s*=\s*matchAll/g, (match, variable) ->
			"set('#{variable}'); #{match}"

		code = code.replace /(.*?)\s*=\s*.*?\.match/g, (match, variable) ->
			"set('#{variable}'); #{match}"

		code = code.replace /(.*?)\s*=\s*\/.*?\/\.exec/g, (match, variable) ->
			"set('#{variable}'); #{match}"


		# console.debug code

		subject = Sites.siteList[usingSite].content
		evalEl.get(0).contentWindow.postMessage subject:subject, code:code, '*'
		# eval code



	compileTimer = null
	setTimeout (->
		editor.doc.on 'change', ->
			save 'code', editor.getValue()
			clearTimeout compileTimer
			compileTimer = setTimeout (->
				doRun()
			), 200

		chrome.storage.local.get 'codeDev', (data) ->
			editor.setValue data.codeDev?.code
	), 0

	createEntryEl = (entry) ->
		el = $ "<div class='entry' />"

		if entry.type == 'match'
			el.append "<div class='name'>#{entry.name}</div>" if entry.name
			if entry.value
				el.append '<ul />'

				for match in entry.value
					el.find('ul').append $('<li />').html encodeHtml match
			else
				el.html 'no match'
			el
		else if entry.type == 'matchAll'
			el.append "<div class='name'>#{entry.name}</div>" if entry.name
			el.append '<ul />'
			for matches in entry.value
				matchesEl = $('<li><ul /></ul>').appendTo el.children('ul')
				for match in matches
					matchesEl.children('ul').append $('<li />').html encodeHtml match
			el
		else if entry.type == 'variable'
			el.append "<div class='name'>#{entry.name}</div>"
			el.append "<div class='json'>#{JSON.stringify entry.value, undefined, 2}</div>"
			el

	output = null

	updateOutput = ->
		# console.log output
		$('#output').html ''

		if output
			if $('#outputPanel > input').val()
				filter = $('#outputPanel > input').val().split /,\s*/
				for name in filter
					for entry in output
						if entry.name && entry.name == name
							$('#output').append createEntryEl entry

				for entry in output
					if !entry.name
						$('#output').append createEntryEl entry
			else
				for entry in output
					$('#output').append createEntryEl entry

	window.addEventListener 'message', (event) ->
		output = event.data
		updateOutput()
