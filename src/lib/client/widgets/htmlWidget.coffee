define -> -> class htmlWidget
	expands:true
	constructor: (@data) ->
		@title = data.title
		@el = $("<div class='htmlContent'>#{data.content}</div>")
		if data.maxHeight?
			@el.css 'max-height', data.maxHeight

	init: ->
		if @data.maxHeight != 'none'
			@el.dotdotdot()
			if !@el.triggerHandler('isTruncated')
				@expands = false
