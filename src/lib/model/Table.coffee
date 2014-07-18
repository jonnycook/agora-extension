define ['./ObservableArray', './ObservableObject', './Record', 'underscore', 'util'], (ObservableArray, ObservableObject, Record, _, util) ->
	class Table
		constructor: (@name, args) ->
			{schema:@schema, contents:contents} = args if args
			@records = new ObservableArray
			@records.name = "Table::#{@name}"
			@addRecord record for record in contents if contents
			
			@mappings = {}
			
			@rid = 1
			@_recordsByRid = {}

			@schema ?= {}
			@schema.fields ?= []
			@schema.types ?= {}
			@schema.defaultValues ?= {}

			@records.observe (mutation) =>
				if mutation.type == 'deletion'
					delete @_recordsByRid[mutation.value.get('id')]

			if args?.graph
				@onGraph = true
				@graphRoot = args.graph.root
				@graphRels = rels = []

				for name, rel of args.graph
					if !_.isArray rel
						rel = [rel]

					for r in rel
						if r.table
							rels.push
								table:r.table
								owns:r.owns
								owner:r.owner
								field:name
								filter:r.filter
						else if r.field
							rels.push
								foreignKey:true
								field:r.field
								table:name
								owns:r.owns
								owner:r.owner
								filter:r.filter

			else
				@onGraph = args?.onGraph

			@canBeExternal = args?.graph?.canBeExternal ? true

			if @schema
				@schema.fields ?= []

				if @schema.referents
					for field,referent of @schema.referents
						if !@schema?.types?[field]
							@schema.types ?= {}
							@schema.types[field] = 'id'

				if @schema.autoIncrement
					@schema.types ?= {}
					@schema.types[@schema.autoIncrement] = 'int'

				if @schema.defaultValues
					for fieldName, value of @schema.defaultValues
						@schema.fields.push fieldName unless fieldName in @schema.fields

						if !@schema.types || !(fieldName of @schema.types)
							@schema.types ?= {}
							@schema.types[fieldName] = if _.isBoolean value
								'bool'
							else if _.isString value
								'string'
							else if _.isNumber value
								if value % 1 == 0
									'int'
								else
									'float'
							else
								throw new Error "invalid default value"


				if @schema.types
					for fieldName, type of @schema.types
						@schema.fields.push fieldName unless fieldName in @schema.fields
							
						switch type
							when 'object'
								@mappings[fieldName] = (value) -> 
									if _.isString value
										JSON.parse value
									else
										value
							when 'datetime'
								@mappings[fieldName] = (value) -> 
									if _.isString value
										Date.parse value
									else
										value
							when 'bool'
								@mappings[fieldName] = (value) -> 
									if _.isBoolean value
										value
									else if _.isString value
										if value == 'true'
											true
										else if value == 'false'
											false
										else
										 !!parseInt value

									else if _.isNumber
										!!value
							when 'int'
								@mappings[fieldName] = (value) ->
									if _.isString value
										value = value.replace /,/g, ''
									parseInt value
							when 'float'
								@mappings[fieldName] = (value) -> parseFloat value
							when 'id'
								@mappings[fieldName] = (value) ->
									if typeof value == 'string' && value[0] == 'G'
										value
									else
										parseInt value

		clear: ->
			@delete -> 1
			@_recordsByRid = {}
			
		executeChanges: (changes, source) ->
			for rid,recordChanges of changes
				rid = @db.globalToLocalMapping?[@name]?[rid] ? rid
				if recordChanges == 'deleted'
					@records.deleteIf (record) -> `record.id == rid`
					# delete @_recordsByRid[rid]
				else
					for key,value of recordChanges
						if referentTable = @schema?.referents?[key]
							if _.isFunction referentTable
								referentTable = referentTable recordChanges
							recordChanges[key] = @db.globalToLocalMapping[referentTable]?[value] ? value

					record = @_recordsByRid[rid]
					if record
						#Debug.log 'updating', @name, rid, recordChanges
						for key,value of recordChanges
							if record.get(key) != value
								record.set key, value
					else
						# console.log 'adding', @name, rid, recordChanges
						@_addRecord recordChanges, rid

		serialize: ->
			table =
				rid:@rid
				records:{}
				
			@records.each (record) ->
				table.records[record.id] = record.serialize()
			table
			
		_nextAutoIncrement: ->
			if !@_autoIncrement
				@_autoIncrement = 1
			else
				++@_autoIncrement
		
		_addRecord: (data, rid) ->
			if @schema						
				(data[field] = null unless field of data) for field in @schema.fields if @schema.fields
				(data[field] = null unless field of data) for field,type of @schema.types if @schema.types

			record = new Record rid, data, @mappings, @
			@records.push record
			@_recordsByRid[record.id] = record
			record
		
		addRecord: (data) ->
			if @schema
				if @schema.autoIncrement
					if !data[@schema.autoIncrement]
						data[@schema.autoIncrement] = @_nextAutoIncrement()
					else
						data[@schema.autoIncrement] = parseInt(data[@schema.autoIncrement])
						if @_autoIncrement < data[@schema.autoIncrement] || !@_autoIncrement
							@_autoIncrement = data[@schema.autoIncrement]		

				if @schema.defaultValues
					for fieldName,value of @schema.defaultValues
						data[fieldName] = value unless fieldName of data		
						
				(data[field] = null unless field of data) for field in @schema.fields if @schema.fields

			@_addRecord data, @rid++

		insert: (data) -> @addRecord data
			
			
		select: (query) ->
			results = []
			@records.each (record) =>
				results.push record if query record
			results

		selectFirst: (query) ->
			util.find @records, query
		
		delete: (predicate) ->
			# console.log predicate
			@records.deleteIf (record) -> predicate record

		observe: (observer) ->
			observeField = (record, field) ->
				record.field(field).observe (mutation) ->
					# updater.addUpdate record, field
					observer type:'update', record:record, field:field
			
			observeRecord = (record) =>
				if record.table.schema.fields
					for field in record.table.schema.fields
						observeField record, field
			
			@records.each observeRecord
			
			@records.observe (mutation) ->
				if mutation.type == 'insertion'
					# updater.addInsertion mutation.value
					observer type:'insertion', record:mutation.value
					observeRecord mutation.value
				else if mutation.type == 'deletion'
					# updater.addDeletion mutation.value
					observer type:'deletion', record:mutation.value

		byId: (id) -> @_recordsByRid[id]

		byGlobalId: (id) ->
			@byId @db.globalToLocalMapping?[@name]?[id] ? id

		bySaneId: (id) ->
			@byGlobalId "G#{id}"

