define ['models/Product','models/ProductVariant', 'models/Composite', 'model/Table', 'model/Database', 'model/ModelManager', 'Site', 'model/ObservableArray', 'model/auxiliary/maintainOrder', 'model/HasManyRelationship', 'util'], (Product, ProductVariant, Composite, Table, Database, ModelManager, Site, ObservableArray, maintainOrder, HasManyRelationship, util) ->
	(background) ->
		map = (record) ->
			switch record.element_type
				when 'Product'
					'products'
				when 'ProductVariant'
					'product_variants'
				when 'Decision'
					'decisions'
				when 'Composite'
					'composites'
				when 'Bundle'
					'bundles'
				when 'Session'
					'sessions'
				when 'List'
					'lists'
				when 'Descriptor'
					'descriptors'
				when 'ObjectReference'
					'object_references'

		db = new Database
		db.schema = 1
		modelManager = new ModelManager db, background

		addElementType = (args) ->
			args.hasParent ?= true
			table = parentKey = parentTable = model = null
			if args.for
				lc = args.for.toLowerCase()
				table = "#{lc}_elements"
				parentKey = "#{lc}_id" if args.hasParent
				parentTable = "#{lc}s"
				model = "#{args.for}Element"

			table = args.table if args.table
			parentKey = args.parentKey if args.parentKey 
			parentTable = args.parentTable if args.parentTable
			model = args.model if args.model

			types = 
				element_id: 'id'
				element_type: 'string'
				index: 'int'
				creator_id:'id'

			types[parentKey] = 'id' if args.hasParent

			if args.types
				_.extend types, args.types

			referents = 
				element_id: map

			referents[parentKey] = parentTable if args.hasParent

			fields = []
			fields.push parentKey if args.hasParent

			graph =
				element_id:
					table: (record) -> map record._values
					owns: (record) -> !(record.table.name in ['products', 'product_variants'])

			if args.graph
				_.extend graph, args.graph

			if args.hasParent
				graph[parentKey] =
					table:parentTable
					owner:true

			db.addTable table,
				schema:
					fields: fields
					types: types
					referents: referents
					opts:
						element_id:reassignIdentical:true
						element_type:reassignIdentical:true

				graph:graph

			relationships = 
				element:
					type: 'hasOne'
					relKey: 'element_id'
					model: (instance) -> instance.get('element_type')

			if args.hasParent
				relationships.parent =
					type: 'hasOne'
					relKey: parentKey
					model: args.parentModel ? args.for

			modelManager.addModel model,
				orderBy: args.orderBy
				table: table
				relationships: relationships

		db.addTable 'users',
			schema:
				types:
					tutorial_step: 'int'
					user_colors:'string'
					tutorials: 'string'
					email: 'string'
					alerts_email: 'string'
				defaultValues:
					tutorial_step: 0

			onGraph:true

		db.addTable 'collaborators',
			schema:
				types:
					object:'string'
					object_user_id:'id'
					user_id:'id'
					active:'bool'
					# role:'string'
				defaultValues:
					active:false

		db.addTable 'products',
			schema:
				fields: ['image', 'title', 'price', 'reviews', 'sem3_id', 'coupons']
				local: ['sem3_id', 'coupons', 'inShoppingBar']
				types:
					inShoppingBar: 'object'
					more: 'object'
					offers: 'object'
					offer: 'object'
					retrievalId: 'string'
					rating: 'float'
					ratingCount: 'int'
					last_scraped_at: 'int'
					scraper_version:'string'
					status:'int'
					price:'string'
				defaultValues:
					purchased: false
				opts:
					more: reassignIdentical:true

			graph:
				canBeExternal:false

		db.addTable 'product_variants',
			schema:
				types:
					variant: 'object'
				referents:
					product_id: 'products'
				defaultValues:
					schema_version: 0
			graph:
				canBeExternal:false

		db.addTable 'product_watches',
			schema:
				local: ['listing', 'stock', 'used', 'new', 'refurbished', 'state']
				types:
					# product_id: 'id'
					watch_threshold: 'int'
					watch_increment: 'int'
					watch_condition: 'int'
					enable_threshold: 'bool'
					enable_stock: 'bool'
					enable_increment: 'bool'
					index: 'int'
					seen: 'bool'
					enabled: 'bool'
					state: 'int'

					reported_stock: 'int'
					reported_listing: 'int'
					reported_new: 'int'
					reported_used: 'int'
					reported_refurbished: 'int'
					initial_stock: 'int'
					initial_listing: 'int'
					initial_new: 'int'
					initial_used: 'int'
					initial_refurbished: 'int'
					stock: 'int'
					listing: 'int'
					new: 'int'
					used: 'int'
					refurbished: 'int'
					stock: 'int'

				defaultValues:
					enable_threshold: false
					enable_increment: false
					enable_stock: false
					watch_condition: 0
					enabled: true
				referents:
					product_id: 'products'
					
		db.addTable 'site_settings',
			schema:
				fields: ['site', 'enabled']
				types:
					enabled: 'int'

		db.addTable 'bundles',
			graph:
				root_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				bundle_elements: [
					{
						field: 'element_id'
						owner:true
						filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

					},
					{
						field: 'bundle_id'
						owns:true
					}
				]
				list_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				session_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				belt_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name



		db.addTable 'competitive_lists'

		db.addTable 'lists',
			schema:
				types:
					descriptor: 'object'
				defaultValues:
					collapsed: false

			graph:
				list_elements:
					field: 'list_id'
					owns:true

				decisions:
					field: 'list_id'
					owner:true

		db.addTable 'belts',
			schema:
				types:
					title: 'string'
					shared: 'bool'

				referents:
					user_id: 'users'

			graph:
				belt_elements:
					field:'belt_id'
					owns:true

		db.addTable 'composites'

		db.addTable 'composite_slots',
			schema:
				types:
					index: 'int'
					composite_id: 'id'
					element_id: 'id'
					element_type: 'string'
				referents:
					element_id: map
					composite_id: 'composites'
				opts:
					element_id: reassignIdentical:true

		db.addTable 'sessions',
			schema: 
				types:
					title: 'string'
				defaultValues:
					collapsed: false
			graph:
				session_elements:
					field: 'session_id'
					owns:true

				root_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				belt_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name


		db.addTable 'decisions',
			schema:
				referents:
					list_id: 'lists'
					# dismissal_list_id: 'lists'
				types:
					display_options: 'object'
					share_title: 'string'
					share_message: 'string'
					shared: 'bool'
					access: 'int'

				defaultValues:
					access: 0

				opts:
					display_options: reassignIdentical:true

			graph:
				list_id:
					table:'lists'
					owns:true

				decision_elements:
					field: 'decision_id'
					owns:true

				root_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				bundle_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				list_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				session_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				belt_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name


		db.addTable 'object_references',
			schema:
				types:
					object_user_id: 'id'
					object: 'string'

			graph:
				root_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				bundle_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				list_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				session_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name

				belt_elements:
					field: 'element_id'
					owner:true
					filter: (record, otherRecord) -> map(otherRecord._values) == record.table.name


		db.addTable 'decision_elements',
			schema:
				types:
					# selected: 'bool'
					row: 'int'
				defaultValues: 
					row: 0
					selected: false
					dismissed: false
				referents:
					decision_id: 'decisions'
					list_element_id: 'list_elements'

			graph:
				decision_id:
					table: 'decisions'
					owner:true

				# list_element_id:
				# 	table: 'list_elements'

		db.addTable 'data',
			schema:
				types:
					type: 'string'
					url: 'string'
					title: 'string'
					text: 'string'
					comment: 'string'
					element_type: 'string'
				referents:
					element_id: map

		db.addTable 'feelings',
			schema:
				types:
					positive: 'int'
					negative: 'int'
					thought: 'string'
					element_type: 'string'
					timestamp: 'datetime'
				referents:
					element_id: map
			graph:
				onGraph:true

		db.addTable 'arguments',
			schema:
				types:
					for: 'int'
					against: 'int'
					thought: 'string'
					element_type: 'string'
					timestamp: 'datetime'
				referents:
					element_id: map

		db.addTable 'descriptors',
			schema:
				types:
					descriptor: 'object'
					element_type: 'string'
				referents:
					element_id: map
				opts: element_id:reassignIdentical:true

		db.addTable 'shared_objects',
			schema:
				types:
					object: 'string'
					title: 'string'
					user_id: 'id'
					with_user_id: 'id'
					user_name: 'string'
					with_user_name: 'string'
					seen:'bool'


		db.addTable 'activity',
			schema:
				types:
					user_id:'id'
					generator_id:'id'
					timestamp:'int'
					type:'string'
					object_type:'string'
					object_id:'id'
					args:'object'

		addElementType
			for:'Root'
			# hasParent:false
			parentKey:'user_id'
			parentTable:'users'
			parentModel:'User'
			# for: 'User'
			# orderBy: field:'index', direction: 'asc'
			# types:
			# 	user_id:'id'
			# graph:
			# 	user_id:
			# 		table: 'users'
			# 		owner:true

		addElementType for:'Collection', hasParent:false, orderBy: field:'index', direction: 'asc'
		addElementType for:'Session'
		addElementType for:'Composite'
		addElementType for:'Bundle'
		addElementType for:'CompetitiveList', table: 'competitive_list_elements', parentKey: 'competitive_list_id', parentTable: 'competitive_lists'
		addElementType for:'List'
		addElementType for:'Belt'

		modelManager.defineModels
			User:
				table: 'users'
				relationships:
					belts:
						type: 'hasMany'
						model: 'Belt'
						foreignKey: 'user_id'
						# orderBy: field:'index', direction:'asc'

					rootElements:
						type: 'hasMany'
						model: 'RootElement'
						foreignKey: 'user_id'
						orderBy: field:'index', direction:'asc'

					sharedWithMe:
						type: 'hasMany'
						model: 'SharedObject'
						foreignKey: 'with_user_id'

					unseenSharedWithMe:
						type: 'hasMany'
						model: 'SharedObject'
						foreignKey: 'with_user_id'
						filter: (instance) ->
							!instance.get('seen')


			CompetitiveList:
				table: 'competitive_lists'
				relationships:
					elements:
						type: 'hasMany'
						model: 'CompetitiveListElement'
						foreignKey: 'competitive_list_id'
						orderBy: field:'index', direction: 'asc'

					contents:
						type: 'hasMany'
						through: 'competitive_list_elements'
						foreignKey: 'competitive_list_id'
						relKey: 'element_id'
						orderBy: field:'index', direction: 'asc'
						model: (record) -> record.get 'element_type'
						defaultValues: (instance) ->
							element_type: instance.model.name

			Belt:
				table: 'belts'
				relationships:
					elements:
						type: 'hasMany'
						model: 'BeltElement'
						foreignKey: 'belt_id'
						orderBy: field:'index', direction:'asc'

					contents:
						type: 'hasMany'
						through: 'belt_elements'
						foreignKey: 'belt_id'
						relKey: 'element_id'
						orderBy: field:'index', direction: 'asc'
						model: (record) -> record.get 'element_type'
						defaultValues: (instance) ->
							element_type: instance.model.name

			List:
				table: 'lists'
				relationships:
					elements:
						type: 'hasMany'
						model: 'ListElement'
						foreignKey: 'list_id'
						orderBy: field:'index', direction:'asc'

					contents:
						type: 'hasMany'
						through: 'list_elements'
						foreignKey: 'list_id'
						relKey: 'element_id'
						orderBy: field:'index', direction: 'asc'
						model: (record) -> record.get 'element_type'
						defaultValues: (instance) ->
							element_type: instance.model.name

			Decision:
				table: 'decisions'
				relationships:
					list:
						type: 'hasOne'
						relKey: 'list_id'
						model: 'List'

					listElements:
						type: 'hasMany'
						through: 'decision_elements'
						model: 'ListElement'
						foreignKey: 'decision_id'
						relKey: 'list_element_id'

					elements:
						type: 'hasMany'
						foreignKey: 'decision_id'
						model: 'DecisionElement'
						for: 
							path: 'list.elements'
							key: 'list_element_id'

					selection:
						type: 'hasMany'
						through: 'decision_elements'
						throughFilter: (record) -> record.get('selected')
						model: 'ListElement'
						foreignKey: 'decision_id'
						relKey: 'list_element_id'
						remove: (instance) ->
							@_instance.get('listElements').instanceForInstance(instance).set 'selected', false
						add: (instance) ->
							@_instance.get('listElements').add instance
							@_instance.get('listElements').instanceForInstance(instance).set 'selected', true

					dismissed:
						type: 'hasMany'
						through: 'decision_elements'
						throughFilter: (record) -> record.get('dismissed')
						model: 'ListElement'
						foreignKey: 'decision_id'
						relKey: 'list_element_id'

						remove: (instance) ->
							@_instance.get('listElements').instanceForInstance(instance).set 'dismissed', false
						add: (instance) ->
							@_instance.get('listElements').add instance
							@_instance.get('listElements').instanceForInstance(instance).set 'dismissed', true

					considering:
						type: 'hasMany'
						through: 'decision_elements'
						throughFilter: (record) -> !record.get('dismissed')
						model: 'ListElement'
						foreignKey: 'decision_id'
						relKey: 'list_element_id'

						remove: (instance) ->
							@_instance.get('listElements').instanceForInstance(instance).set 'dismissed', true
						add: (instance) ->
							@_instance.get('listElements').add instance
							@_instance.get('listElements').instanceForInstance(instance).set 'dismissed', false


			DecisionElement:
				table: 'decision_elements'
				relationships:
					element:
						type: 'hasOne'
						model: 'ListElement'
						relKey: 'list_element_id'
					decision:
						type: 'hasOne'
						model: 'Decision'
						relKey: 'decision_id'

			Bundle:
				table: 'bundles'
				relationships:
					elements:
						type: 'hasMany'
						model: 'BundleElement'
						foreignKey: 'bundle_id'
						orderBy: field:'index', direction: 'asc'

					contents:
						type: 'hasMany'
						through: 'bundle_elements'
						relKey: 'element_id'

						foreignKey: 'bundle_id'
						model: (record) -> record.get 'element_type'
						defaultValues: (instance) ->
							element_type: instance.model.name

						orderBy: field:'index', direction: 'asc'

			Descriptor:
				table:'descriptors'
				relationships:
					element:
						type: 'hasOne'
						relKey: 'element_id'
						model: (instance) -> instance.get('element_type')

			ObjectReference:
				table:'object_references'

			CompositeSlot:
				table:'composite_slots'
				relationships:
					element:
						type: 'hasOne'
						relKey: 'element_id'
						model: (instance) -> instance.get('element_type')

			Composite:
				class: Composite
				table: 'composites'
				relationships:
					slots: 
						type: 'hasMany'
						foreignKey: 'composite_id'
						model: 'CompositeSlot'
						orderBy: field:'index', direction: 'asc'

					additionalContents:
						type: 'hasMany'
						through: 'composite_elements'
						foreignKey: 'composite_id'
						relKey: 'element_id'
						model: (instance) -> instance.get('element_type')

						defaultValues: (instance) ->
							element_type: instance.model.name
						orderBy: field:'index', direction: 'asc'

					additionalElements:
						type: 'hasMany'
						# through: 'composite_elements'
						foreignKey: 'composite_id'
						# relKey: 'element_id'
						model: 'CompositeElement'
						# model: (record) -> record.get 'element_type'
						# defaultValues: (instance) ->
							# element_type: instance.model.name
						orderBy: field:'index', direction: 'asc'


					contents: (instance) ->
						list = new ObservableArray

						onInstance = (inst) ->
							inst.set('index', list.length())
							list.push inst
							maintainOrder field:'index', direction:'asc', inst, list

						for rel in ['slots', 'additionalElements']
							instance.get(rel).each onInstance

							instance.get(rel).observe (mutationInfo) ->
								if mutationInfo.type == 'insertion'
									onInstance mutationInfo.value
								else if mutationInfo.type == 'deletion'
									list.remove mutationInfo.value
									if list.length() > 1
										for i in [Math.min(instance.get('index'),list.length()-1)...list.length()]
											list.get(i).set 'index', i

						add: (inst) ->
							if inst.model.name == 'CompositeSlot'
								instance.get('slots').add inst
							else
								instance.get('additionalElements').add inst
						remove: (inst) ->
							if inst.model.name == 'CompositeSlot'
								instance.get('slots').remove inst
							else
								instance.get('additionalElements').remove inst
						instanceForInstance: (inst) ->
							if inst.model.name == 'CompositeSlot'
								instance.get('slots').instanceForInstance inst
							else
								instance.get('additionalElements').instanceForInstance inst

						observe: -> list.observe.apply list, arguments
						stopObserving: -> list.stopObserving.apply list, arguments
						each: -> list.each.apply list, arguments
						get: -> list.get.apply list, arguments

			Session:
				table: 'sessions'
				relationships:
					elements:
						type: 'hasMany'
						model: 'SessionElement'
						foreignKey: 'session_id'
						orderBy: field:'index', direction: 'asc'

					contents:
						type: 'hasMany'
						through: 'session_elements'
						foreignKey: 'session_id'
						relKey: 'element_id'
						orderBy: field:'index', direction: 'asc'

						model: (record) -> record.get 'element_type'
						defaultValues: (instance) ->
							element_type: instance.model.name

			Product:
				class: Product
				table: 'products'
				# fault:true
				properties: 
					url: -> "http://agora.sh/product/#{@_get('siteName')}/#{@get 'productSid'}"

						# if @_get('siteName') == 'General'
						# 	@_get 'productSid'
						# else
							# site = Site.site @_get('siteName')
							# site.productUrl @get 'productSid'

							# "http://#{background.domain}/product.php?site=#{site.config.slug}&id=#{@get 'productSid'}"

					currency: ->
						if @_get 'currency'
							@_get 'currency'
						else
							Site.site(@_get('siteName')).config.currency

					displayPrice: ->
						if @get('price') == @model.errorMap.price
							'(error)'
						else if @get('currency') == 'embedded'
							if @get('price') == ''
								'(none)'
							else
								@get('price')
						else
							if @get('price')? && @get 'currency'
								currencySymbolMap = 
									dollar: '$'
									euro: 'EUR '
								"#{currencySymbolMap[@get 'currency']}#{@get 'price'}"
							else
								@get 'price'

					displayUserPrice: ->
						if @get('currency') == 'embedded'
							if @get('userPrice') == ''
								'(none)'
							else
								@get('userPrice')
						else
							if @get('offer')
								currencySymbolMap = 
									dollar: '$'
									euro: 'EUR '

								price = parseFloat(@get('offer').price).toFixed(2)
								price = util.numberWithCommas price

								"#{currencySymbolMap[@get 'currency']}#{price}"

					siteUrl: ->
						if @_get('siteName') == 'General'
							@_get('productSid').split('/').slice(0, 3).join('/')
						else
							Site.site(@_get('siteName')).url

					siteName: ->
						if @_get('siteName') == 'General'
							name = @_get('productSid').split('/')[2]
							if /^www\./.exec name
								name = name.substr 4
							name
						else
							@_get('siteName')
				relationships:
					data:
						type: 'hasMany'
						model: 'Datum'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'Product'

					feelings:
						type: 'hasMany'
						model: 'Feeling'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'Product'

					arguments:
						type: 'hasMany'
						model: 'Argument'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'Product'

					lists:
						type: 'hasMany'
						through: 'list_elements'
						model: 'List'
						relKey: 'list_id'
						foreignKey: 'element_id'
						throughFilter: (record) -> record.get('element_type') == 'Product'

					bundles:
						type: 'hasMany'
						through: 'bundle_elements'
						model: 'Bundle'
						relKey: 'bundle_id'
						foreignKey: 'element_id'
						throughFilter: (record) -> record.get('element_type') == 'Product'

					variants:
						type: 'hasMany'
						model: 'ProductVariant'
						foreignKey: 'product_id'

					root:
						type: 'hasMany'
						model: 'RootElement'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'Product'

			ProductVariant:
				class: ProductVariant
				table: 'product_variants'
				relationships:
					product:
						type: 'hasOne'
						relKey: 'product_id'
						model: 'Product'

					data:
						type: 'hasMany'
						model: 'Datum'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'ProductVariant'

					feelings:
						type: 'hasMany'
						model: 'Feeling'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'ProductVariant'

					arguments:
						type: 'hasMany'
						model: 'Argument'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'ProductVariant'

					lists:
						type: 'hasMany'
						through: 'list_elements'
						model: 'List'
						relKey: 'list_id'
						foreignKey: 'element_id'
						throughFilter: (record) -> record.get('element_type') == 'ProductVariant'

					bundles:
						type: 'hasMany'
						through: 'bundle_elements'
						model: 'Bundle'
						relKey: 'bundle_id'
						foreignKey: 'element_id'
						throughFilter: (record) -> record.get('element_type') == 'ProductVariant'

					root:
						type: 'hasMany'
						model: 'RootElement'
						foreignKey: 'element_id'
						filter: (record) -> record.get('element_type') == 'ProductVariant'

			ProductWatch:
				table: 'product_watches'
				orderBy: field:'index', direction:'asc'
				relationships:
					product:
						type: 'hasOne'
						relKey: 'product_id'
						model: 'Product'


			Datum:
				table: 'data'
				relationships:
					element:
						type: 'hasOne'
						relKey: 'element_id'
						model: (instance) -> instance.get('element_type')

			Feeling:
				table: 'feelings'
				relationships:
					element:
						type: 'hasOne'
						relKey: 'element_id'
						model: (instance) -> instance.get('element_type')

			Argument:
				table: 'arguments'
				relationships:
					element:
						type: 'hasOne'
						relKey: 'element_id'
						model: (instance) -> instance.get('element_type')

			SharedObject:
				table: 'shared_objects'


		isObjectInShoppingBar = (obj) ->
			if beltElements = modelManager.getModel('BeltElement').findAll(element_type:obj.modelName, element_id:obj.get 'id')
				if beltElements.length
					response = {}
					for beltElement in beltElements
						response[beltElement.get('parent').get 'user_id'] = true
					return response

			listElements = modelManager.getModel('ListElement').findAll element_type:obj.modelName, element_id:obj.get 'id'
			for listElement in listElements
				decision = modelManager.getModel('Decision').find list_id:listElement.get('list_id')
				if decision
					if response = isObjectInShoppingBar decision
						return response

			bundleElements = modelManager.getModel('BundleElement').findAll element_type:obj.modelName, element_id:obj.get 'id'
			for bundleElement in bundleElements
				if response = isObjectInShoppingBar bundleElement.get 'parent'
					return response
			false

		isProductInShoppingBar = (product) ->
			if beltElements = modelManager.getModel('BeltElement').findAll(element_type:'Product', element_id:product.get 'id')
				if beltElements.length
					response = {}
					for beltElement in beltElements
						response[beltElement.get('parent').get 'user_id'] = true
					return response

			for i in [0...product.get('lists').length()]
				list = product.get('lists').get i
				decision = modelManager.getModel('Decision').find list_id:list.get('id')
				if decision
					if response = isObjectInShoppingBar decision
						return response

			for i in [0...product.get('bundles').length()]
				bundle = product.get('bundles').get i
				if response = isObjectInShoppingBar bundle
					return response

			for i in [0...product.get('variants').length()]
				if response = isObjectInShoppingBar product.get('variants').get i
					return response
			false

		forProducts = (element, cb) ->
			if element.get('element_type') == 'Product'
				cb element.get('element')
			else if element.get('element_type') == 'ProductVariant'
				cb modelManager.getModel('Product').withId element.get('element').get 'product_id'
			else if element.get('element_type') == 'Decision'
				element.get('element').get('list').get('elements').each (element) -> forProducts element, cb
			else if element.get('element_type') == 'Bundle'
				element.get('element').get('elements').each (element) -> forProducts element, cb

		modelManager.getModel('ListElement').events.onCreate.subscribe (instance) ->
			forProducts instance, (product) ->
				product.set 'inShoppingBar', isProductInShoppingBar product

		modelManager.getModel('ListElement').events.onRemove.subscribe (instance) ->
			forProducts instance, (product) ->
				product.set 'inShoppingBar', isProductInShoppingBar product

		modelManager.getModel('BundleElement').events.onCreate.subscribe (instance) ->
			forProducts instance, (product) ->
				product.set 'inShoppingBar', isProductInShoppingBar product

		modelManager.getModel('BundleElement').events.onRemove.subscribe (instance) ->
			forProducts instance, (product) ->
				product.set 'inShoppingBar', isProductInShoppingBar product

		modelManager.getModel('BeltElement').events.onCreate.subscribe (instance) ->
			forProducts instance, (product) ->
				product.set 'inShoppingBar', isProductInShoppingBar product

		modelManager.getModel('BeltElement').events.onRemove.subscribe (instance) ->
			forProducts instance, (product) ->
				product.set 'inShoppingBar', isProductInShoppingBar product

		db:db, modelManager:modelManager
