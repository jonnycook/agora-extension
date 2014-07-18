define -> -> class Observable
	observe: (event, observer) ->
		@observers ?= {}
		if @observers[event]
			@observers[event].push observer
		else
			@observers[event] = [observer]

	trigger: (event) ->
		if @observers[event]
			observer.apply(null, Array.prototype.slice.call(arguments, 1)) for observer in @observers[event]
 