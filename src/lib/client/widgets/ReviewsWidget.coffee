define -> -> class ReviewsWidget
	expands:true
	constructor: (@data) ->
		@title = data.title ? 'Reviews'
		@el = $ '<ul />'
		for review,reviewI in data.content
			break if reviewI == data.count ? 3
			reviewEl = $ "<li class='review'>
				<div class='wrapper'>
					<a href='#{review.url}' target='_blank' class='title'>#{review.title ? ''}</a>
					<div class='rating'>
						<div><div /></div>
						<div><div /></div>
						<div><div /></div>
						<div><div /></div>
						<div><div /></div>
					</div>
					<div class='author'>#{review.author}</div>
				</div>
				<div class='review'>#{review.review ? review.content}</div>
			</div>"

			if !review.review
				reviewEl.find('div.review').remove()
			else if data.maxHeight
				reviewEl.find('div.review').css 'maxHeight', data.maxHeight

			if !review.url
				reviewEl.find('.title').removeAttr 'href'

			util2.setRating reviewEl.find('.rating'), review.rating

			@el.append reviewEl

	init: ->
		if @data.maxHeight
			@el.find('div.review').dotdotdot()

		# if !@el.find('.review').triggerHandler('isTruncated')
		# 	@expands = false
