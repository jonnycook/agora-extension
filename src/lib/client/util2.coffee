define -> ->
	setRating: (el, rating, animate=false) ->
		if rating == '(error)'
			for starEl,i in el.find('div div')
				$(starEl).css width:0
			el.addClass 'error'
		else
			el.removeClass 'error'
			intRating = parseInt rating

			el.find('div div').css width:0

			speed = 100
			delay = -10

			setTimeout (->
				for starEl,i in el.find('div div')
					if i < intRating
						if animate
							do (starEl, i) ->
								setTimeout (->$(starEl).animate width:18, speed), i*(speed+delay)
						else
							$(starEl).css width:18

				if rating - intRating
					if animate
						setTimeout (->el.find("div:nth-child(#{intRating + 1}) div").animate width:18 * (rating - intRating), speed), intRating*(speed+delay)
					else
						el.find("div:nth-child(#{intRating + 1}) div").css width:18 * (rating - intRating)

			), if animate then 500 else 0

	ratingHtml:
		'<div><div /></div>
		<div><div /></div>
		<div><div /></div>
		<div><div /></div>
		<div><div /></div>'