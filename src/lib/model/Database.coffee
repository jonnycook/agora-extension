define ['./Event', './Table'], (Event, Table) ->
	class Database
		constructor: ->
			@tables = {}
			@localToGlobalMapping = {}
			@globalToLocalMapping = {}

			@events =
				onBeforeExecuteChanges: new Event
				onAfterExecuteChanges: new Event
			
		addTable: ->
			if typeof arguments[0] == 'string'
				@addTable new Table arguments[0], arguments[1]
			else
				table = arguments[0]
				table.db = @
				@tables[table.name] = table
			
		table: (name) -> 
			table = @tables[name]
			throw new Error "table `#{name}` not found" unless table
			table

		addMapping: (mapping) ->
			for table,map of mapping
				@localToGlobalMapping[table] ?= {}
				@globalToLocalMapping[table] ?= {}
				
				for localId, globalId of map
					@localToGlobalMapping[table][localId] = globalId
					@globalToLocalMapping[table][globalId] = localId

		executeChanges: (allChanges, source) ->
			@events.onBeforeExecuteChanges.fire()
			for name,changes of allChanges
				@table(name).executeChanges changes, source
			@events.onAfterExecuteChanges.fire()

		clear: ->
			@localToGlobalMapping = {}
			@globalToLocalMapping = {}
			for name,table of @tables
				table.clear()

		data: ->
			tables = {}
			for name,table of @tables
				records = {}
				table.records.each (record) ->
					records[record.get 'id'] = record._values
				tables[name] = records
			tables

		setData: (data) ->
			for name,table of data
				maxId = 0
				for id,record of table
					id = parseInt(id)
					if id > maxId
						maxId = id
				@tables[name].rid = maxId + 1

			@executeChanges data
