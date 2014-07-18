define ['./ClientObject'], (ClientObject) -> class ClientValue extends ClientObject
	constructor: (agora, owner, @_value) ->
		super
		
	get: -> @_value
	set: (value, timestamp=false) ->
		if typeof value == 'object' || value != @_value || timestamp
			@_triggerMutationEvent 'assignment',
				oldValue: ClientObject.serialize @_value
				value: ClientObject.serialize value
				timestamp:timestamp
			@_value = value

	trigger: ->
		@_triggerMutationEvent 'assignment',
			oldValue: ClientObject.serialize @_value
			value: ClientObject.serialize @_value

	serialize: ->
		obj = super
		_.extend obj,
			__class__: 'ClientValue'
			_scalar: ClientObject.serialize @_value