define -> d: ['View', 'Frame'], c: ->
	class ReviewsView extends View
		type: 'Reviews'
		constructor: (@contentScript) ->
			super @contentScript
			@el = $ '
				<div class="-agora v-reviews">
					<div class="cont">
						Loading reviews...
					</div>
				</div>'
				
			util.trapScrolling @el.find('.cont')
			
		onData: (data) ->
			@withData data, (data) =>
				contEl = @el.find('.cont')
				contEl.html ''
				if data.reviews.length || data.reviews.url
					for review in data.reviews
						el = $ "<div class='review'>
							<a class='title' target='_blank' href='#{review.url}'>
							<span class='rating rating#{review.rating}'>
								<span />
								<span />
								<span />
								<span />
								<span />
							</span>
							#{review.title}</a>
							<div class='review'>#{review.review}</div>
							<a href='#{review.url}' target='_blank' class='readMore'>Read more</a>
						</div>"

						el.find('.title').click => @event 'goToReview'
						contEl.append el

					if data.url
						text = if data.count == undefined
								'Read all reviews'
							else
								switch data.count
									when 0
										'No reviews'
									when 1
										'Read one review'
									else
										"Read all #{data.count} reviews"

						contEl.append("<a class='allReviews' target='_blank' href='#{data.url ? '#'}'>#{text}</a>")
						contEl.find('.allReviews').click => @event 'goToAllReviews'
				else
					contEl.html 'No reviews'

				@sizeChanged?()
				# util.scrollbar @el.find('.cont'), trapScrolling:true

		shown: ->
			@event 'open'