define ['./ModelInstance', './ObservableArray', './Event', './auxiliary/maintainOrder2'], (ModelInstanceBase, ObservableArray, Event, maintainOrder) ->
	class Model
		constructor: (@manager, @name, @background, args) ->
			{relationships:@relationships, properties:@properties} = args
			@_byId = {}
			@_list = new ObservableArray
			@_list.name = "Model::#{@name}"
			@_table = table = @manager.db.table args.table
			@_args = args

			@_fault = args.fault


			if !table
				throw new Error "NO TABLE"
			
			if @_args.orderBy
				maintainOrder @_list, @_args.orderBy

			table.records.each (record) =>
				@_addFromRecord record, false
			
			table.records.observe (mutation) =>
				unless @_ignoringTableMutations
					if mutation.type == 'insertion'
						@_addFromRecord mutation.value
					else if mutation.type == 'deletion'
						@_remove mutation.value

			@ModelInstance = class ModelInstance extends ModelInstanceBase

			if args.instanceMethods
				for name,method of args.instanceMethods
					@ModelInstance.prototype[name] = method


			@events =
				onCreate: new Event
				onRemove: new Event

					
		_initRelationships: ->
			@_list.each (instance) -> instance._createRelationships()
		
		_addFromRecord: (record, createRelationships=true) ->
			unless @_byId[record.get 'id']
				# console.log 'added:', record
				instance = new @ModelInstance @, record, false
				@_byId[instance.get 'id'] = instance

				@_args.onBeforeAdd.call @, instance if @_args.onBeforeAdd	
				
				# if @_args.orderBy
				# 	if instance.get(@_args.orderBy.field) == null
				# 		instance.set(@_args.orderBy.field, @_list.length())


				# if @_args.orderBy
				# 	maintainOrder @_args.orderBy, instance, @_list

				instance.createRelationships createRelationships

				@_list.push instance

				@_args.onAfterAdd?.call @, instance	

				setTimeout (=> @events.onCreate.fire instance, @ if instance._relationships), 0

				instance
			else
				# console.log 'already added:', record
				@_byId[record.get 'id']
		
		# don't call directly, otherwise _list might become out-of-sync with it's corresponding table
		_remove: (record) ->
			@_list.deleteIf (model) => `model.get('id') == record.get('id')`
			instance = @_byId[record.get('id')]

			for name,rel of instance._relationships
				rel.destruct()


			instance._fireMutation 'deleted'
			delete @_byId[record.get('id')]

			@_args.onRemove.call @, instance if @_args.onRemove
			@events.onRemove.fire instance, @

			if @_args.orderBy						
				if @_list.length()
					for i in [Math.min(record.get(@_args.orderBy),@_list.length()-1)...@_list.length()]
						@_list.get(i).set @_args.orderBy, i

			
		withId: (id, throwError=true) ->
			unless @_byId[id]
				if @_fault
					@_table._addRecord {}, id
					instance = @_byId[id]
					@manager.events.onFault.fire instance
					instance
				else if throwError
					throw new Error "Model #{@name} does not have instance with id #{id}"
			else
				@_byId[id]
		
		_ignoreTableMutations: (block) ->
			@_ignoringTableMutations = true
			ret = block()
			@_ignoringTableMutations = false
			ret

		@find: (list, predicate) ->
			if _.isPlainObject predicate
				list.find (instance) ->
					for name,value of predicate
						if instance.get(name) != value
							return false
					true
			else
				list.find predicate

		@findAll: (list, predicate) ->
			if _.isPlainObject predicate
				list.findAll (instance) ->
					for name,value of predicate
						if instance.get(name) != value
							return false
					true
			else
				list.findAll predicate


		find: (predicate) -> Model.find @_list, predicate

		findAll: (predicate) -> Model.findAll @_list, predicate

		add: (data = {}) ->
			record = @_table.addRecord data
			@_byId[record.get 'id']

		create: (data = {}) -> @add data
		
		all: -> @_list

		# TODO: remove records from relationship tables as well
		delete: (instance) ->
			if instance.model == @
				@_table.delete (record) => `record.id == instance.get('id')`
				for relName, rel of instance._relationships
					rel.removeAll?()
					rel.destruct()
			else
				throw new Error "incorrect instance model"


		clear: ->
			@_byId = {}
			@_list.clear()