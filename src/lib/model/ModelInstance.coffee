define ['./HasManyRelationship', './HasOneRelationship', './ObservableObject'], (HasManyRelationship, HasOneRelationship, ObservableObject) ->
	class ModelInstance extends ObservableObject
		_createRelationship: (constructor, relName) ->
			if typeof constructor == 'function'
				constructor @
			else
				if typeof constructor.model == 'string'
					constructor.model = @model.manager.getModel constructor.model
				switch constructor.type
					when 'hasMany'
						new HasManyRelationship @, constructor, relName
					when 'hasOne'
						new HasOneRelationship @, constructor, relName
					
		_createRelationships: ->
			@_relationships = {}
			if relationships = @model.relationships
				for relName, relArgs of relationships
					@_relationships[relName] = @_createRelationship relArgs, relName

			# @model.events.onCreate.fire @, @model

		_initRelationships: ->
			for relName, rel of @_relationships
				rel.init?()

		saneId: -> @record.saneId()

		createRelationships: (shouldCreateRelationships) ->
			if @model.manager.relationshipsPaused
				@model.manager.relationshipsQueue.push @
			else if shouldCreateRelationships
				@_createRelationships()
				@_initRelationships()

		constructor: (@model, @record) ->
			@modelName = @model.name
			# @createRelationships()
			@retrieving = {}

		_get: (propertyName) -> @record.get propertyName

		get: (propertyName) ->
			if rel = @_relationships?[propertyName]
				rel
			else if prop = @model.properties?[propertyName]
				prop.call @
			else
				@_get propertyName

		set: (propertyName, value, timestamp) ->
			@record.set propertyName, value, timestamp
			
		field: (name) -> @record.field name
			
		delete: (failSilently=false) ->
			@model.delete @, failSilently

		tableName: -> @record.tableName()

		equals: (instance) ->
			@model == instance.model && @get('id') == instance.get('id')

		isA: (modelName) ->
			modelName == @modelName

		retrieve: (field, cb=null, force=false) ->
			if @get(field) == null || force
				if @retrieving[field]
					@retrieving[field].push cb if cb
				else
					@retrieving[field] = []
					@retrieving[field].push cb if cb
					@retrievers[field].call @, (value) =>
						@set field, value
						cb value for cb in @retrieving[field] if @retrieving[field]
						delete @retrieving[field]
			else if cb
				cb @get field

		with: (fields..., cb) ->
			values = []
			done = ->
				if !--count
					cb values...

			count = fields.length
			for field,i in fields
				do (field,i) =>
					if @retrieving[field]
						@retrieving[field].push (value) =>
							values[i] = value
							done()
					else
						if @get(field) == null
							@retrieve field, (value) =>
								values[i] = value
								done()
						else
							values[i] = @get field
							done()
