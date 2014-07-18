define -> -> class AmazonSizesWidget
	title: 'Sizes'
	expands:false
	constructor: (data) ->
		@el = $ "
			<div>
				<ul class='sizes' />
			</div>
		"

		if data.howItFits
			@el.prepend("<span class='howItFits'>How it fits: <strong>#{data.howItFits}</strong></span>")

		for size in data.sizes
			@el.find('.sizes').append "<li>#{size}</li>"
