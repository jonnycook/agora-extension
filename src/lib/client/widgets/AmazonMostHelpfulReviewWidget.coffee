define -> -> class AmazonMostHelpfulReviewWidget
	title: 'Most Helpful Review'
	expands:true
	constructor: (data) ->
		@el = $ "<div>
			<div class='wrapper'>
			<a href='#{data.url}' target='_blank' class='title'>#{data.title}</a>
			<div class='rating'>
				<div><div /></div>
				<div><div /></div>
				<div><div /></div>
				<div><div /></div>
				<div><div /></div>
			</div>
			<div class='author'>#{data.author?.name ? data.author}</div>
			</div>
			<div class='review'>#{data.review}</div>
		</div>"

		util2.setRating @el.find('.rating'), data.rating
		# intRating = parseInt rating

		# for starEl,i in @el.find('.rating div div')
		# 	if i >= intRating
		# 		$(starEl).css width:0

		# if rating - intRating
		# 	@el.find(".rating div:nth-child(#{intRating + 1}) div").css width:18 * (rating - intRating)




	init: ->
		@el.find('.review').dotdotdot()
		if !@el.find('.review').triggerHandler('isTruncated')
			@expands = false
