define ['./ObservableObject', './ObservableValue', 'underscore'], (ObservableObject, ObservableValue, _) ->
	class Record extends ObservableObject
		constructor: (@id, @_values, @_mappings, @table) ->	
			if typeof @id == 'string'
				if @id[0] != 'G'
					@id = parseInt @id

			# if @table.onGraph && @table.db.storeId
			if @table.canBeExternal && @table.db.externalStoreId
				@storeId = @table.db.externalStoreId
			else
				@storeId = @table.db.storeId

			# else
				# @storeId = 0

			@_fields = {}

			@_tableName = @table.name

			@_sources = {}

			for name, value of _values
				@_values[name] = if @_mappings[name] && value != null then @_mappings[name] value else value
				@_createField name


			@_updateStoreIdFromOwner()

		_addSource: (source, accumulate=true) ->
			key = "#{source.storeId}.#{source.object}"
			if @_sources[key] && accumulate
				@_sources[key]++
			else
				@_sources[key] = 1

		_removeSource: (source) ->
			key = "#{source.storeId}.#{source.object}"
			if @_sources[key]
				if !--@_sources[key]
					delete @_sources[key]

		_updateContentsStoreId: ->
			contained = @contained()
			for record in contained
				record.storeId = @storeId

		_updateStoreIdFromOwner: ->
			owner = @owner()
			if owner
				@storeId = owner.storeId
				contained = @contained()
				for record in contained
					record.storeId = @storeId

		_createField: (name) ->
			@_fields[name] = field = new ObservableValue @_values[name], @table.schema.opts?[name]?.reassignIdentical

			if @table.graphRels
				for rel in @table.graphRels
					if rel.owns && rel.field == name
						field.observe =>
							# console.debug 'content change', @, field.get()
							@_updateContentsStoreId()
						break
					else if rel.owner && rel.field == name
						field.observe =>
							# console.debug 'owner changed', @, field.get()
							@_updateStoreIdFromOwner()
						break

		set: (key, value, timestamp) -> 
			if key == 'store_id'
				@storeId = value
			else
				@_values[key] = if @_mappings[key] && value != null then @_mappings[key] value else value
				if @_fields[key]
					@_fields[key].set @_values[key], timestamp
				else
					@_createField key
		get: (key) ->
			switch key
				when 'id'
					@id
				when 'store_id'
					@storeId
				else
					@_fields[key]?.get()

		field: (key) -> @_fields[key]

		fields: -> _.values @_fields
		
		serialize: -> @_values

		globalId: -> @table.db.localToGlobalMapping[@table.name]?[@id] ? @id

		hasGlobal: -> (@id + '')[0] == 'G' || @table.db.localToGlobalMapping[@table.name]?[@id]?

		tableName: -> @table.name
		saneId: ->
			id = @globalId() + ''
			if id[0] == 'G'
				parseInt id.substr 1
			else if env.localTest
				@get('id')
			else
				console.log @
				throw new Error id

		delete: ->
			@table.delete (record) => record.get('id') == @get('id')

		contained: (recursive=true)->
			contained = []
			if @table.graphRels
				for rel in @table.graphRels
					if rel.owns
						if !rel.foreignKey
							table = if _.isFunction rel.table then rel.table @ else rel.table
							record = @table.db.table(table).byId @get rel.field
							if record
								if _.isFunction rel.owns
									if rel.owns record
										contained.push record
										if recursive
											contained = contained.concat record.contained()
								else
									contained.push record
									contained = contained.concat record.contained()
						else
							records = @table.db.table(rel.table).select (record) => record.get(rel.field) == @get 'id'

							for record in records
								contained.push record
								if recursive
									contained = contained.concat record.contained()
			contained

		owner: ->
			if @table.graphRels
				for rel in @table.graphRels
					if rel.owner
						if !rel.foreignKey
							table = if _.isFunction rel.table then rel.table @ else rel.table
							record = @table.db.table(table).byId @get rel.field
							return record if record
						else
							if rel.filter
								records = @table.db.table(rel.table).select (record) => record.get(rel.field) == @get('id') && rel.filter @, record
							else
								records = @table.db.table(rel.table).select (record) => record.get(rel.field) == @get 'id'

							return records[0] if records[0]
