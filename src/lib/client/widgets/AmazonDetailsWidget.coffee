define -> -> class AmazonDetailsWidget
	title: 'Details'
	expands:false
	constructor: (data) ->
		@el = $ '<ul />'
		for name,detail of data
			@el.append("<li><span class='name'>#{name}</span>: <span class='value'>#{detail}</span></li>")
