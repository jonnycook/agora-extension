define -> d: ['View', 'util', 'icons', 'Frame2', 'views/DecisionPreviewView'], c: -> 
	class CollaborateView extends View
		type: 'Collaborate'
		constructor: ->
			super
			@viewEl '<div class="v-collaborate collaborators">
				<div class="tabs">
					<div class="tab collaborators">Collaborators</div>
					<div class="tab activity">Activity</div>
				</div>

				<div class="content">
					<div class="collaborators">
						<ul class="collaborators">
							<li class="collaborator">
								<span class="abbreviation" />
								<span class="name" />
								<a href="#" class="delete" />
							</li>
						</ul>
						<a href="#" class="invite">Invite Collaborators</a>
					</div>
					<div class="activity">
						<ul class="activity">
							<li class="entry">
								<span class="type" />
								<span class="imagePreview" />
								<span class="text" />
								<span class="timestamp" />
							</li>
						</ul>
					</div>
				</div>
			</div>'

			@el.find('.tabs .collaborators').click =>
				@el.removeClass 'activity'
				@el.addClass 'collaborators'
				# @sizeChanged?()


			@el.find('.tabs .activity').click =>
				@el.addClass 'activity'
				@el.removeClass 'collaborators'
				# @sizeChanged?()

			util.trapScrolling @el.find('ul.activity')

			@el.find('.invite').click =>
				util.showDialog => 
					view = new ShareView @contentScript
					view.represent @args
					view
				false


		onDisplay: ->
		onClose: ->

		configure: (data) ->
			if @stateView
				@stateView.destruct()

			@stateView = @createView()

			if data.owner
				@el.addClass 'owner'
			else
				@el.removeClass 'owner'

			@el.find('ul.collaborators').html '
				<li class="collaborator">
					<span class="abbreviation" />
					<span class="name" />
					<a href="#" class="delete" />
				</li>'

			@stateView.listInterface(@el.find('ul.collaborators'), '.collaborator', (el, data, pos, onRemove) =>
				view = @stateView.createView()
				onRemove -> view.destruct()

				if data.pending
					el.addClass 'pending'
					el.find('.abbreviation').html '...'
					el.find('.name').html data.name + ' (pending)'
					el.find('.delete').click =>
						@callBackgroundMethod 'deletePending', [data.id]
						false

				else				
					view.withData data.abbreviation, (abbreviation) ->
						el.find('.abbreviation').html abbreviation

					if data.color == '#FFFFFF'
						el.find('.abbreviation').addClass 'white'

					el.find('.abbreviation').css backgroundColor:data.color

					view.withData data.name, (name) ->
						if data.owner
							name += ' (owner)'
						el.find('.name').html name

					if data.owner
						el.find('.delete').remove()
					else
						el.find('.delete').click =>
							@callBackgroundMethod 'delete', [data.id]
							false
				el
			).setDataSource data.collaborators


			@el.find('ul.activity').html '
				<li class="entry">
					<span class="type" />
					<span class="imagePreview" />
					<span class="text" />
					<span class="timestamp" />
				</li>'
			@stateView.listInterface(@el.find('ul.activity'), '.entry', (el, data, pos, onRemove) =>
				view = @stateView.createView()
				onRemove -> view.destruct()

				el.addClass data.type.replace '.', '-'

				if data.images.length
					el.addClass 'hasImage'
					classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
					el.find('.imagePreview').addClass classesForLength[data.images.length]

					for image in data.images
						imageEl = $('<span class="image" />').appendTo el.find('.imagePreview')
						do (imageEl) =>
							if image == 'decision'
								icons.setIcon imageEl, 'list', itemClass:false
							else if image == 'bundle'
								icons.setIcon imageEl, 'bundle', itemClass:false
							else if image == 'belt'
								# icons.setIcon imageEl, 'bundle', itemClass:false
							else
								@withData image, (image) =>
									imageEl.css 'backgroundImage', "url('#{image}')"

				textEl = el.find('.text')
				for comp in data.text
					if typeof comp == 'string'
						textEl.append document.createTextNode comp
					else
						objEl = $ '<span class="object" />'
						if comp.type == 'user'
							objEl.addClass 'user'
							objEl.html "<span class='name'>#{comp.text}</span> <span class='color' style='background-color: #{comp.color}' />"
						else if comp.model
							if comp.model == 'Product'
								objEl.addClass 'product'
								do (comp, objEl) =>
									objEl.click =>
										util.openProductPreview {modelName:'Product', instanceId:comp.id}
									@el.find('.activity').one 'scroll', -> popup.close()
									popup = util.popupTrigger2 objEl,
										delay:300
										closeDelay:0

										# stayOpen:true
										createPopup: (cb, close, addEl) =>
											# return false if window.suppressPopups
											productPopupView = @createView 'ProductPopupView', unconstrainedPictureHeight:true
											# @view.shoppingBarView.propOpen productPopupView
											tracking.page "#{@path()}/#{productPopupView.pathElement()}"

											frame = Frame.frameAbove objEl, productPopupView.el,
												type:'balloon'
												distance:10
												position:(if objEl.offset().top - $(window).scrollTop() < ($(window).height())/3 then 'below' else 'above')
												onClose: ->
													productPopupView.destruct()
													productPopupView = null
											# frame.el.css marginTop:-17
											productPopupView.close = close
											productPopupView.sizeChanged = ->
												frame.update()
												updateConnectorEl()
											productPopupView.addEl = addEl
											productPopupView.shown()
											setTimeout (->frame.update()), 500

											productPopupView.represent {modelName:'Product', instanceId:comp.id}
											@addExtension? frame.el

											connectorEl = $ '<div />'
											connectorEl.appendTo frame.el
											updateConnectorEl = ->
												height = objEl.offset().top - (frame.el.offset().top + frame.el.height())
												connectorEl.css
													position:'absolute'
													bottom:-height
													left:0
													width:'100%'
													height:height
											updateConnectorEl()
											frame.el
										onClose: (el) =>
											@removeExtension? el.data('frame').el
											el.data('frame')?.close? 100

									objEl.mousedown -> popup.close()

							else if comp.model == 'Decision'
								objEl.addClass 'decision'
								do (comp, objEl) =>
									@el.find('.activity').one 'scroll', -> popup.close()
									popup = util.popupTrigger2 objEl,
										delay:300
										closeDelay:0

										# stayOpen:true
										createPopup: (cb, close, addEl) =>
											return false if window.suppressPopups
											decisionPreviewView = @createView 'DecisionPreview'
											decisionPreviewView.editInModalDialog = true
											decisionPreviewView.represent {modelName:'Decision', instanceId:comp.id}
											decisionPreviewView.close = close
											decisionPreviewView.editEnv = (cb) ->
												cb objEl

											tracking.page "#{@path()}/#{decisionPreviewView.pathElement()}"
												

											frame = Frame.frameAbove objEl, decisionPreviewView.el,
												type:'balloon'
												distance:10
												position:(if objEl.offset().top - $(window).scrollTop() < ($(window).height())/3 then 'below' else 'above')
												onClose: ->
													decisionPreviewView.destruct()
													decisionPreviewView = null

											@addExtension? frame.el

											decisionPreviewView.sizeChanged = ->
												frame.update()
												updateConnectorEl()


											connectorEl = $ '<div />'
											connectorEl.appendTo frame.el
											updateConnectorEl = ->
												height = objEl.offset().top - (frame.el.offset().top + frame.el.height())
												connectorEl.css
													position:'absolute'
													bottom:-height
													left:0
													width:'100%'
													height:height
											updateConnectorEl()
											frame.el
										onClose: (el) =>
											@removeExtension? el.data('frame').el
											el.data('frame')?.close? 100

									objEl.mousedown -> popup.close()

							objEl.html comp.text
						else
							objEl.html comp.text
						textEl.append objEl

					textEl.append document.createTextNode ' '

				el.find('.timestamp').html data.timestamp

				el
			).setDataSource data.activity

		onData: (data) ->
			@withData data, (data) =>
				@configure data