define -> -> class AmazonFeatureWidget
	title: 'Features'
	expands:false
	constructor: (data) ->
		@el = $ '<ul />'
		for feature in data
			@el.append("<li>#{feature}</li>")
