define ['underscore', './IArray'], (_, IArray) -> class ClientObject
	@_nextId: 1
	@_registry: {}
	
	@nextId: -> @_nextId++
	
	@serialize: (obj) ->
		if _.isArray obj
			newArray = []
			_.each obj, (el) =>
				newArray.push @serialize el
			newArray
		else if _.isObject obj
			if obj instanceof ClientObject
				obj.serialize()
			else if obj instanceof IArray
				@serialize obj._array
			else# if obj.constructor is Object
				newObject = {}
				for key, value of obj
					newObject[key] = @serialize value
				newObject
# 				else
# 					throw new Error "can't serialize obj #{obj}"
		else
			obj

	constructor: (@agora, @_owner) ->
		@_id = ClientObject.nextId()
		ClientObject._registry[@_id] = @

	radioSilence: (block) ->
		@_radioSilence = true
		block()
		@_radioSilence = false
		
	_triggerEvent: (event, args) ->
		if !@_radioSilence
			@agora.background.triggerContentScriptEvent "ClientObjectEvent:#{@_id}",
				_.extend({event:event}, (if @_name then _.extend({name:@_name}, args) else args)), 
				@debug
		
	_triggerMutationEvent: (type, args) ->
		@_triggerEvent 'mutation', _.extend({type:type}, args)
		
	disconnectClient: ->
		@_triggerEvent 'disconnection'

	serialize: ->
		obj = _id:@_id
		if @_name
			obj._name = @_name
		obj

	destruct: ->
		ClientObject._registry[@_id] = false
		@disconnectClient()