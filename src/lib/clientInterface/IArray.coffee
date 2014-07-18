define ['underscore'], (_) -> class IArray
	constructor: ->
		@_array = []
		@length = 0
	get: (pos) -> @_array[pos]
	setArray: (array) ->
		while @length
			@delete()
		for el,i in array
			@insert el, i
	delete: (pos) -> 
		@_array.splice pos, 1
		--@length
	insert: (el, pos) ->
		if pos == 0
			@_array.unshift el
		else if pos == @_array.length
			@_array.push el
		else
			@_array.splice pos, 0, el
		++@length
	push: (el) -> @_array.insert el, @_array.length
	each: (cb) -> _.each @_array, cb
	forEach: (cb) -> @each cb
	move: (from, to) ->
		if from != to
			[el] = @_array.splice from, 1
			@_array.splice to, 0, el
