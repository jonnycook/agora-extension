define ['underscore', './ClientObject', './IArray'], (_, ClientObject, IArray) -> class ClientArray extends ClientObject
	constructor: ->
		super
		@_array = new IArray
	
	get: (pos) -> @_array.get pos

	setArray: (array) ->
		@_array.setArray array
		@_triggerMutationEvent 'setArray', array:ClientObject.serialize @_array
	
	delete: (pos) ->
		@_array.delete pos
		@_triggerMutationEvent 'deletion', position: pos
	
	insert: (el, pos) ->
		@_array.insert el, pos
		@_triggerMutationEvent 'insertion',
			value: ClientObject.serialize el
			position: pos
			
	move: (from, to) ->
		@_array.move from, to
		@_triggerMutationEvent 'movement', from: from, to: to
			
	push: (el) ->
		@insert el, @_array.length
		
	serialize: ->
		obj = super
		_.extend obj,
			__class__: 'ClientArray'
			_array: ClientObject.serialize @_array
