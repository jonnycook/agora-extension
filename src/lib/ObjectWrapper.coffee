define ['model/ObservableValue'], (ObservableValue) -> class ObjectWrapper
	@create: (storeId, object, defaults) ->
		new ObjectWrapper storeId, object, defaults

	getObject: ->
		if @object == '@'
			agora.modelManager.getInstance('User', "G#{@storeId}")

	field: (name) -> @fields[name]
	get: (name) ->
		if name == 'id'
			if @object == '@'
				"G#{@storeId}"
			else if @object == '/'
				throw new Error
			else
				[table, id] = @object.split '.'
				return "G#{id}"
		else
			@fields[name].get()

	saneId: ->
		parseInt @get('id').substr 1

	constructor: (@storeId, @object, @values) ->
		@empty = true
		@fields = {}
		for name,value of @values
			@fields[name] = new ObservableValue value

		@whenObject = agora.updater.transport.whenObject @storeId, [@object],
			=>
				@empty = false
				@obj = @getObject()
				for name,field of @fields
					field.set @obj.get name
			=>
				@empty = true
				for name,field of @fields
					field.set @values[name]

	destruct: ->
		agora.updater.transport.unregisterWhenObject @whenObject
