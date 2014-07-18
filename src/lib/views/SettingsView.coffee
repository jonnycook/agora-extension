define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class SettingsView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@background.getStorage ['options'], (data) =>
				@data = 
					hideBelt:data.options?.hideBelt ? false
					autoFeelings:data.options?.autoFeelings ? false
					showPreview:data.options?.showPreview ? false

				done()


		# init: (args, done) ->
		# 	@resolveObject args, (obj) =>
		# 		@data = @ctx.clientArray obj.get('data'), (datum, onRemove) =>
		# 			ctx = @context()
		# 			onRemove -> ctx.destruct()
		# 			id:datum.get 'id'
		# 			type:ctx.clientValue datum.field 'type'
		# 			url:ctx.clientValue datum.field 'url'
		# 			title:ctx.clientValue datum.field 'title'
		# 			text:ctx.clientValue datum.field 'text'
		# 			comment:ctx.clientValue datum.field 'comment'
		# 		done()


		@client: ->
			class SettingsView extends View
				type: 'Settings'
				booleanSettings: ['hideBelt', 'autoFeelings', 'showPreview']
				init: ->
					@viewEl '<div class="v-settings t-dialog">
						<h2>Settings</h2>
						<div class="content">
							<form>
								<div class="field"><input type="checkbox" name="hideBelt"> <label>Hide Belt</label></div>
								<div class="field"><input type="checkbox" name="autoFeelings"> <label>Auto Feelings</label></div>
								<div class="field"><input type="checkbox" name="showPreview"> <label>Show Preview</label></div>
								<!--<input type="Submit">-->
							</form>
						</div>
					</div>'


					for name in @booleanSettings
						do (name) =>
							@el.find("[name=#{name}]").change =>
								@callBackgroundMethod 'update', [name, @el.find("[name=#{name}]").prop 'checked']

				onData: (data) ->
					for name in @booleanSettings
						if data[name]
							@el.find("[name=#{name}]").prop 'checked', true


				# @el.submit =>
				# 	@callBackgroundMethod 'submit', [@el.find('[name="subject"]').val(), @el.find('[name="message"]').val()]
				# 	@el.addClass 'sent'
				# 	setTimeout (=> @close()), 1500
				# 	false

				# setTimeout (=>@el.find('[name="subject"]').get(0).focus()), 10


		methods:
			submit: (view, subject, message) ->
				@agora.background.httpRequest "#{@agora.background.apiRoot}contact.php", 
					method: 'post'
					data:
						subject:subject
						message:message

			update: (view, prop, value) ->
				options = {}
				options[prop] = value
				@agora.setOptions options
