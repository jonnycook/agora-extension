define -> d: ['View', 'util', 'icons'], c: -> 
	class AddArgumentView extends View
		type: 'AddArgument'
		constructor: ->
			super
			@el = @viewEl '<div class="v-addArgument dark">
				<div class="content">
					<ul class="arguments">
						<li>
							<span class="position" />
							<span class="thought" />
							<a href="#" class="delete" />
						</li>
					</ul>
					<form>
						<input type="text" name="argument" placeholder="Add argument" autocomplete="off"><span class="positionPreview" />
						<!--<input type="submit" value="Add">-->
					</form>
				</div>
			</div>'


			parse = (argument) ->
				against = 0
				pro = 0

				argument = argument.trim()

				for i in [0...argument.length]
					char = argument[i]
					if char == '-'
						++against
					else if char == '+'
						++pro
					else
						break

				argument = argument.substr i
				for j in [argument.length-1...0]
					char = argument[j]

					if char == '-'
						++against
					else if char == '+'
						++pro
					else
						break

				argument = argument.substr(0, j+1).trim()

				# if !(against && pro)
				# 	words = 
				# 		"-2": ['hate', 'really don\'t like']
				# 		"-1": ['don\'t like', 'bad', 'ugly', 'poor', 'stupid', 'dumb', 'shitty', 'stinks']
				# 		"1": ['like', 'cool', 'good', 'nice', 'classy']
				# 		"2": ['love', 'awesome']
					
				# 	wordList = []

				# 	map = {}
				# 	for emotion,emotionWords of words
				# 		for word in emotionWords
				# 			map[word] = parseInt emotion
				# 			wordList.push word

				# 			strippedWord = word.replace '\'', ''
				# 			if word != strippedWord
				# 				map[strippedWord] = map[word]
				# 				wordList.push strippedWord

				# 	wordList.sort (a, b) -> b.length - a.length

				# 	for word in wordList
				# 		if argument.indexOf(word) != -1
				# 			emotion = map[word]
				# 			if emotion < 0
				# 				against -= emotion
				# 			else if emotion > 0
				# 				pro += emotion

				[pro, against, argument]


			arugmentEl = @el.find('[name=argument]')
			positionPreviewEl = @el.find('.positionPreview')


			arugmentEl.keydown (e) =>
				if e.keyCode == 27
					@close true

			arugmentEl.keyup (e) =>
				[pro, against] = parse arugmentEl.val()
				position = util.positionClass pro, against
				positionPreviewEl.removeClass().addClass('positionPreview').addClass position

			@el.find('form').submit (e) =>
				e.preventDefault()
				[pro, against, thought] = parse arugmentEl.val()
				@callBackgroundMethod 'add', [pro, against, thought]
				@el.find('form [name="argument"]').val ''
				setTimeout (=>@close()), 700
				false


		onData: (@data) ->
			iface = @listInterface @el, '.arguments li', (el, data, pos, onRemove) =>
				view = @view()
				onRemove -> view.destruct()
				view.valueInterface(el.find('.thought')).setDataSource data.thought
				# view.valueInterface(el.find('.emotion')).setDataSource data.emotion

				previousPosition = null
				updateForPosition = =>
					position = util.positionClass data.for.get(), data.against.get()

					if previousPosition
						el.find('.position').removeClass previousPosition

					el.find('.position').addClass position
					previousPosition = position

				data.for.observe updateForPosition
				data.against.observe = updateForPosition
				updateForPosition()

				el.find('.delete').click =>
					@callBackgroundMethod 'delete', data.id
					false
				el

			iface.onInsert = =>
				@sizeChanged?()

			iface.onDelete = (el, del) =>
				del()
				@sizeChanged?()



			iface.setDataSource data
			setTimeout (=> @el.find('[name=argument]').get(0).focus()), 50

