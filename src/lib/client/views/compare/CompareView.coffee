define -> d: ['View', 'util', 'views/compare/TileItemView', 'views/ProductPreviewView', 'views/EditDescriptorView'], c: ->
	class CompareView extends View
		type: 'compare/Compare'
		constructor: (contentScript, @contEl, @backEl, @public=false) ->
			super
			@el = @viewEl '
				<div class="-agora v-compareTile">
					<h2 class="title" />
					<ul class="breadcrumbs" />

					<div class="client" />
				</div>'

			if contEl
				@setContEl contEl


			if @public
				@el.addClass 'public'

			@clientEl = @el.find('.client')
			@titleEl = @el.find('.title')

			# @layout = 'tiles'
			# @layout = 'columns'
			@layout = 'masonry'

			$(window).keyup @keyListener = (e) =>
				if e.keyCode == 27
					pathLength = @el.find('.breadcrumbs li').length
					if pathLength == 1
						@close?()
					else
						@callBackgroundMethod 'gotoPath', pathLength - 2

		items: -> @el.find('.items > .tileItem')

		setContEl: (@contEl) ->
			contEl.resize => @updateLayout()
			@contEl.append @menuEl = $ '
				<div class="agoraMenu">
					<div class="group">
						<div class="item agora"><a href="http://agora.sh" target="_blank" /></div>
						<!--<div class="item home"><a href="#" /></div>-->
					</div>
					<div class="group">
						<div class="item selectionMode">
							<a href="#" />
							<div class="submenu">
								<a href="#" class="wrap"><label>wrap</label></a>
								<a href="#" class="extract"><label>extract</label></a>
								<a href="#" class="split"><label>split</label></a>
								<a href="#" class="delete"><label>delete</label></a>
								<a href="#" class="bundle"><label>bundle</label></a>
							</div>
						</div>
						<div class="item settings">
							<a href="#" />
							<div class="submenu">
								<div class="properties" />
							</div>
						</div>
						<div class="item share">
							<a href="#" />
						</div>
					</div>
				</div>
			'
			if @public
				@menuEl.addClass 'public'

			@menuEl.find('.selectionMode .submenu').hide()
			@menuEl.find('.selectionMode').click =>
				if @selectMode
					@event 'select'
					@disableSelection()
				else
					@event 'cancelSelect'
					@enableSelection()
				false


			@menuEl.find('.share a').click =>
				util.presentViewAsModalDialog 'SocialShare', {viewId:@id}, waitUntilRepresented:true
				false

			@menuEl.find('.selectionMode .wrap').click =>
				@wrapSelection 'decision'
				false

			@menuEl.find('.selectionMode .extract').click =>
				@extractSelection()
				false

			@menuEl.find('.selectionMode .split').click =>
				@splitSelection()
				false

			@menuEl.find('.selectionMode .delete').click =>
				@deleteSelection()
				false

			@menuEl.find('.selectionMode .bundle').click =>
				@wrapSelection 'bundle'
				false

			@menuEl.find('.settings').click => false
			util.popoutTrigger @menuEl.find('.settings'),
				side: 'right'
				anchor: 'top'
				el: @menuEl.find('.settings .submenu')

		eachSelectable: (cb) ->
			@el.find('.items').children('.tileItem').each ->
				cb $(@).data 'view'

		enableSelection: ->
			unless @selectMode
				@eachSelectable (view) -> view.enableSelection()

				@menuEl.find('.selectionMode').addClass 'enabled'

				@selectionMenuFuncs = util.createPopout @menuEl.find('.selectionMode'),
					side:'right'
					anchor:'middle'
					el: @menuEl.find('.selectionMode .submenu')
					flexibleHeight: false
				@selectMode = true

		disableSelection: ->
			if @selectMode
				# @unpinMenu()
				@menuEl.find('.selectionMode').removeClass 'enabled'

				@eachSelectable (view) -> view.disableSelection()
				@selectMode = false
				@selectionMenuFuncs.close()

				# @updateMenu()

		selected: ->
			selected = []
			@eachSelectable (view) -> selected.push(view.id) if view.selected
			selected

		wrapSelection: (type) ->
			@event 'wrap'
			@callBackgroundMethod 'wrap', [type, @selected()]
			@disableSelection()

		deleteSelection: ->
			@event 'delete'
			@callBackgroundMethod 'delete', [@selected()]
			@disableSelection()

		extractSelection: ->
			@event 'extract'
			@callBackgroundMethod 'extract', [@selected()]
			@disableSelection()

		splitSelection: ->
			@event 'split'
			@callBackgroundMethod 'split', [@selected()]
			@disableSelection()

		updateLayout: ->
			if @state == 'Decision'
				return if @barItemLoadCount

				margin = parseInt @clientEl.children('.items').children('.tileItem:first').css('marginBottom')
				size = @clientEl.children('.items').children('.tileItem:first').outerWidth()

				if @public || !@showingDismissalList
					if @subDecision
						padding = 170
					else
						padding = 100
				else
					padding = (106+60)*2

				contWidth = (Math.floor((@contEl.width() - padding)/(size+margin)) * (size+margin)) - margin


				@clientEl.css width:contWidth
				@el.width contWidth
				@el.height ''
				@clientEl.children('.items').css width:contWidth

				@clientEl.find('.dismissalList').css
					top:@clientEl.offset().top - (@clientEl.find('.items').offset().top)
					marginTop:-65

				switch @layout
					when 'tiles'
						rowHeight = size

						params = margin:margin, contWidth:contWidth, rowHeight:rowHeight

						state =
							x: 0
							y: 0
							cols: 0
							rows: 1
							maxWidth: 0

						@items().each ->
							itemEl = $ @
							itemEl.data('view').barItem.updateTilesLayout params, state

						height = state.rows*rowHeight + (state.rows-1)*margin
						@clientEl.children('.items').css
							height:state.rows*rowHeight + (state.rows-1)*margin

						@clientEl.css height:height

					when 'masonry'
						@items().each ->
							itemEl = $ @
							if itemEl.data('view').barItem
								itemEl.data('view').barItem.updateMasonryLayout()

						@clientEl.children('.items').masonry('reloadItems').masonry columnWidth:size, itemSelector:'.rootItem', gutter:margin
						@clientEl.css height:@clientEl.children('.items').height() - margin

			else if @state == 'Product'
				contWidth = $(window).width() - 220#(Math.floor((@contEl.width() - (106+60)*2)/(size+margin)) * (size+margin)) - margin

				@clientEl.css width:contWidth
				@el.width contWidth

				# @clientEl.outerHeight 0
				@el.height $(window).height() - 100#@contEl.innerHeight() - (@el.offset().top - @contEl.offset().top)
				@clientEl.outerHeight @el.height() - (@clientEl.offset().top - @el.offset().top) - 40

		childWidthChanged: (view) ->
			@updateLayout()

		barItemLoadCount: 0
		loadBarItem: (barItem) ->
			++@barItemLoadCount
		barItemLoaded: (barItem) ->
			--@barItemLoadCount
			if !@barItemLoadCount
				@updateLayout()
				@el.animate opacity:1, 100


		initBreadcrumbs: (breadcrumbs) ->
			breadcrumbsEl = @el.children('.breadcrumbs')
			breadcrumbsEl.html ''
			for breadcrumb in breadcrumbs
				do (breadcrumb) =>
					breadcrumbEl = $('<li><span class="images" /></li>').appendTo breadcrumbsEl
					breadcrumbEl.click (=>
						@callBackgroundMethod 'gotoPath', breadcrumbEl.index()
					)

					if View.isClientArray breadcrumb
						breadcrumbEl.find('.images').append  $ '<span class="image" />'
						util.initMosaic @, breadcrumbEl, '.image', breadcrumb

						# contents = @listInterface breadcrumbEl, '.image', (el, data, pos, onRemove) =>
						# 	el.css 'background-image', "url(#{data})"
						# contents.setDataSource breadcrumb

						# prevLength = contents.length()
						# classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
						# updateForLength = =>
						# 	breadcrumbEl.removeClass classesForLength[prevLength]
						# 	breadcrumbEl.addClass classesForLength[prevLength = contents.length()]

						# contents.onLengthChanged = updateForLength
						# updateForLength()

					else if View.isClientValue breadcrumb
						breadcrumbEl.find('.images').css backgroundImage:"url('#{breadcrumb.get()}')"

		configure: (data) ->
			if @clientView
				@clientView.clear()
			else
				@clientView = @view()
			@clientEl.html ''
			@titleEl.html ''

			@el.removeClass @state if @state

			if @state == 'Decision'
				util.terminateDragging @contEl

			@state = data.state

			@el.addClass @state

			@backEl.removeClass 'v-compareTile-background'
			@clientEl.removeClass 'frame'
			@el.children('.breadcrumbs').hide()

			@initBreadcrumbs data.breadcrumbs

			if data.breadcrumbs.length > 1
				@backEl.addClass 'v-compareTile-background'
				@clientEl.addClass 'frame'
				@el.children('.breadcrumbs').show()
				lastBreadcrumbEl = @el.children('.breadcrumbs').children('li:last')
				arrowEl = $('<span class="-arrow" />').appendTo(@clientEl)
				arrowEl.css
					position: 'absolute'
					top:-42
					left:lastBreadcrumbEl.offset().left - @el.offset().left + lastBreadcrumbEl.width()/2 - arrowEl.width()/2

				_tutorial 'Workspace/ReturnToParent', @el.children('.breadcrumbs').children('li:first')

			if data.state == 'Decision'
				if data.breadcrumbs.length > 1
					@subDecision = true
				else
					@subDecision = false
				@clientEl.append '
					<div class="properties" />
					<div class="items">
						<div class="tileItem" />
					</div>

					<div class="dismissalList">
						<a href="#" class="clear" />
						<ul>
							<li>
								<a href="#" class="restore" />
								<a href="#" class="remove" />
							</li>
						</ul>
					</div>'
				@clientEl.find('.items').data 'view', @

				if !@public
					util.initDragging @clientEl.find('.items'),
						enabled:false
						root:true
						rootZIndex:0
						acceptsDrop:true
						# onRippedOut: =>
						# 	# @updateLayout()
						# onReorder: (el, startIndex, endIndex) =>
						# 	@callBackgroundMethod 'reorder', [startIndex, endIndex]
						# # onRemove: (el) =>
						# # 	@callBackgroundMethod 'remove', [{view:el.data('view').id}, {view:@id}]
						onDroppedOn: (el, fromEl) =>
							@onDroppedOn el, fromEl, @el.find('.items')
							el.remove();
							false

					util.initDragging @contEl,
						enabled:false
						root:true
						rootZIndex:-1
						acceptsDrop:true
						onDroppedOn: (el, fromEl) =>
							@onDroppedOn el, fromEl, @el.find('.items')
							el.remove();
							false

				@clientEl.children('.items').addClass @layout

				contents = @clientView.listInterface @el, '.items > .tileItem', (el, data, pos, onRemove) =>
					tileItemView = @clientView.createView 'TileItemView', @, selectMode:@selectMode
					tileItemView.represent data
					tileItemView

					onRemove -> tileItemView.destruct()
					tileItemView.el.addClass 'rootItem'
					tileItemView.el

				contents.onDelete = (el, del) =>
					del()
					@updateLayout()

				contents.onInsert = (el) =>
					@updateLayout()

				contents.onMove = => @updateLayout()

				@el.find('.dismissalList').hide()

				@el.find('.dismissalList .clear').click =>
					@callBackgroundMethod 'clearDismissalList'
					false

				util.tooltip @el.find('.dismissalList .clear'), 'clear', position:'below'

				@el.css opacity:0

				@barItemLoadCount = 0

				if data.contents
					contents.setDataSource data.contents
					if @barItemLoadCount == 0
						@updateLayout()
						@el.css opacity:''

				if data.dismissalList
					dismissalListIface = @clientView.listInterface @el.find('.dismissalList ul'), 'li', (el, data, pos, onRemove) =>
						view = @clientView.createView()
						onRemove -> view.destruct()

						if typeof data == 'string'
							el.css 'background-image', "url('#{data}')"
						else
							el.append  $ '<span class="image" />'
							# contents = view.listInterface el, '.image', (el, data, pos, onRemove) =>
							# 	el.css 'background-image', "url(#{data})"
							# contents.setDataSource data

							# prevLength = contents.length()
							# classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
							# updateForLength = =>
							# 	el.removeClass classesForLength[prevLength]
							# 	el.addClass classesForLength[prevLength = contents.length()]

							# contents.onLengthChanged = updateForLength
							# updateForLength()
							util.initMosaic view, el, '.image', data

						el.find('.restore').click =>
							@event 'restore'
							@callBackgroundMethod 'restore', [el.index()]
							false
						el.find('.remove').click =>
							@event 'removeDismissed'
							@callBackgroundMethod 'removeDismissed', [el.index()]
							false
						util.tooltip el.find('.remove'), 'remove'
						el
					dismissalListIface.setDataSource data.dismissalList

					updateForLengthChanged = =>
						if dismissalListIface.length()
							@showingDismissalList = true
							@el.find('.dismissalList').show()
						else
							@showingDismissalList = false
							@el.find('.dismissalList').hide()

						@updateLayout()

					dismissalListIface.onLengthChanged = updateForLengthChanged
					updateForLengthChanged()


				@titleEl.html '<span class="icon" /><span class="descriptor" /><a href="#" class="edit" />'

				opened = false
				@titleEl.find('.edit').click =>
					if !opened
						opened = true
						editDescriptorView = new EditDescriptorView @contentScript
						editDescriptorView.close = -> frame.close()
						editDescriptorView.represent data.args.decisionId
						frame = Frame.frameAround @titleEl.find('.edit'), editDescriptorView.el, type:'balloon', distance:15, close: -> frame.close(); opened = false
						tracking.page "#{@path()}/#{editDescriptorView.pathElement()}"
						@event 'editDescriptor'

					# editDescriptorView
					false
				util.tooltip @titleEl.find('.edit'), 'edit', position:'below'

				if data.descriptor
					@clientView.valueInterface(@titleEl.find('.descriptor')).setDataSource data.descriptor

				updateIcon = =>
					icons.setIcon @titleEl.find('.icon'), data.icon.get() ? 'list', size:'small', color:'white'
					@titleEl.find('.icon').removeClass 't-item'
				data.icon.observe updateIcon
				updateIcon()

				updateProperties = =>
					propertiesEl = @menuEl.find('.settings .properties')
					propertiesEl.html ''
					if data.properties.get()
						for prop in data.properties.get()
							do (prop) =>
								if 'count' of prop
									propertiesEl.append propEl = $ "<div class='property'><input type='checkbox' class='selected'> <label>#{prop.label}&nbsp;(#{prop.count})</label></div>"
									if prop.count == 0
										propEl.addClass 'none'
								else
									propertiesEl.append propEl = $ "<div class='property'><input type='checkbox' class='selected'> <label>#{prop.label}</label></div>"

								propEl.find('.selected')
									.change =>
										@event 'toggleProperty'
										@callBackgroundMethod 'setProperty', [prop.path, propEl.find('.selected').prop 'checked']
									.prop 'checked', prop.selected.get()

								propEl.click =>
									propEl.find('.selected').prop 'checked', !propEl.find('.selected').prop 'checked'
									propEl.find('.selected').triggerHandler 'change'


				updateProperties()
				data.properties.observe updateProperties
			
			else if data.state == 'Product'
				productPreviewView = @clientView.createView 'ProductPreviewView', public:@public
				productPreviewView.represent data.productId, =>
					productPreviewView.el.children('.head').appendTo @titleEl

				# productPreviewView.el.find('.productSidebar').removeClass 'white'
				productPreviewView.el.appendTo @clientEl
				tracking.page "#{@path()}/#{productPreviewView.pathElement()}"

			@updateLayout()

		onDroppedOn: (el, fromEl, toEl, dropAction) ->
			util.resolveDraggingData el, (data) =>
				if fromEl
					@event 'move'
					@callBackgroundMethod 'move', [data, {view:toEl.data('view').id}, dropAction]
				else
					@event 'drop'
					@callBackgroundMethod 'drop', [data, {view:toEl.data('view').id}, dropAction]


		destruct: ->
			super
			$(window).unbind 'keyup', @keyListener

		onData: (data) ->
			@configure data.get()
			data.observe => 
				@configure data.get()

			_tutorial 'Workspace'