define ['underscore'], (_) -> class Event
	subscribe: (subscriber) ->
		@subscribers ?= []
		@subscribers.push subscriber

	unsubscribe: (subscriber) ->
		_.pull @subscribers, subscriber if @subscribers

	fire: (args...) ->
		subscriber args... for subscriber in @subscribers if @subscribers