
define -> d: ['View', 'Frame', 'views/OffersView', 'views/DataView', 'views/AddFeelingView', 'views/AddArgumentView'], c: ->
	class DecisionPreviewView extends View
		type: 'DecisionPreview'
		init: ->
			@viewEl '
				<span class="descriptorTooltip">
					<span class="preview"><span class="image" /></span>
					<div class="descriptorWrapper"><span class="icon" /> <span class="descriptor" /><a class="edit" href="#" /></div>
				</span>'

		onData: (data) ->
			text = if data.descriptor.get()?.descriptor
				data.descriptor.get()?.descriptor
			else 
				'<i>Edit Decision</i>'

			@el.find('.descriptorWrapper .descriptor').html text

			icons.setIcon @el.find('.icon'), data.icon.get() ? 'list', size:'small'
			@el.find('.icon').removeClass 't-item'

			util.tooltip @el.find('.edit'), 'edit'
			edit = =>
				if @editInModalDialog
					tracking.page "#{@path()}/EditDescriptor"
					util.presentViewAsModalDialog 'EditDescriptor', @args
				else
					@editEnv (el) =>
						editDescriptorView = @createView 'EditDescriptor'
						# args.view.shoppingBarView.propOpen editDescriptorView
						editDescriptorView._mouseenter true
						editDescriptorView.close = -> frame.close()
						editDescriptorView.represent decision:@args
						frame = Frame.frameAround el, editDescriptorView.el, type:'balloon', distance:20, close: -> frame.close(); editDescriptorView.destruct()
						tracking.page "#{@path()}/#{editDescriptorView.pathElement()}"

			@el.find('.edit').click -> edit(); false
			@el.find('.descriptor').click -> edit(); false

			openCompareView = =>
				tracking.page "#{@path()}/Compare"
				compareTileView = new CompareView @contentScript
				compareTileView.shoppingBarView = shoppingBarView
				frameEl = Frame.wrapInFrame compareTileView.el,
					type:'fullscreen'
					scroll:true
					resize: (width, height) -> [width - 100, height - 100]
					close: -> compareTileView.destruct()

					
				compareTileView.close = -> Frame.close frameEl

				frameEl.appendTo document.body
				Frame.show frameEl

				compareTileView.setContEl frameEl.data('client')
				compareTileView.backEl = compareTileView.contEl
				compareTileView.el.css margin:'20px auto 0'

				compareTileView.represent @args
				# tracking.page "#{@path()}/Compare"
				# @event 'openWorkspace'

			@el.find('.preview').click openCompareView

			contents = @listInterface @el.find('.preview'), '.image', (el, data, pos, onRemove) =>
				el.css 'background-image', "url('#{data}')"
			contents.setDataSource data.preview

			prevLength = contents.length()
			classesForLength = 0:'empty', 1:'oneItem', 2:'twoItems', 3:'threeItems', 4:'fourItems'
			updateForLength = =>
				@el.find('.preview').removeClass classesForLength[prevLength]
				@el.find('.preview').addClass classesForLength[prevLength = contents.length()]

			contents.onLengthChanged = updateForLength
			updateForLength()

			@sizeChanged?()


		# shown: ->
		# 	@event 'open'
	
