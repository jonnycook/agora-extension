define -> d: ['View', 'util', 'views/ShoppingBarView/ListBarItem'], c: ->
	class SessionBarItem extends ListBarItem
		type: 'Session'
		html: '<div class="title"><span>Session</span> <div class="toggle"></div></div>'

		init: ->
			super
			dialogOpened = false
			@el.children('.title').dblclick =>
				return if dialogOpened
				popupEl = $ "
					<form class='t-dialog renameSession'>
						<h2>Rename session</h2>
						<div class='content'>
							<input type='text' name='title' value='#{@data.title.get()}'>
							<input type='button' class='button cancel' value='cancel'>
							<input type='submit' class='button' value='confirm'>
						</div>
					</form>
				"

				close = ->
					dialogOpened = false
					frame.close()

				popupEl.find('.cancel').click close

				popupEl.submit =>
					@view.callBackgroundMethod 'setTitle', popupEl.get(0).title.value
					close()
					false

				frame = Frame.frameAbove @el.children('.title'), popupEl, type:'balloon', close:-> dialogOpened = false
				frame.el.css marginTop:-8

				popupEl.get(0).title.focus()
				popupEl.get(0).title.select()

				dialogOpened = true

		onData: (@data) ->
			super
			@el.removeClass 't-item'
			@el.find('.title .toggle').click =>
				@callBackgroundMethod 'toggle'
				false

			@view.valueInterface(@el.find '.title span').setDataSource data.title 

			util.tooltip @el.find('.title .toggle'), (=> if @el.hasClass('expanded') then 'collapse session' else 'expand session'), distance:15


		updateLayout: ->
			super
			if @_width < 66
				@el.children('.title').css minWidth:@_width
			else
				@el.children('.title').css minWidth:''
