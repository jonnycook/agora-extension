define -> d: ['View', 'util', 'icons'], c: -> 
	class ShareView extends View
		type: 'Share'
		constructor: ->
			super
			@viewEl '<div class="v-share t-dialog">
				<h2>Invite Collaborators</h2>

				<div class="content">
					<input type="text" class="title" placeholder="Title">
					<textarea class="message" placeholder="Message"></textarea>
					<input type="text" class="add" placeholder="Add">
					<input type="button" value="invite">
				</div>
			</div>'

			submit = =>
				@callBackgroundMethod 'add', [shareTitleEl.val(), @el.find('.message').val(), addEl.val()]
				addEl.val ''
				@el.addClass 'success'
				setTimeout (=> @close?()), 1500
				

			addEl = @el.find('.add')

			@el.find('[type=button]').click submit

			addEl.keyup (e) =>
				if e.keyCode == 13
					submit()

			shareTitleEl = @el.find('.title')
			shareTitleEl.keyup (e) =>
				if e.keyCode == 13
					@callBackgroundMethod 'update', [shareTitleEl.val(), @el.find('.message').val()]
					@close?()


		onData: (data) ->
			@el.find('.title').val data.title
			@el.find('.message').val data.message
			@withData data.entries, (entries) =>
				@el.find('.users').html ''
				for entry in entries
					do (entry) =>
						el = $ "<li><span class='user'>#{entry.with_user_name}</span> <a href='#' class='delete' /></li>"
						@el.find('.users').append el
						el.find('.delete').click =>
							@callBackgroundMethod 'delete', [entry.id]
							false
