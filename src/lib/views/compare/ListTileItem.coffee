define ['View', 'Site', 'Formatter', 'util', 'underscore', './TileItem'], (View, Site, Formatter, util, _, TileItem) ->
	class ListTileItem extends TileItem
		type: 'List'
		init: ->
			@contentsCtx = @ctx.context()

			barItemData = @barItemData?() ? {}
			barItemData.state = @view.clientValue()

			updateData = =>
				data = if @obj.get 'collapsed'
					state: 'collapsed'
					contents:@collapsedContents()
				else
					state: 'expanded'
					contents:@expandedContents()

				barItemData.state.set data

			updateData()

			@data = 
				type: @type
				barItemData:barItemData

			@observe @obj.field('collapsed'), =>
				@contentsCtx.clear()
				updateData()

		dropped: (obj) ->
			util.addElement @obj, obj
			null

		ripped: (view) ->
			view.element.delete()

		expandedContents: ->
			contents = @view.clientArrayNamed "#{@obj.modelName}.contents"

			util.syncArrays @contentsCtx, @obj.get('elements'), contents, (element, onRemove, i) =>
				elementType: element.modelName
				elementId: element.get('id')
				compareViewId: @view.compareView.id

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

				ctx = @view.context()
				[contents, sources]


			clientContents = @view.clientArrayNamed "#{@obj.modelName}.contents"

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
