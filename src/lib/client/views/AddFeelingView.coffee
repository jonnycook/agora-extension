define -> d: ['View', 'util', 'icons'], c: -> 
	class AddFeelingView extends View
		type: 'AddFeeling'
		init: (args={}) ->
			@el = @viewEl '<div class="v-addFeeling dark">
				<div class="content">
					<ul class="feelings">
						<li>
							<span class="emotion" />
							<span class="thought" />
							<a href="#" class="delete" />
						</li>
					</ul>
					<form>
						<input type="text" name="feeling" placeholder="Add feeling" autocomplete="off"><span class="emotionSummary neutral" />
						<!--<input type="submit" value="Add">-->
					</form>
				</div>
			</div>'


			parse = (feeling) ->
				negative = 0
				positive = 0

				feeling = feeling.trim()

				for i in [0...feeling.length]
					char = feeling[i]
					if char == '-'
						++negative
					else if char == '+'
						++positive
					else
						break

				feeling = feeling.substr i
				for j in [feeling.length-1...0]
					char = feeling[j]

					if char == '-'
						++negative
					else if char == '+'
						++positive
					else
						break

				feeling = feeling.substr(0, j+1).trim()

				if !(negative || positive)
					words = 
						"-2": ['hate', 'really dont like', 'terrible', 'disgusting']
						"-1": ['dont like', 'bad', 'ugly', 'poor', 'stupid', 'dumb', 'shitty', 'stinks', 'nasty', 'wretched', 'low quality', 'sad']
						"1": ['like', 'cool', 'good', 'nice', 'classy', 'tasteful', 'cute', 'happy']
						"2": ['love', 'awesome', 'great', 'perfect', 'fantastic', 'wonderful', 'beautiful', 'sensational', 'magical']
					
					wordList = []

					map = {}
					for emotion,emotionWords of words
						for word in emotionWords
							map[word] = parseInt emotion
							wordList.push word

							# strippedWord = word.replace '\'', ''
							# if word != strippedWord
							# 	map[strippedWord] = map[word]
							# 	wordList.push strippedWord

					wordList.sort (a, b) -> b.length - a.length
					matchingFeeling = feeling.replace('\'', '').split(/\s+/).join ' '

					for word in wordList
						pattern = new RegExp("\\b#{word}\\b", 'i')
						if (index = matchingFeeling.search(pattern)) != -1
							matchingFeeling = matchingFeeling.replace pattern, ''

							emotion = map[word]
							if emotion < 0
								negative -= emotion
							else if emotion > 0
								positive += emotion

				[positive, negative, feeling]


			feelingEl = @el.find('[name=feeling]')
			emotionEl = @el.find('.emotionSummary')


			feelingEl.keydown (e) =>
				if e.keyCode == 27
					@close true
					e.stopPropagation()

			feelingEl.keyup (e) =>
				@pin?()
				[positive, negative] = parse feelingEl.val()
				emotion = util.emotionClass positive, negative
				emotionEl.removeClass().addClass('emotionSummary').addClass emotion

			@el.find('form').submit (e) =>
				e.preventDefault()
				[positive, negative, thought] = parse feelingEl.val()
				if args.auto
					@event 'add', 'auto'
				else
					@event 'add'
				@callBackgroundMethod 'add', [positive, negative, thought]
				@el.find('form [name="feeling"]').val ''
				setTimeout (=>@close()), 700
				false


		onData: (@data) ->
			iface = @listInterface @el, '.feelings li', (el, data, pos, onRemove) =>
				view = @view()
				onRemove -> view.destruct()
				view.valueInterface(el.find('.thought')).setDataSource data.thought
				# view.valueInterface(el.find('.emotion')).setDataSource data.emotion

				previousEmotion = null
				updateForEmotion = =>
					emotion = util.emotionClass data.positive.get(), data.negative.get()

					if previousEmotion
						el.find('.emotion').removeClass previousEmotion

					el.find('.emotion').addClass emotion
					previousEmotion = emotion



				data.positive.observe updateForEmotion
				data.negative.observe = updateForEmotion
				updateForEmotion()

				el.find('.delete').click =>
					@event 'delete'
					@callBackgroundMethod 'delete', data.id
					false
				el

			iface.onInsert = =>
				@sizeChanged?()

			iface.onDelete = (el, del) =>
				del()
				@sizeChanged?()



			iface.setDataSource @data
			setTimeout (=> @el.find('[name=feeling]').get(0).focus()), 50

		shown: ->
			@event 'open'
			_tutorial 'AddFeeling', @el.find('form [name="feeling"]')