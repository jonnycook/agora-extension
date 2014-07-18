define ['./ObservableArray', './auxiliary/maintainOrder', './Relationship'], (ObservableArray, maintainOrder, Relationship) ->
	class HasOneRelationship extends Relationship
		get: (propertyName) ->
			# if @_joint.field propertyName
			# 	@_joint.get propertyName
			# else
				@_relInstance?.get propertyName

		_get: (propertyName) ->
			@_relInstance?._get propertyName

		set: (propertyName, value) ->
			# if @_joint.field propertyName
			# 	@_joint.set propertyName, value
			# else
				@_relInstance?.set propertyName, value
			
		field: (propertyName) ->
			# if @_joint.field propertyName
			# 	@_joint.field propertyName
			# else
				@_relInstance?.field propertyName
			
		delete: ->
			@_relInstance?.delete()

		tableName: ->
			@_relInstance?.tableName()

		saneId: -> @_relInstance.saneId()

		equals: (instance) -> @_relInstance.equals instance

		isA: (modelName) -> @_relInstance.isA modelName

		isNull: -> !@_relInstance

		with: -> @_relInstance.with arguments...
		retrieve: -> @_relInstance.retrieve arguments...

		constructor: (@_instance, @_args, @_relName) ->
			throw new Error 'no relKey' unless @_args.relKey
			model = =>
				if typeof @_args.model == 'function'
					name = @_args.model @_instance
					if name
						@_instance.model.manager.getModel name
				else
					@_args.model

			updateRelInstance = =>
				if @_relInstance
					if @_relInstance.instanceMethods
						for method in @_relInstance.instanceMethods
							delete @[method]

				# if @model && @model._args.instanceMethods
				# 	for name,method of @model._args.instanceMethods
				# 		delete @[name]

				id = @_instance.get(@_args.relKey)
				if id
					@_relInstance = model().withId id
					@model = model()
					@modelName = @model.name
					@record = @_relInstance.record

					if @_relInstance.instanceMethods
						for method in @_relInstance.instanceMethods
							do (method) =>
								@[method] = => @_relInstance[method].apply @_relInstance, arguments


				else
					@_relInstance = null
					@model = @record = null


				# if @model && @model._args.instanceMethods
				# 	for name,method of @model._args.instanceMethods
				# 		do (name, method) =>
				# 			@[name] = => method.apply @_relInstance, arguments

				@_fireMutation 'changed'


			updateRelInstance()

			@observeObject @_instance.field(@_args.relKey), updateRelInstance

			@onDestruct = ->
				@_instance.field(@_args.relKey).stopObserving updateRelInstance