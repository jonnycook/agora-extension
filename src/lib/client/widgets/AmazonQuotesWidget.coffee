define -> -> class AmazonQuotes
	title: 'Quotes'
	expands:true
	constructor: (data) ->
		@el = $ '<div />'
		for quote in data
			quoteEl = $ "<div class='quoteEntry'>
				<div class='wrapper'>
					<a href='#{quote.url}' target='_blank' class='quote'>#{quote.quote}</a>
					<div class='author'>#{quote.author}</div>
				</div>
			</div>"
			@el.append quoteEl

	init: ->
		# @el.find('.review').dotdotdot()
		# if !@el.find('.review').triggerHandler('isTruncated')
		# 	@expands = false
