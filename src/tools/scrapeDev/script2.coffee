
chrome.storage.local.get 'scrapeDev', (data) ->
	Data = data.scrapeDev ? {"pages":[{"url":"http://www.amazon.com/gp/product/B00FGL5IG4/ref=s9_simh_gw_p193_d0_i2?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=0H7C5ADJE855G6BA582X&pf_rd_t=101&pf_rd_p=1688200382&pf_rd_i=507846"}],"rootCaptures":[{"pattern":"<div id=\"rev-dpReviewsMostHelpfulAUI-R3QD2CF3I9ZMPQ\" class=\"a-section\">([\\S\\s]*?)<a id=\"R3QD2CF3I9ZMPQ.2115.Helpful.Reviews\"></a>","captures":[{"pattern":"title=\"(\\S+) out of 5 stars\"","captures":[]},{"pattern":"<a href=\"/gp/pdp/profile/[^/]*/ref=cm_cr_dp_pdp\" class=\"noTextDecoration\">([^<]*)</a>","captures":[]},{"pattern":"<span class=\"a-color-secondary\"> on ([^<]*)</span>","captures":[]},{"pattern":"<div class=\"a-section\">\\s*([\\S\\s]*?)\\s*</div>","captures":[]}],"name":"reviews","global":true}]}


	$ ->
		save = ->
			chrome.storage.local.set scrapeDev:Data

		class ListInterface
			constructor: (args) ->
				@new = args.new
				@el = args.el
				@array = args.array

				if @array
					for el in @array
						@_add el

			_add: (data) ->
				removeFunc = null
				el = @new data,
					remove: =>
						el.remove()
						removeFunc?()
						if @array
							_.pull @array, data

					onRemove: (func) -> removeFunc = func


				@el.append el

			add: (data) ->
				@_add data
				if @array
					@array.push data

				save()



		$('<button>Reload CSS</button>')
			.appendTo 'body'
			.click ->
				$('link').remove()
				$('<link rel="stylesheet" type="text/css" href="scrapeDev/styles.css?' + new Date().getTime() + '">').appendTo 'head'

		$('<button>Get Data</button>')
			.appendTo 'body'
			.click ->
				el = $('<textarea />')
					.html(JSON.stringify Data)
					.appendTo('body')
					.select()
				document.execCommand('copy')
				el.remove()


		_getCode = (args) ->
			i = args.indent ? ''
			i2 = i + '	'
			code = "#{i}((subject, data) ->\n"
			for captureId, capture of args.captures
				name = "data.#{capture.name}"
				pattern = capture.pattern.replace(/\//g, '\\/')
				if capture.global
					if capture.captures.length
						subCaptures = _getCode(
							captures:capture.captures
							subject:"match.match(/#{pattern}/)[#{capture.group}]"
							object:'obj'
							indent:i2 + '	'
						)

						code += """
#{i2}matches = subject.match(/#{pattern}/g)
#{i2}#{name} = for match in matches
#{i2}	obj = {}
#{i}#{subCapture}
#{i2}	obj
"""
					else
						code += "#{i2}#{name} = match.match(/#{pattern}/)[#{capture.group}] for match in subject.match(/#{pattern}/g)\n"

				else
					if capture.captures.length
						code += "#{i2}#{name} = {}\n"
						code += "#{i2}matches = /#{pattern}/.exec(subject)[#{capture.group}]\n"
						subCaptures = _getCode(
							captures:capture.captures
							subject:"matches"
							object:name
							indent:i2
						)
						code += "#{i}#{subCaptures}\n"
					else
						code += "#{i2}#{name} = /#{pattern}/.exec(subject)[#{capture.group}]\n"


			code += "#{i})(#{args.subject}, #{args.object})\n"

			code



		getCode = ->
			_getCode captures:Data.rootCaptures, subject:'STRING', object:'ROOT'
		console.debug getCode()

		$('<button>Get Code</button>')
			.appendTo 'body'
			.click ->


				el = $('<textarea />')
					.html(getCode())
					.appendTo('body')
					.select()
				document.execCommand('copy')
				el.remove()




		encodeHtml = (html) -> html.replace(/</g, '&lt;').replace(/>/g, '&gt;')

		pagesEl = $('<ul id="pages" />').appendTo 'body'

		addPageEl = $('<input type="text">')
			.keydown (e) -> (addPage(); $(@).val '') if e.keyCode == 13
			.appendTo 'body'

		Pages = 
			pageCount:0
			pages:[]

		pagesIface = new ListInterface
			array: Data.pages
			el: pagesEl
			new: (data, control) ->
				url = data.url
				pageEl = $("
					<li>
						<span class='url'>#{url}</span>
						<div class='source' />
					</li>
				")

				$('<input value="Toggle Size" type="button">')
					.appendTo pageEl
					.click -> pageEl.toggleClass 'fullscreen'

				page = {}

				Pages.pages[Pages.pageCount++] = page

				$.get url, (response) ->
					page.content = response
					pageEl.find('.source').html encodeHtml response

				pageEl



		addPage = ->
			pagesIface.add url:addPageEl.val()



		add = (parentEl, contentFunc, array) ->
			update = ->
				# console.debug captures
				for capture,i in captures
					regExp = new RegExp capture.pattern
					for content,contentId in contentFunc()
						capture.update contentId, regExp.exec content


			captures = []
			contEl = $('<div />').appendTo parentEl
			capturesEl = $('<ul id="captures" />').appendTo contEl
			capturesIface = new ListInterface
				el:capturesEl
				array:array
				new: (data, control) ->
					captureData = {}

					capture =
						pattern:data.pattern
						update: (contentId, matches) ->
							captureData[contentId] = matches
							captureEl.children('.captureData').html('')

							for contentId, matches of captureData
								do (contentId, matches) ->
									el = $('<li />').appendTo captureEl.children('.captureData')
									if matches
										el.append '<ol />'
										for match,i in matches
											el.find('ol').append $('<li class="match" />').addClass(if i == data.group then 'selected').html encodeHtml match
									else
										el.html 'no matches'

							# captureEl.find('.captureData').html encodeHtml ("#{contentId}:#{matches?[0] ? 'no matches'}" for contentId,matches of captureData).join(' -- ')

					capturesIndex = captures.length
					captures.push capture
					captureEl = $('<li>
							<button class="update">Update</button>
							<input type="checkbox" class="global">
							<input type="text" class="name" value="" placeholder="Name">
							<input type="text" class="group" value="" placeholder="Group">
							<input type="text" class="pattern" value="" placeholder="Pattern">
							<ol class="captureData" />
						</li>')
						.find('.update').click(->update()).end()
						.find('.global')
							.prop 'checked', data.global
							.change -> data.global = @checked; save()
							.end()
						.find('.name')
							.val data.name
							.keyup -> data.name = $(@).val(); save()
							.end()
						.find('.pattern')
							.val data.pattern
							.keyup -> data.pattern = capture.pattern = $(@).val(); update(); save()
							.end()
						.find('.group')
							.val data.group
							.keyup -> data.group = parseInt $(@).val(); update(); save()
							.end()

					add captureEl, (-> matches[0] for contentId,matches of captureData), data.captures

					captureEl.append $('<button>Remove</button>').click -> control.remove()
					control.onRemove -> captures.splice capturesIndex, 1
					captureEl


			$('<button>Add Capture</button>')
				.appendTo contEl
				.click -> capturesIface.add pattern:'', captures:[]

		add 'body', (-> page.content for page in Pages.pages), Data.rootCaptures
