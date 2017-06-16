define -> d: ['View', 'util'
	'views/ProductPopupView'
	'views/ShoppingBarView/ListBarItem', 'views/ShoppingBarView/SessionBarItem', 'views/ShoppingBarView/DecisionBarItem', 'views/ShoppingBarView/BundleBarItem', 'views/ShoppingBarView/ProductBarItem', 'views/ShoppingBarView/CompositeSlotBarItem', 'views/ShoppingBarView/CompositeBarItem', 'views/ShoppingBarView/PlaceholderBarItem', 'views/ShoppingBarView/SharedBeltBarItem', 'views/ShoppingBarView/BeltBarItem', 'views/ShoppingBarView/UnauthorizedBarItem'], c: ->
	class BarItemView extends View
		type: 'ShoppingBarView/BarItem'
		constructor: (contentScript, @shoppingBarView, @opts={}) ->
			super
			@el = @viewEl '<div class="element t-item barItem"></div>'
				

			popupView = null
			@selectMode = @opts.selectMode

		childrenCount: -> 
			@barItem?.childrenCount?()

		width: -> @barItem?.width?() ? 48

		updateLayout: ->
			@barItem?.updateLayout?()

		processChild: (view) ->
			@barItem?.processChild? view.barItem
			@parent.processChild? view

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

			@el
				.mouseenter(=>
					(@shoppingBarView.mouseEnteredBarItemView @ if util.isMutable @el) unless @selectMode
				)
				.mouseleave(=>
					(@shoppingBarView.mouseLeftBarItemView @ if util.isMutable @el) unless @selectMode
				)

			@view = @createView()

			if data
				if data.type
					@elementType = data.type

				else
					@elementType = 'Placeholder'

				if !__classes["#{@elementType}BarItem"]
					throw "bar item close not present #{@elementType}"

				@barItem = new __classes["#{@elementType}BarItem"] @, @opts.barItemArgs
				@barItem.init data
				@parent?.processChild? @

				if data.selected
					@el.append '<input type="checkbox" class="chosen">'
					@el.find('.chosen')
						.prop('checked', data.selected.get())
						.click (e) =>
							tracking.event 'ShoppingBar', 'toggleChosen'
							e.stopPropagation()
							@callBackgroundMethod 'setSelected', [@el.find('.chosen').prop('checked')]

					@view.observeObject data.selected, => 
						@el.find('.chosen').prop 'checked', data.selected.get()


				if data.creator
					el = $('<span class="userIndicator" />').css 'background-color', data.creator.color
					util.tooltip el, -> data.creator.name.get()
					@el.append el

				@changedType?()

			@enableSelection true if @selectMode

		represent: ->
			super
			unless @loadNotify
				@shoppingBarView.loadBarItem @
				@loadNotify = true

		destruct: ->
			unless @noDestruct
				@barItem?.destruct() # TODO: In browser extension, @barItem is undefined when entering a Decision item with no element selected. Figure out why
				@parent.destructChild? @
				super

		onData: (@data) ->
			@update @data.get()
			@data.observe =>
				@update @data.get()
			@shoppingBarView.barItemLoaded @

		path: ->
			@shoppingBarView.path()