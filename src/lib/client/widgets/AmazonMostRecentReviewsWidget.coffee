define -> -> class AmazonMostRecentReviewsWidget
	title: 'Most Recent Reviews'
	expands:true
	constructor: (data) ->
		@el = $ '<div />'
		for review,reviewI in data
			break if reviewI == 3
			reviewEl = $ "<div class='recentReview'>
				<div class='wrapper'>
					<a href='#{review.url}' target='_blank' class='title'>#{review.title}</a>
					<div class='rating'>
						<div><div /></div>
						<div><div /></div>
						<div><div /></div>
						<div><div /></div>
						<div><div /></div>
					</div>
					<div class='author'>#{review.author}</div>
				</div>
				<!--<div class='review'>#{review.review}</div>-->
			</div>"

			util2.setRating reviewEl.find('.rating'), review.rating

			@el.append reviewEl

	init: ->
		# @el.find('.review').dotdotdot()
		# if !@el.find('.review').triggerHandler('isTruncated')
		# 	@expands = false
