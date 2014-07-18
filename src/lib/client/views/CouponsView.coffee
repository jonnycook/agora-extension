define -> d: ['View', 'Frame'], c: ->
	class CouponsView extends View
		type: 'Coupons'
		constructor: (@contentScript) ->
			super @contentScript
			@el = $ '
				<div class="-agora v-coupons">
					<div class="cont">
						Loading deals...
					</div>
				</div>'
				
			util.trapScrolling @el.find('.cont')
			
		onData: (data) ->
			update = =>
				contEl = @el.find('.cont')
				if data.get()
					contEl.html ''

					for deal in data.get()
						contEl.append "<div class='deal'><a target='_blank' href='#{deal.href}'>#{deal.offer_text}</a></div>"

				@sizeChanged?()

			data.observe update
			update()
