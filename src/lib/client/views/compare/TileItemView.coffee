define -> d: ['View', 'util'
'views/compare/ProductTileItem'
'views/compare/BundleTileItem'
'views/compare/DecisionTileItem'
'views/compare/UnauthorizedTileItem'
], c: ->
	class TileItemView extends View
		type: 'compare/TileItem'
		constructor: (contentScript, @compareView, @opts={}) ->
			super
			@el = @viewEl '<div class="tileItem"></div>'
			@selectMode = @opts.selectMode

		# childrenCount: -> 
		# 	@barItem?.childrenCount?()

		# width: ->
		# 	@barItem?.width?()

		updateLayout: ->
			@compareView.updateLayout()
			# @barItem?.updateLayout? params, state

		# processChild: (view) ->
		# 	@barItem?.processChild? view.barItem
		# 	@parent.processChild? view

		# childWidthChanged: ->
		# 	@barItem.childWidthChanged.apply @barItem, arguments if @barItem && @barItem.childWidthChanged

		childWidthChanged: (view) ->
			@updateLayout()
			@parent.childWidthChanged? @

		enableSelection: (force=false) ->
			unless @selectMode && !force
				@selectMode = true
				@el.addClass 'selectMode'
				@el.append $('<input type="checkbox" class="select">').click (e) =>
					e.stopPropagation()
					@selected = !@selected
					true

		disableSelection: ->
			if @selectMode
				delete @selectMode
				delete @selected
				@el.find('.select').remove()
				@el.removeClass 'selectMode'

		update: (data) ->
			if @barItem
				@clearViews()
				# @view.destruct()
				@barItem.destruct()
				@parent.destructChild? @

			# @el
			# 	.mouseenter(=>
			# 		(@shoppingBarView.mouseEnteredBarItemView @ if util.isMutable @el) unless @selectMode
			# 	)
			# 	.mouseleave(=>
			# 		(@shoppingBarView.mouseLeftBarItemView @ if util.isMutable @el) unless @selectMode
			# 	)

			@view = @createView()

			if data
				if data.type
					@elementType = data.type
				else
					@elementType = 'Placeholder'


				if !__classes["#{@elementType}TileItem"]
					throw new Error "No class #{@elementType}TileItem"

				@barItem = new __classes["#{@elementType}TileItem"] @, @opts.barItemArgs
				@barItem.init data, @opts.barItemArgs

				if data.creator
					el = $('<span class="userIndicator" />').css 'background-color', data.creator.color
					util.tooltip el, -> data.creator.name.get()
					@el.append el


				if data.selected
					@el.append '<div class="actions"><a href="#" class="dismiss" /><input type="checkbox" class="chosen"></div>'
					@el.find('.chosen')
						.prop('checked', data.selected.get())
						.click (e) =>
							e.stopPropagation()
							tracking.event 'Compare', 'toggleChosen'
							@callBackgroundMethod 'setSelected', [@el.find('.chosen').prop('checked')]

					@observeObject data.selected, =>
						@el.find('.chosen').prop 'checked', data.selected.get()
					util.tooltip @el.find('.chosen'), 'choose'

					@el.find('.dismiss').click =>
						tracking.event 'Compare', 'dismiss'
						@callBackgroundMethod 'dismiss'
						false
					util.tooltip @el.find('.dismiss'), 'dismiss'
					@barItem.initActions?()

				# if data.selected
				# 	@el.append '<input type="checkbox" class="chosen">'
				# 	@el.find('.chosen')
				# 		.prop('checked', data.selected.get())
				# 		.click (e) =>
				# 			e.stopPropagation()
				# 			@callBackgroundMethod 'setSelected', [@el.find('.chosen').prop('checked')]

				# 	@view.observeObject data.selected, => 
				# 		@el.find('.chosen').prop 'checked', data.selected.get()

				# @changedType?()

			@enableSelection true if @selectMode

		represent: ->
			super
			unless @loadNotify
				@compareView.loadBarItem @
				@loadNotify = true

		destruct: ->
			unless @noDestruct
				@barItem?.destruct() # TODO: In browser extension, @barItem is undefined when entering a Decision item with no element selected. Figure out why
				@parent.destructChild? @
				super

		onData: (@data) ->
			@update data.get()
			data.observe =>
				@update data.get()

			@compareView.barItemLoaded @


		path: ->
			@compareView.path()