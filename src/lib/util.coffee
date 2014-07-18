define ['Site', 'underscore', 'ObjectWrapper'], (Site, _, ObjectWrapper) ->
	util = 
		syncArrays: (ctx, a, b, mapping) ->
			setRemoveCallback = (cb, position) ->
				b.__removeCallback ?= []
				b.__removeCallback[position] = cb
			
			a.each (el, i) ->
				b.push mapping(el, ((cb) -> setRemoveCallback(cb, i)), i)
			
			b.__syncedTo = a
			ctx.observe a, b.__syncObserver = (mutation) ->
				if mutation.type == 'insertion'
					b.insert mapping(mutation.value, ((cb) -> setRemoveCallback(cb, mutation.position)), mutation.position), mutation.position
				else if mutation.type == 'deletion'
					b.__removeCallback?[mutation.position]?()
					b.delete mutation.position
				else if mutation.type == 'movement'
					b.move mutation.from, mutation.to

		unsyncArrays: (a, b) ->
			a.stopObserving b.__syncObserver
			delete b.__syncObserver


		unsync: (array) ->
			@unsyncArrays array.__syncedTo, array

		reorder: (list, fromIndex, toIndex) ->
			instance = list.get(fromIndex)
			if toIndex > fromIndex
				for i in [fromIndex+1..toIndex]
					list.get(i).set('index', i - 1)
			else if fromIndex > toIndex
				for i in [fromIndex-1..toIndex]
					list.get(i).set('index', i + 1)
				
			instance.set('index', toIndex)

		addElement: (obj, element) ->
			obj.get('contents').add util.resolveObject element

		resolveObject: (element) ->
			if _.isFunction element.getObj
				element.getObj()
			else if element.obj
				element.obj
			else if element.modelName.match /Element$/
				element.get 'element'
			else
				element

		feelingEmotionString: (feeling) ->
			emotion = ''
			emotion += '+' for i in [0...feeling.get('positive')]
			emotion += '-' for i in [0...feeling.get('negative')]
			emotion

		listPreview: (ctx, list) ->
			clientList = ctx.clientArray()
			getContents = =>
				stack = [list:list, pos:0]
				contents = []
				sources = [list]

				while stack.length && contents.length < 4 
					state = stack[stack.length - 1]

					if state.list.length() == state.pos
						stack.pop()
						continue

					obj = state.list.get(state.pos++).get('element')

					loop
						if obj.modelName in ['Product', 'ProductVariant']
							contents.push obj.getDisplayValue 'image'
							sources.push obj.field('image')

						else if obj.modelName == 'Decision'
							stack.push list:obj.get('selection'), pos:0
							sources.push obj.get('selection')

						else if obj.modelName == 'Bundle'
							stack.push list:obj.get('elements'), pos:0
							sources.push obj.get('elements')
						break

				[contents, sources]

			reset = =>
				ctx.clear()
				[contents, sources] = getContents()
				for source in sources
					ctx.observe source, (mutation) =>
						reset()
				clientList.setArray contents

			reset()
			clientList

		dismissDecisionElement: (decision, element) ->
			# if !decision.get('dismissal_list_id')
				# list = decision.model.manager.getModel('List').create()
				# decision.set 'dismissal_list_id', list.get 'id'

			# decision.get('dismissalList').get('contents').add element.get('element')

			decision.get('dismissed').add element
			# element.delete()


		lastFeeling: (ctx, product, lastFeelingCv=null) ->
			lastFeelingCv ?= ctx.clientValue()
			updateLastFeeling = =>
				feelings = product.get('feelings')
				lastFeeling = if feelings.length()
					feelings.get feelings.length() - 1

				if lastFeeling
					emotion = util.feelingEmotionString lastFeeling
					lastFeelingCv.set thought:lastFeeling.get('thought'), positive:lastFeeling.get('positive'), negative:lastFeeling.get('negative')
				else
					lastFeelingCv.set null
			updateLastFeeling()
			ctx.observe product.get('feelings'), updateLastFeeling

			lastFeelingCv

		lastArgument: (ctx, product, lastArgumentCv) ->
			lastArgumentCv ?= ctx.clientValue()
			updateLastArgument = =>
				arguments_ = product.get('arguments')
				lastArgument = if arguments_.length()
					arguments_.get arguments_.length() - 1

				if lastArgument
					lastArgumentCv.set thought:lastArgument.get('thought'), for:lastArgument.get('for'), against:lastArgument.get('against')
				else
					lastArgumentCv.set null
			updateLastArgument()
			ctx.observe product.get('arguments'), updateLastArgument

			lastArgumentCv

		feelings: (parentCtx, obj) ->
			parentCtx.clientArray obj.get('feelings'), (feeling, onRemove) =>
				ctx = parentCtx.context()
				onRemove -> ctx.destruct()

				emotion = util.feelingEmotionString feeling

				id:feeling.get 'id'
				negative:ctx.clientValue feeling.field 'negative'
				positive:ctx.clientValue feeling.field 'positive'
				# emotion:ctx.clientValue emotion
				thought:ctx.clientValue feeling.field 'thought'

		arguments: (parentCtx, obj) ->
			parentCtx.clientArray obj.get('arguments'), (argument, onRemove) =>
				ctx = parentCtx.context()
				onRemove -> ctx.destruct()

				id:argument.get 'id'
				for:ctx.clientValue argument.field 'for'
				against:ctx.clientValue argument.field 'against'
				# emotion:ctx.clientValue emotion
				thought:ctx.clientValue argument.field 'thought'

		resolveProducts: (obj,p=false) ->
			if obj.isA 'Product'
				[obj]
			else if obj.isA 'Bundle'
				objs = []
				id = obj.get('id')
				obj.get('elements').each (el) ->
					objs = objs.concat util.resolveProducts el.get('element'), id
				objs
			else if obj.isA 'Decision'
				objs = []
				obj.get('selection').each (el) ->
					objs = objs.concat util.resolveProducts el.get('element')
				objs
			else
				[]

		observeContents: (ctx, elements, cb) ->
			observeElement = (el) ->
				ctx.observe el.get('element'), ->
					observeObj el.get('element')
					cb()
				observeObj el.get('element')

			observeObj = (obj) ->
				if obj.isA('Bundle') || obj.isA('Decision')
					els = if obj.isA('Decision') then obj.get('selection') else obj.get('elements')
					util.observeContents ctx, els, cb

			ctx.observe elements, (mutation) ->
				if mutation.type == 'insertion'
					observeElement mutation.value
				cb()

			elements.each (el) ->
				observeElement el


		# http://stackoverflow.com/a/2901298/323330
		numberWithCommas: (x) -> 
			if x?
				parts = x.toString().split('.')
				parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
				parts.join('.')

		stripHtml: (html, tags=null, baseUrl=null) ->
			return html unless _.isString html
			tags ?= ['h1', 'h2', 'h3', 'h4', 'p', 'small', 'b', 'small', 'a', 'br', 'em', 'ul', 'li']
			html.replace(/<\s*(\/?)\s*(\w*)([^>]*)>/g, (match, slash, tag, attrs) ->
				# console.debug tag
				tag = tag.toLowerCase()
				if tag in tags
					if slash
						"</#{tag}>"
					else
						newAttrs = {}
						if tag == 'a'
							matches = attrs.match(/href\s*=\s*"([^"]*)"/)
							if matches
								newAttrs['href'] = util.url matches[1], baseUrl
								newAttrs['target'] = '_blank'

						else if tag == 'img'
							matches = attrs.match(/src\s*=\s*"([^"]*)"/)
							if matches
								newAttrs['src'] = matches[1]
								newAttrs['width'] = 100

						newAttrs = ("#{field}=\"#{value}\"" for field,value of newAttrs).join(' ')
						if newAttrs.length
							newAttrs = ' ' + newAttrs

						"<#{tag}#{newAttrs}>"
				else					''
			).trim()

		colorForUser: (baseUser, coloredUser) ->
			coloredUserId = if typeof coloredUser == 'number' || typeof coloredUser == 'string'
				parseInt coloredUser
			else
				coloredUser.saneId()

			if baseUser.saneId() == coloredUserId
				return '#FFFFFF'

			colors = ['#AC8AB2', '#25BA26', '#C3230C', '#DD49DA', '#6B5825', '#3FC0A4', '#D73A76', '#8987D6', '#EDCD28', '#7D3B83', '#026A5D', '#8A2519', '#4DA7C7', '#B6B12E', '#4F4F77', '#426A2D', '#8BAA39', '#F4A720', '#75AD6F', '#DD625E', '#A15ED9', '#D87D9B', '#6B98D5', '#C8907D', '#DE7C19']
			currentColors = baseUser.get('user_colors')
			if currentColors
				colorPairs = currentColors.split ' '
				for colorPair in colorPairs
					[userId,colorId] = colorPair.split ':'
					if `userId == coloredUserId`
						return colors[colorId]

				if colorPairs.length == colors.length
					return '#000000'
				else
					colorId = colorPairs.length
					baseUser.set 'user_colors', "#{baseUser.get('user_colors')} #{coloredUserId}:#{colorId}"
					return colors[colorId]
			else
				baseUser.set 'user_colors', "#{coloredUserId}:0"
				return colors[0]

		ucfirst: (string) ->
			string.toLowerCase().replace /(\b)(\w)/g, (match, leading, letter) -> "#{leading}#{letter.toUpperCase()}"

		find: (list, predicate) ->
			if _.isPlainObject predicate
				list.find (instance) ->
					for name,value of predicate
						if instance.get(name) != value
							return false
					true
			else
				list.find predicate

		# SUPER HACK
		userWrapper: (userId) ->
			window._userWrappers ?= {}
			if !_userWrappers[userId]
				_userWrappers[userId] = ObjectWrapper.create userId, '@',
					name: 'User ' + userId
			_userWrappers[userId]


		findAll: (list, predicate) ->
			if _.isPlainObject predicate
				list.findAll (instance) ->
					for name,value of predicate
						if instance.get(name) != value
							return false
					true
			else
				list.findAll predicate

		filteredArray: (ctx, subject, output, test, reversed=false) ->
			add = if reversed
				(obj) -> output.unshift obj
			else
				(obj) -> output.push obj
			subject.each (record) =>
				if test record
					add record

			ctx.observeObject subject, (mutation) =>
				if mutation.type == 'insertion'
					if test mutation.value
						add mutation.value
				else if mutation.type == 'deletion'
					if test mutation.value
						output.remove mutation.value

		url: (url, baseUrl=null) ->
			if url
				part = url.match(/^https?:\/\/(.*)$/)?[1]
				if part
					'http://agora.sh/url/' + part
				else if baseUrl && url[0] == '/'
					util.url baseUrl + url
				else
					url

		mapObjects: (array, map) ->
			if array
				_.map array, (el) =>
					newEl = _.clone el
					for p,mapping of map
						if _.isFunction mapping
							newEl[p] = mapping el
						else
							newEl[p] = el[mapping]
					newEl



		shoppingBar:
			pushRootState: (user) ->
				belt = user.get('belts').get(0)
				shoppingBarView.pushState
					state: 'root'
					shareObject: -> "belts.#{belt.saneId()}"
					shared: -> belt.field 'shared'
					isShared: -> belt.get('shared')

					contents: => belt.get('elements')
					contentMap: (el) => elementType:'BeltElement', elementId:el.get('id')
					ripped: (view) ->
						_activity 'remove', belt, util.resolveObject view.element
						view.element.delete()
					dropped: (element) =>
						obj = util.resolveObject element#if element instanceof View then element.obj else element
						_activity 'add', belt, obj
						belt.get('contents').add obj
						# rootEl = agora.modelManager.getModel('RootElement').create user_id:user.get('id'), element_type:obj.modelName, element_id:obj.get 'id'

			pushBeltState: (belt) ->
				shoppingBarView.pushState
					state: 'root'
					shareObject: -> "belts.#{belt.saneId()}"
					shared: -> belt.field 'shared'

					isShared: -> belt.get('shared')

					contents: => belt.get('elements')
					contentMap: (el) => elementType:'BeltElement', elementId:el.get('id')
					ripped: (view) ->
						_activity 'remove', belt, util.resolveObject view.element
						view.element.delete()
					dropped: (element) =>
						obj = util.resolveObject element#if element instanceof View then element.obj else element
						_activity 'add', belt, obj
						belt.get('contents').add obj
						# rootEl = agora.modelManager.getModel('RootElement').create user_id:user.get('id'), element_type:obj.modelName, element_id:obj.get 'id'

			pushDecisionState: (decision) ->
				shoppingBarView.pushState
					# shareObject: "decisions.#{decision.record.globalId().substr 1}"
					shareObject: -> "decisions.#{decision.record.saneId()}"
					shared: -> decision.field 'shared'

					isShared: -> decision.get('shared')


					dropped: (element) =>
						obj = util.resolveObject element
						_activity 'add', decision, obj
						decision.get('list').get('contents').add obj
					ripped: (view) =>
						view.element.delete()
					contents: => decision.get('list').get('elements')
					contentMap: (el) => elementType:'ListElement', elementId:el.get('id'), decisionId:decision.get 'id'
					state: 'Decision'
					args: decisionId: decision.get 'id'

