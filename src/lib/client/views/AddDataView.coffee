define -> d: ['View', 'util', 'icons'], c: -> 
	class AddDataView extends View
		type: 'AddData'
		constructor: (contentScript, opts) ->
			super
			viewType = opts.type
			if viewType == 'drag'
				@el = @viewEl '<div class="v-addData t-dialog">
					<h2>Clip</h2>
					<div class="content">
						<form>
							<div class="field">
								<select name="type">
									<option>Content Type</option>
									<option value="image">Image</option>
									<option value="video">Video</option>
									<option value="url">Page</option>
									<option value="plainText">Text</option>
									<option value="richText">Rich Text</option>
								</select>
							</div>
							<div class="field"><input type="text" name="title" placeholder="Title"></div>
							<div class="field"><input type="text" name="url" placeholder="URL"></div>
							<div class="field"><input type="text" name="text" placeholder="Text"></div>
							<div class="field"><input type="text" name="comment" placeholder="Comment"></div>
						</form>

						<span class="t-item -agora-addData-link" />
					</div>
				</div>'
			else if viewType == 'connected'
				@el = @viewEl '<div class="v-addData t-dialog">
					<div class="content">
						<form>
							<div class="field">
								<select name="type">
									<option>Content Type</option>
									<option value="image">Image</option>
									<option value="video">Video</option>
									<option value="url">Page</option>
									<option value="plainText">Text</option>
									<option value="richText">Rich Text</option>
								</select>
							</div>
							<div class="field"><input type="text" name="title" placeholder="Title"></div>
							<div class="field"><input type="text" name="url" placeholder="URL"></div>
							<div class="field"><input type="text" name="text" placeholder="Text"></div>
							<div class="field"><input type="text" name="comment" placeholder="Comment"></div>
							<input type="submit">
						</form>
					</div>
				</div>'

			@el.addClass viewType

			setType = (type) =>
				@el.find("select[name=type] option[value=#{type}]").prop 'selected', true
				@el.find('[name=type]').trigger 'change'

			@values = {}
			@set = (prop, value) =>
				@values[prop] = value
				if prop == 'type'
					setType value
				else
					@el.find("input[name=#{prop}]").val value


			@set 'title', opts.title if opts.title


			type = null

			if opts.url.match /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
				@set 'url', opts.url
			else
				type = 'plainText'
				@set 'text', opts.url

			if viewType == 'drag'
				rangy.init() unless rangy.initialized
				selection = rangy.getSelection()
				selectionText = selection.toString()

				if selectionText != ''
					type = 'plainText'
					@set 'text', selectionText

			if !type
				if opts.url.match /(^https?:\/\/www\.youtube.com\/watch|^http:\/\/vimeo.com\/\d+)/
					type = 'video'


			args = object:opts.args

			@set 'type', type if type
			
			args.url = opts.url
			@represent args

			if viewType == 'drag'
				linkEl = @el.find('.-agora-addData-link')
				formEl = @el.find('form').get 0
				util.tooltip linkEl, 'drag to a product', position:'below'
				util.initDragging linkEl,
					context: 'page'
					action: 'addData'
					breaksImmutability:true
					data: (cb) ->
						cb
							action:'addData'
							data:
								type:formEl.type.value
								title:formEl.title.value
								url:formEl.url.value
								text:formEl.text.value
								comment:formEl.comment.value

					helper: (e, el) -> el.clone().addClass '-agora dragging'
					onDraggedOver: (activeEl, helperEl) ->
						if activeEl
							helperEl.addClass 'adding'
						else 
							helperEl.removeClass 'adding'

					start: =>
						linkEl.css opacity:.5
					stop: (event, ui) =>
						linkEl.animate opacity:1
						ui.helper.detach()
						@close()

			else if viewType == 'connected'
				@el.find('form').submit =>
					@submit()
					false

			util.styleSelect @el.find('[name=type]'), autoSize:false

		submit: ->
			formEl = @el.find('form').get 0

			@callBackgroundMethod 'add', 
				type:formEl.type.value
				title:formEl.title.value
				url:formEl.url.value
				text:formEl.text.value
				comment:formEl.comment.value
			@close()

			@onSubmit?()


		onData: (data) ->
			if data.title && !@values.title
				@set 'title', data.title
			if data.type && !@values.type
				@set 'type', data.type
