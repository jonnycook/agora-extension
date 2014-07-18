define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->
	class ListBarItem extends BarItem
		type: 'List'
		init: ->
			@contentsCtx = @ctx.context()

			itemData = @itemData?() ? {}
			itemData.state = @itemView.clientValue()

			updateData = =>
				data = if @obj.get 'collapsed'
					state: 'collapsed'
					contents:@collapsedContents()
				else
					state: 'expanded'
					contents:@expandedContents()

				itemData.state.set data

			updateData()

			@data = 
				type: @type
				barItemData:itemData

			@observe @obj.field('collapsed'), =>
				@contentsCtx.clear()
				updateData()

		dropped: (obj) ->
			util.addElement @obj, obj
			null

		ripped: (view) ->
			view.element.delete()

		expandedContents: ->
			contents = @itemView.clientArrayNamed "#{@obj.modelName}.contents"

			util.syncArrays @contentsCtx, @obj.get('elements'), contents, (element, onRemove, i) =>
				elementType: element.modelName
				elementId: element.get('id')

			contents

		collapsedContents: ->
			getContents = =>
				stack = [list:@obj.get('elements'), pos:0]
				contents = []
				sources = [@obj.get('elements')]

				while stack.length && contents.length < 4 
					state = stack[stack.length - 1]

					if state.list.length() == state.pos
						stack.pop()
						continue

					obj = state.list.get(state.pos++).get('element')

					loop
						if obj.modelName == 'Product'
							contents.push obj.get 'image'
							sources.push obj.field('image')

						else if obj.modelName == 'Decision'
							stack.push list:obj.get('selection'), pos:0
							sources.push obj.get('selection')

						else if obj.modelName == 'Bundle'
							stack.push list:obj.get('elements'), pos:0
							sources.push obj.get('elements')
						break

				ctx = @itemView.context()
				[contents, sources]


			clientContents = @itemView.clientArrayNamed "#{@obj.modelName}.contents"

			reset = =>
				@contentsCtx.clear()
				[contents, sources] = getContents()
				for source in sources
					@contentsCtx.observe source, (mutation) =>
						reset()
				clientContents.setArray contents

			reset()
			clientContents

		methods:
			toggle: (view) ->
				if @obj.get 'collapsed'
					@obj.set 'collapsed', false
				else 
					@obj.set 'collapsed', true

			click: ->
				shoppingBarView.pushState
					dropped: (obj) => util.addElement @obj, obj
					ripped: (view) => view.element.delete()
					contents: => @obj.get('elements')
					contentMap: (el) => elementType:'ListElement', elementId:el.get('id')
