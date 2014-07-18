define ['./Model', './Event'], (Model, Event) ->
	class ModelManager
		constructor: (@db, @background) ->
			@_models = {}
			@db.events.onBeforeExecuteChanges.subscribe =>
				@pauseRelationships()

			@db.events.onAfterExecuteChanges.subscribe =>
				@resumeRelationships()

			@events = onFault:new Event

			@_modelsByTable = {}

		pauseRelationships: ->
			@relationshipsPaused = true
			@relationshipsQueue = []
			@mutations = []

		resumeRelationships: ->
			@relationshipsPaused = false
			for instance in @relationshipsQueue
				instance._createRelationships()

			for instance in @relationshipsQueue
				instance._initRelationships()

			for mutation in @mutations
				mutation.observer mutation.mutation

			for instance in @relationshipsQueue
				instance.model.events.onCreate.fire instance, instance.model


			delete @relationshipsQueue
			delete @mutations

		clear: ->
			for name, model in @_models
				model.clear()

		model: (name) -> @getModel name

		instanceForRecord: (record) ->
			if record
				model = @_modelsByTable[record.table.name]
				model.withId record.get('id')

		getModel: (name) -> 
			model = @_models[name]
			if model
				model
			else
				throw new Error "no model '#{name}'"


		instance: (model, id) -> @getInstance model, id
		getInstance: (model, id, throwError=true) ->
			@getModel(model).withId id, throwError

		addModel: (modelName, modelDef) ->
			@_modelsByTable[modelDef.table] = @_models[modelName] = new (modelDef.class ? Model) @, modelName, @background, modelDef

		initModels: ->
			model._initRelationships() for modelName, model of @_models

		defineModels: (definitions) ->
			if definitions
				for modelName, modelDef of definitions
					@addModel modelName, modelDef
				
			@initModels()