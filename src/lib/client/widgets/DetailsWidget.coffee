define -> -> class DetailsWidget
	expands:false
	constructor: (data) ->
		@title = data.title
		@el = $ '<ul />'
		for name,detail of data.content
			@el.append("<li><span class='name'>#{name}</span>: <span class='value'>#{detail}</span></li>")
