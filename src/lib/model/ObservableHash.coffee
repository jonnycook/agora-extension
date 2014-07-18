define ['./ObservableObject'], (ObservableObject) ->
	class ObservableHash extends ObservableObject
		constructor: (@_hash) ->
			throw new Error 'must pass a hash' unless @_hash
		get: (key) -> @_hash[key]
		set: (key, value) ->
			oldValue = @_hash[key]
			@_hash[key] = value
			@_fireMutation 'set', key:key, value:value, oldValue:oldValue