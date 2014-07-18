define ['./ObservableObject', 'underscore'], (ObservableObject, _) ->
	class ObservableValue extends ObservableObject
		constructor: (@_value, @_reassignIdentical=false) ->

		test: (value) ->
			return true if @_reassignIdentical
			if @_type == 'object'
				!_.isEqual value, @_value
			else
				value != @_value
		set: (value, timestamp) ->
			if @test value
				oldValue = @_value
				@_value = value

				@_fireMutation 'set', value:value, oldValue:oldValue, timestamp:timestamp
		get: -> @_value

		with: (cb) ->
			if @_value != null
				cb @_value
			else
				@observe =>
					if @_value != null
						cb @_value
						@stopObserving arguments.callee