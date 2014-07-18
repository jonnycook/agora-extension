define -> d: ['View', 'Frame'], c: ->
	class ProductAddedView extends View
		type: 'ProductAdded'
		constructor: (@contentScript) ->
			super @contentScript
			@el = $ '
				<div class="-agora v-productAdded">
					<span class="p-picture"></span>
					<div class="g-info">
						<span class="p-title t-field" data-name="title">
							<span class="display">Legend of Zelda: A Link to the Past</span>
							<span class="edit-w"><span class="w"><input type="text" class="edit"></span></span>
						</span>
						<span class="p-site">Amazon</span>
						<span class="p-price t-field" data-name="price">
							<span class="display"></span>
							<span class="edit-w"><span class="w"><input type="text" class="edit"></span></span>
						</span>
					</div>
					<span class="v-button small n-close">Done</span>		
				</div>'
				
			@el.find('.n-remove').click =>
				@callBackgroundMethod 'remove', null, (returnVal) ->
					console.log returnVal


			@editingCount = 0
			@isEditing = {}

			@el.mouseenter =>
				@mouseOver = true
				@updateInUse()

			@el.mouseleave =>
				@mouseOver = false
				@updateInUse()

		updateInUse: ->
			if @mouseOver || @editingCount
				if !@inUse
					@inUse = true
					@onStartedUsing?()
			else 
				if @inUse
					@inUse = false
					@onStoppedUsing?()

		onData: (data) ->
			title = @el.find '.p-title'
			site = @el.find '.p-site'
			image = @el.find '.p-picture'
			price = @el.find '.p-price'

			fields = 
				price:
					display: 'displayPrice'
		
			updateField = (field, edit) ->
				name = field.attr('data-name')

				if display = fields[name]?.display
					field.find('.display').html data[display].get()
					field.find('.edit').val data[name].get() if edit
				else
					if data[name].get()
						field.find('.display').html data[name].get()
						field.find('.edit').val data[name].get() if edit

			enableEditModeForField = {}

			@el.find('.t-field').each (i, el) =>
				field = $ el
				name = field.attr 'data-name'
				updateField field, true
				edit = field.find('.edit')

				enabledEditMode = (startEditing = true) => 
					field.addClass 's-editing'
					setTimeout (->
						edit.get(0).select()
						edit.get(0).focus()
					), 0

					if !@isEditing[name] && startEditing
						@isEditing[name] = true
						++@editingCount
						@updateInUse()

				enableEditModeForField[name] = enabledEditMode

				editModeEnabled = -> field.hasClass 's-editing'

				closeEdit = =>
					if @isEditing[name]
						delete @isEditing[name]
						--@editingCount
						@updateInUse()

					field.removeClass('s-editing')
					edit.get(0).blur()

				if data[name].get() == '' || name == 'price'
					enabledEditMode false

				#enter edit mode
				field.find('.display').dblclick enabledEditMode
					

				#observing
				if display = fields[name]?.display
					@observe data[display], (mutation) -> 
						updateField field, !editModeEnabled()

				@observe data[name], (mutation) -> 
					updateField field, !editModeEnabled()

				#editing
				save = => 
					d = {}
					d[name] = edit.val()
					@callBackgroundMethod 'set', [d]
					closeEdit()


				# edit.blur save

				edit.keydown (e) =>
					switch e.which
						when 9
							fields = @el.find('.t-field')
							i = $.inArray field.get(0), fields
							nextField = $ fields.get (i + 1) % fields.length
							save()
							enableEditModeForField[nextField.attr 'data-name']()
							return false
							
						when 13
							save()
							return false
						when 27
							closeEdit()
							updateField field, true
							return false
					
					unless @isEditing[name]
						++@editingCount
						@isEditing[name] = true
						@updateInUse()



			site.html data.site.name
			
			image.css backgroundImage:"url('#{data.image.get()}')" if data.image.get()
			@observe data.image, (mutation) -> image.css backgroundImage:"url('#{mutation.value}')"

			@el.find('.n-close').click => @onClose()