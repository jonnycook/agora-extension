define ->
	interfaces = {}
	inputs = {}

	onModified = null
	resolveInput = (data) ->
		input = if typeof data == 'string'
			type:data
		else
			data

	createInput = (input, binding, element) ->
		el = inputs[input.type] input, binding, element
		# el.addClass input.type
		el


	class DataInterface
		constructor: (@data) ->

		binding: (field) -> new DataBinding @data, field

		setUIData: (data) ->
			@data['.ui'] = data

		get: -> @data

	class ArrayElementInterface
		constructor: (@arrayInterface, @index) ->
			@array = @arrayInterface.get()
			@array.observers ?= []
			@array.observers.push @

			@dataInterface = new DataInterface @array[@index]

		delete: ->
			for observer in @array.observers
				if observer != @
					observer.deleted @index

			@array.splice @index, 1
			_.pull @array.observers, @
			onModified?()

		deleted: (index) ->
			if @index > index
				-- @index

		binding: (field) -> @dataInterface.binding field

		setUIData: (data) ->
			@dataInterface.setUIData data

		get: -> @dataInterface.get()

		set: (value) ->
			@array[@index] = value
			onModified?()

	class ObjectElementInterface
		constructor: (@object, @key) ->
			@dataInterface = new DataInterface @object[@key]

		binding: (field) -> @dataInterface.binding field

		delete: ->
			delete @object[@key]
			onModified?()

		changeKey: (key) ->
			console.debug key
			@object[key] = @object[@key]
			delete @object[@key]
			@key = key
			onModified?()

		setUIData: (data) ->
			@dataInterface.setUIData data

		get: -> @dataInterface.get()

		set: (value) ->
			@object[@key] = value
			onModified?()

	class DataBinding
		constructor: (@data, @field) ->
			if !@data
				throw new Error 'bad'
			if @field && @data && !@field of @data
				throw new Error 'error'

		setUIData: (data) ->
			@uiData = data
			@updateUIData()

		updateUIData: ->
			if @get()
				@get()['.ui'] = @uiData


		get: -> 
			if @data && @field
				fieldParts = @field.split '.'
				obj = @data
				if obj
					for part in fieldParts
						obj = obj[part]
						return null unless obj
				obj
			else
				null

		set: (value) ->
			if @data && @field
				fieldParts = @field.split '.'
				obj = @data

				for part,i in fieldParts
					if i == fieldParts.length - 1
						obj[part] = value
					else
						obj[part] ?= {}
						obj = obj[part]
			
			@updateUIData()

			onModified?()

		binding: (field) -> 
			v = @get()
			if v == null || v == undefined
				@set {}
			else if !_.isPlainObject v
			 throw new Error 'invalid type'

			new DataBinding @get(), field


		push: (value) ->
			v = @get()
			if v == null || v == undefined
				@set([])
				@get().push value
			else if _.isArray v
				v.push value
			else
				console.debug v
				throw new Error 'invalid type'
			@updateUIData()
			onModified?()


		setKey: (key, value) ->
			v = @get()
			if v == null || v == undefined
				@set {}
				@get()[key] = value
			else if _.isPlainObject v
				v[key] = value
			else
				console.debug v
				throw new Error 'invalid type'
			@updateUIData()
			onModified?()


	stripUIData = (data) ->
		if data != null && data != undefined
			newData = _.clone data
			if newData['.ui']
				delete newData['.ui']
			if _.isArray newData
				for value,i in newData
					newData[i] = stripUIData value
			else if _.isPlainObject newData
				for key,value of newData
					if value == '' || value == null || value == undefined
						delete newData[key]
					else
						newData[key] = stripUIData value
			newData


	DataInterface: DataInterface
	setInputs: (obj) ->
		inputs = obj
	setInterfaces: (obj) ->
		interfaces = obj
	setOnModified: (func) -> onModified = func
	stripUIData: stripUIData
	createInterface: createInterface = (interfaceName, dataInterface, element) ->
		iface = _.clone interfaces[interfaceName]
		iface.type ?= 'form'

		el = $('<div class="interface" />').addClass(iface.type).addClass interfaceName

		actionsContEl = $('<div class="actions"><button class="copy">Copy</button><button class="paste">Paste</button></div>').appendTo el

		actionsContEl.find('.copy').click ->
			window.copyBuffer = stripUIData dataInterface.get()

		actionsContEl.find('.paste').click ->
			dataInterface.set window.copyBuffer
			resetInterface()

		if element
			el.append "<span class='name'><button class='toggle'>Toggle</button> #{interfaceName} (#{element?.bind})</span>"
		else
			el.append "<span class='name'><button class='toggle'>Toggle</button> #{interfaceName}</span>"
		el.find('.name .toggle').click -> el.toggleClass 'minimized'
		dataInterface.setUIData
			el:el

		switch iface.type
			when 'form'
				if iface.elements
					for element in iface.elements
						if element.interface
							el.append createInterface element.interface, dataInterface.binding(element.bind), element
						else if element.input
							input = resolveInput element.input

							el.append $('<div class="field" />').addClass(input.type).addClass(element.bind).append createInput input, dataInterface.binding(element.bind), element
			when 'list'
				listEl = $('<ul />').appendTo el

				addEl = (elementType, arrayDataInterface) -> 
					listEl.append(
						li = $('<li />')
							.append createInterface elementType, arrayDataInterface
							.append $('<button class="delete">X</button>').click ->
								arrayDataInterface.delete()
								li.slideUp -> li.remove()
					)

				if dataInterface.get()
					for data,i in dataInterface.get()
						elementType = if iface.map then iface.map data else iface.elementType
						addEl elementType, new ArrayElementInterface dataInterface, i

				if iface.elementType
					el.children('.name').append $('<button class="add">Add</button>').click ->
						obj = {}
						iface.initObj? obj, iface.elementType
						dataInterface.push obj
						addEl iface.elementType, new ArrayElementInterface dataInterface, dataInterface.get().length - 1

				else if iface.elementTypes
					selectEl = $('<select />')
					for elementType in iface.elementTypes
						selectEl.append $("<option>#{elementType}</option>")

					$('<div class="add" />')
						.appendTo el.children('.name')
						.append selectEl
						.append $('<button class="add">Add</button>').click ->
							obj = {}
							iface.initObj? obj, selectEl.val(),
							dataInterface.push obj
							addEl selectEl.val(), new ArrayElementInterface dataInterface, dataInterface.get().length - 1

			when 'dictionary'
				dictionaryEl = $('<ul />').appendTo el
				addEl = (key) ->
					objectDataInterface = new ObjectElementInterface dataInterface.get(), key
					liEl = $('<li />')
					liEl.append(
						$('<input type="text" />')
							.val key
							.change ->
								objectDataInterface.changeKey $(@).val()
					)
						
					liEl.append createInterface iface.valueInterface, objectDataInterface
					liEl.append $('<button class="delete">X</button>').click ->
							liEl.slideUp -> liEl.remove()
							objectDataInterface.delete()


					dictionaryEl.append liEl

				for key,value of dataInterface.get()
					continue if key == '.ui'
					addEl key

				keyEl = $('<input type="text">')
				$('<div class="add" />')
					.appendTo el.children('.name')
					.append keyEl
					.append $('<button>Add</button>').click ->
						key = keyEl.val()
						dataInterface.setKey key, {}
						addEl key

		iface.init? el, dataInterface
		el
