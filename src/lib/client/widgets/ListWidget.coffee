define -> -> class ListWidget
	# expands:false
	constructor: (data) ->
		@title = data.title
		@el = $ '<ul />'
		for item in data.content
			@el.append("<li>#{item}</li>")
