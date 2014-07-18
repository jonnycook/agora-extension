define ['./ObservableArray', './auxiliary/maintainOrder2', './Relationship', 'util'], (ObservableArray, maintainOrder, Relationship, util) ->
	class ModelInstanceWrapper
		constructor: (@_rel, @_joint) ->
			getModel = (record) =>
				if typeof @_rel._model == 'function'
					@_rel._instance.model.manager.getModel @_rel._model record
				else
					@_rel._model			

			@_update = =>
				if @_instance
					@_instance.stopObservingWithTag @
					if @_instance.instanceMethods
						for method in @_instance.instanceMethods
							delete @[method]


				@_instance = getModel(@_joint).withId @_joint.get @_rel._relKey
				@_instance.observeWithTag @, (mutation) =>
					@_rel._remove @

				if @_instance.instanceMethods
					for method in @_instance.instanceMethods
						do (method) =>
							@[method] = => @_instance[method].apply @_instance, arguments



				@model = @_instance.model
				@modelName = @model.name
				@record = @_instance.record

			# @_joint.field(@_rel._relKey).observe @_update

			@_rel.observeObject @_joint.field(@_rel._relKey), @_update
			@_update()

			# if @model._args.instanceMethods
			# 	for name,method of @model._args.instanceMethods
			# 		@[name] = => method.apply @_instance, arguments
		
		get: (propertyName) ->
			if @_joint.field propertyName
				@_joint.get propertyName
			else
				@_instance.get propertyName

		_get: (propertyName) ->
			@_instance._get propertyName

		set: (propertyName, value) ->
			if @_joint.field propertyName
				@_joint.set propertyName, value
			else
				@_instance.set propertyName, value
			
		field: (propertyName) ->
			if @_joint.field propertyName
				@_joint.field propertyName
			else
				@_instance.field propertyName
			
		delete: ->
			@_instance.delete()

		tableName: ->
			@_instance.tableName()

		saneId: -> @_instance.saneId()

		equals: (instance) -> @_instance.equals instance

		isA: (modelName) -> @_instance.isA modelName

		with: -> @_instance.with arguments...
		retrieve: -> @_instance.retrieve arguments...

		saneId: -> @_instance.saneId()

	class HasManyRelationship extends Relationship
		_recordDataKey: (record) -> "#{record.table.name}.#{record.get 'id'}"
		_getRecordData: (record, required=false) ->
			key = @_recordDataKey record
			data = @_recordData[key]
			if !data && required
				Debug.error "no record data for #{key}"
				throw new Error "no record data for #{key}"
			data

		_setRecordData: (record, data) ->
			key = @_recordDataKey record
			@_recordData[key] = data

		_deleteRecordData: (record) ->
			delete @_recordData[@_recordDataKey record]

		constructor: (@_instance, @_args, @_relName) ->
			Relationship.nextId ?= 1

			@id = Relationship.nextId++

			{foreignKey:foreignKey, relKey:relKey, through:through} = _args
			@_model = _args.model

			getModel = (record) =>
				if typeof @_model == 'function'
					@_instance.model.manager.getModel @_model record
				else
					@_model


			if through
				@_table = @_instance.model.manager.db.table through
				if !@_table
					throw new Error "NO TABLE"

			else
				@_table = @_model._table
				relKey = 'id'
				if !@_table
					console.log @_model
					throw new Error "NO TABLE"

			@_relKey = relKey

			if !@_table
				console.log @_relName

			@_list = new ObservableArray
			if @_args.orderBy
				maintainOrder @_list, @_args.orderBy

			@_list.name = "HasManyRelationship::#{@_model.name}.#{_relName}"

			@_list.observe (mutation) => @_callObservers mutation
			
			@_recordData = {}				
			
			testRelation = (record, filter=true) =>
				l = @_instance.get('id')
				r = record.get foreignKey

				t = `l == r`

				return false unless t

				if filter
					if through && @_args.throughFilter
						return false unless @_args.throughFilter record

					if @_args.filter
						return false unless @_args.filter record
				true
				
				
			remove = (record) =>
				relId = record.get relKey
				modelName = getModel(record).name

				@_list.deleteIf (relInstance) -> `relInstance.get('id') == relId && relInstance.modelName == modelName`

				recordData = @_getRecordData record, true
				
				@_args.onRemove.call @, recordData.instance if @_args.onRemove

				if @_args.orderBy
					if @length()
						for i in [Math.min(record.get(@_args.orderBy),@length()-1)...@length()]
							@get(i).set @_args.orderBy, i

				recordData.onRemove?()

				@_deleteRecordData record

			initRecord = (record) =>
				for field in record.fields()
					field.observe =>
						if @_getRecordData record
							if !testRelation record
								remove record
						else 
							onRecord record

				onRecord record

			onRecord = (record) =>
				if testRelation record
					relId = record.get relKey
					instance = null
					if through
						instance = new ModelInstanceWrapper @, record
					else
						instance = @_model.withId relId

					throw new Error 'null instance' unless instance

					@_setRecordData record, 
						instance:instance
						# onRemove: ->
						# 	stopMaintainingOrder?()
					
					@_args.onBeforeAdd.call @, instance if @_args.onBeforeAdd

					# if @_args.orderBy
					# 	if instance.get(@_args.orderBy.field) == null
					# 		instance.set(@_args.orderBy.field, @length())

					@_list.push instance
					
					# stopMaintainingOrder = if @_args.orderBy
					# 	maintainOrder @_args.orderBy, instance, @_list

					@_args.onAfterAdd.call @, instance if @_args.onAfterAdd
		
			@_table.records.each initRecord
			
			@observeObject @_table.records, (mutation) =>
				if mutation.type == 'insertion'
					initRecord mutation.value
				else if mutation.type == 'deletion'
					remove mutation.value if @_getRecordData mutation.value

			if _args.for
				@init = =>
					path = _args.for.path.split '.'
					rel = @_instance.get(path[0]).get(path[1])
					@for = onRelInst = (relInst) =>
						inst = @find (inst) => inst.get(_args.for.key) == relInst.get('id')
						unless inst
							args = {}
							args[_args.for.key] = relInst.get 'id'
							inst = @_model.create args
							@_add inst
						inst
					rel.each onRelInst

					@observeObject rel, (mutation) =>
						if mutation.type == 'insertion'
							onRelInst mutation.value
						else if mutation.type == 'deletion'
							inst = @find (inst) => inst.get(_args.for.key) == mutation.value.get('id')
							@remove inst if inst
		
		get: (position) -> @_list.get position

		_add: (instance, fields) ->
			unless @contains instance
				if @_args.through
					record = {}
					record[@_args.foreignKey] = @_instance.get 'id'
					record[@_args.relKey] = instance.get 'id'

					defaults = {}
					if @_args.defaultValues
						if typeof @_args.defaultValues == 'function'
							defaults = @_args.defaultValues instance
						else
							defaults = @_args.defaultValues
					
					record[name] = value for name,value of defaults
					record[name] = value for name,value of fields if fields
					@_table.addRecord record
				else
					instance.set @_args.foreignKey, @_instance.get 'id'

		_remove: (instance) ->
			if @_args.through
				@_table.delete (record) => record.get(@_args.foreignKey) == @_instance.get('id') && record.get(@_args.relKey) == instance.get('id')
			else
				instance.set @_args.foreignKey, null

		add: (instance, fields) ->
			if @_args.add
				@_args.add.call @, instance, fields
			else
				@_add instance, fields

		remove: (instance) ->
			if @_args.remove
				@_args.remove.call @, instance
			else
				@_remove instance
			
		removeAt: (index) ->
			@remove @get index
			
		removeAll: ->
			if @_args.through
				@_table.delete (record) => record.get(@_args.foreignKey) == @_instance.get('id')

		# observe: (observer) ->
		# 	@_list.observe observer
			
		# stopObserving: (observer) ->
		# 	@_list.stopObserving observer
			
		each: -> @_list.each.apply @_list, arguments
		forEach: -> @each.apply @, arguments
				
		# contains: (instance) -> !!@_getRecordData instance.record
		contains: (instance) ->
			!!@find (inst) -> inst.modelName == instance.modelName && inst.get('id') == instance.get('id')
			
		length: -> @_list.length()
		
		move: (from, to) -> @_list.move(from, to)

		find: (predicate) -> util.find @_list, predicate
		findAll: (predicate) -> util.findAll @_list, predicate

		instanceForInstance: (instance) -> 
			if @_args.through
				@_list.find (inst) -> inst.equals instance
			else
				@_getRecordData(instance.record, true).instance