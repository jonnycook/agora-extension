define -> d: ['View', 'util', 'icons'], c: -> 
	class SharedWithYouView extends View
		type: 'SharedWithYou'
		constructor: ->
			super
			@viewEl '<div class="v-sharedWithYou t-dialog">
				<h2>Shared With You</h2>

				<div class="content">
					<ul class="objects">
						<li class="object">
							<span class="title" />
							<span class="user" />
							<input type="checkbox" class="inBelt" />
						</li>
					</ul>
				</div>
			</div>'

		onData: (data) ->
			@listInterface(@el.find('.objects'), '.object', (el, data, pos, onRemove) =>
				view = @createView()
				onRemove -> view.destruct()
				el.addClass data.type
				el.find('.user').html data.userName
				view.valueInterface(el.find('.title')).setDataSource data.title
				el.click => @callBackgroundMethod 'click', [data.id]
				util.tooltip el.find('.inBelt'), 'show on belt'
				el.find('.inBelt')
					.click (e) => e.stopPropagation()
					.change =>
						@callBackgroundMethod 'inBelt', [data.id, el.find('.inBelt').prop 'checked']

				view.withData data.inBelt, (inBelt) =>
					el.find('.inBelt').prop 'checked', inBelt

				if data.seen.get()
					el.addClass 'seen'

				el
			).setDataSource data.entries


			@callBackgroundMethod 'seen'
