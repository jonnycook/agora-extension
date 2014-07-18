define ['underscore', 'clientInterface/ClientObject', 'clientInterface/ClientArray', 'clientInterface/ClientValue', 'util'], (_, ClientObject, ClientArray, ClientValue, util) ->
	class ClientView
		constructor: (@agora, @id) ->
			{parent:parent} = View.clientViews[@id]
			@parent = View.clientViews[parent].view if parent

		callMethod: (name, args) ->
			@agora.background.triggerContentScriptEvent "ViewMethod:#{@id}", name:name, params:args
			
	class Context
		constructor: (@parent) ->
			@observerObjectPairs = []
			@contexts = []
			@clientObjects = []

		addClientObject: (clientObject) ->
			@clientObjects.push clientObject
			clientObject

		onContextDestruct: (context) ->
			index = @contexts.indexOf context
			if index != -1
				@contexts.splice index, 1
				if context.name
					delete @namedContexts[name]

		context: (name=null) ->
			if name
				@namedContexts ?= {}
				unless @namedContexts[name]
					@namedContexts[name] = @context()
					@namedContexts[name].name = name
				@namedContexts[name]

			else
				ctx = new Context @
				ctx.view = @view
				@contexts.push ctx
				ctx
			
		observe: (object, observer) ->
			object.observe observer, @
			@observerObjectPairs.push object:object, observer:observer

		observeObject: (object, observer) -> @observe object, observer


		stopObserving: (object) ->
			for i in [@observerObjectPairs.length-1..0]
				if @observerObjectPairs[i].object == object
					@observerObjectPairs[i].object.stopObserving @observerObjectPairs[i].observer
					@observerObjectPairs.splice i, 1

		clear: ->
			for ctx in @contexts
				ctx.parent = null
				ctx.destruct()
			@contexts = []

			clientObject.destruct() for clientObject in @clientObjects
			@clientObjects = []

			for {object:object, observer:observer} in @observerObjectPairs
				object.stopObserving observer
			@observerObjectPairs = []

		destruct: ->
			@parent?.onContextDestruct? @
			@onDestruct?()
			@clear()

		clientArray: (array, func) ->
			ca = new ClientArray @view.agora, @
			@addClientObject ca
			View.clientObjects[ca._id] = ca
			if arguments.length == 2
				util.syncArrays @, array, ca, (obj, onRemove) =>
					ctx = null
					getCtx = => ctx ?= @context()
					otherOnRemove = null
					onRemove ->
						ctx?.destruct()
					func obj, ((func) -> otherOnRemove = func), getCtx
			ca

		clientValue: ->
			cv = null
			if arguments.length >= 1
				if arguments[0]?.observe
					obj = arguments[0]

					if typeof arguments[1] == 'function'
						map = arguments[1]
						cv = new ClientValue @view.agora, @, map obj.get()
						@observe obj, => cv.set map obj.get()
					else
						cv = new ClientValue @view.agora, @, obj.get()
						@observe obj, => cv.set obj.get()
				else
					cv = new ClientValue @view.agora, @, arguments[0]
			else
				cv = new ClientValue @view.agora, @

			
			@addClientObject cv
			View.clientObjects[cv._id] = cv
			cv

		bind: (cv, obj, map=null) ->
			if map
				cv.set map obj.get()
				@observe obj, => cv.set map obj.get()
			else
				cv.set obj.get()
				@observe obj, => cv.set obj.get()

		clientValueNamed: (name, value) ->
			clientValue = @clientValue.apply @, Array.prototype.slice.call arguments, 1
			clientValue._name = name
			clientValue

		clientArrayNamed: (name) ->
			clientArray = @clientArray.apply @, Array.prototype.slice.call arguments, 1
			clientArray._name = name
			clientArray

	class View
		@nextViewId: 1
		@views: {}
		@clientViews: {}
		@clientObjects: {}
		@clientIdsByTab: {}
		# @deletedClientViews: {}

		@ClientObject: ClientObject

		@clear: ->
			@nextViewId = 1
			@views = {}
			@clientViews = {}
			@clientObjects = {}
			
		@createClientView: (tabId, type) ->
			id = @nextViewId++
			@clientViews[id] = 
				viewName:type

			@clientIdsByTab[tabId] ?= []
			@clientIdsByTab[tabId].push id
			id
		
		@connect: (agora, clientViewId, args, cb) ->
			{viewName:viewName} = @clientViews[clientViewId]
			@get agora, viewName, args, (view) =>
				if @clientViews[clientViewId]
					@clientViews[clientViewId].id = view.id
					@clientViews[clientViewId].view = view
					view.addClientView clientViewId
					view.getData (data) => cb true, @serializeObject data
				else
					cb false
					# Debug.error "no clientView #{clientViewId}"
					# throw new Error "no clientView #{clientViewId}"
				
		@deleteClientViewsInTab: (tabId) ->
			clientViews = @clientIdsByTab[tabId]
			if clientViews
				for clientId in clientViews
					@remove clientId
			delete @clientIdsByTab[tabId]

		@remove: (clientViewId) ->
			if @clientViews[clientViewId]
				#Debug.log "Deleting view #{clientViewId} #{@clientViews[clientViewId].viewName}"
				if @clientViews[clientViewId].view
					@clientViews[clientViewId].view.removeClientView clientViewId
					@clientViews[clientViewId].view.onClientDisconnect? clientViewId
				delete @clientViews[clientViewId]
		
		@getViewClass: (viewName, cb) ->
			@agora.background.require ["views/#{viewName}View"], (viewClass) ->
				viewClass.agora = @agora
				cb viewClass

		@get: (agora, viewName, args, cb) ->
			@getViewClass viewName, (viewClass) =>
				view = null
				
				doGet = (args) =>				
					# todo: method shouldn't be called "id"
					if viewClass.id
						id = viewClass.id args
					else
						id = null
	
					unless view = @views[viewName]?[id]
						view = new viewClass viewName, id, agora, args
						
						if @views[viewName]
							@views[viewName][id] = view
						else
							@views[viewName] = {}
							@views[viewName][id] = view

					view.whenReady -> 
						cb view
				
				if viewClass.filter
					viewClass.filter agora, args, doGet
				else
					doGet args
		
		@getWithClientId: (clientViewId, cb) ->
			{id:id, viewName:viewName} = @clientViews[clientViewId]
			view = @views[viewName][id]
			cb view
		
		@callMethod: (clientViewId, methodName, args, timestamp) ->
			{id:id, viewName:viewName} = @clientViews[clientViewId]
			Debug.log 'callMethod', viewName, clientViewId, methodName, args

			view = @views[viewName][id]
			view.callMethod clientViewId, methodName, args, timestamp
			
		@serializeObject: (obj) -> ClientObject.serialize obj


		@getClientObjects: (ids) ->
			response = {}
			for id in ids
				clientObject = ClientObject._registry[id]
				if clientObject == false
					console.log '%s has been deleted', id
				else
					response[id] = clientObject.serialize()
			response

		constructor: (@name, @id, @agora, @args) ->
			@background = @agora.background

			@ctx = @context()
			if @init
				@init args
			else if @initAsync
				@waiting = true
				@initAsync args, =>
					@waiting = false
					cb() for cb in @readyCbs if @readyCbs


		destruct: ->
			if !@destructed
				ctx.destruct() for ctx in @contexts if @contexts
				delete View.views[@name][@id]
				if _.isEmpty View.views[@name]
					delete View.views[@name]

				@destructed = true

		context: -> 
			@contexts ?= []
			context = new Context
			context.view = @
			@contexts.push context
			context
		
		clientArray: (ctx, array, func) ->
			ctx.clientArray array, func

		clientValue: (value, func) -> 
			@ctx.clientValue value, func

		clientValueNamed: (name, value, func) ->
			@ctx.clientValueNamed name, value, func

		clientArrayNamed: (name) ->
			@ctx.clientArrayNamed.apply @ctx, arguments
		
		getData: (cb) -> cb @data
		
		observeObject: (observable, observer) ->
			@ctx.observe observable, observer

		stopObservingObject: (observable) ->
			@ctx.stopObserving observable

		addClientView: (id) ->
			@clientViews ?= []
			@clientViews.push id

		removeClientView: (id) ->
			_.pull @clientViews, id
			if !@clientViews.length
				@destruct()

		whenReady: (cb) ->
			if @waiting
				@readyCbs ?= []
				@readyCbs.push cb
			else
				cb()

		hasMethod: (name) ->
			@methods?[name]

		method: (name) ->
			@methods[name]

		callMethod: (clientViewId, name, args, timestamp, cb) ->
			if @hasMethod name
				view = new ClientView @agora, clientViewId
				view.methodTimestamp = timestamp
				@clientView = view
				@method(name).apply @, [view].concat args
				delete @clientView
			else
				console.debug "View '#{@name}' has no method '#{name}'"
				throw new Error "View '#{@name}' has no method '#{name}'"

		resolveObject: (input, cb) ->
			if !input
				cb()

			else if input.modelName && input.instanceId
				cb @agora.modelManager.getInstance(input.modelName, input.instanceId)
			else if input.elementType && input.elementId 
				element = @agora.modelManager.getInstance(input.elementType, input.elementId)
				obj = element.get('element')
				cb obj, element
			else
				@agora.product input, cb

		resolveElements: (args...) ->
			cb = elements = null
			if typeof args[args.length - 1] == 'function'
				cb = args[args.length - 1]
				elements = args.slice 0, args.length - 1
			else
				elements = args

			results = []
			count = 0
			for elementData,i in elements
				if typeof elementData == 'number'
					results[i] = @agora.modelManager.instance 'Product', elementData
				else if elementData.action == 'new'
					switch elementData.type
						when 'computer'
							results[i] = @agora.modelManager.getModel('Composite').createWithType 'computer'

						when 'decision'
							list = @agora.modelManager.getModel('List').create()
							decision = @agora.modelManager.getModel('Decision').create()
							decision.set 'list_id', list.get 'id'
							results[i] = decision

						when 'list'
							results[i] = @agora.modelManager.getModel('List').create collapsed:true

						when 'bundle'
							results[i] = @agora.modelManager.getModel('Bundle').create()

						when 'session'
							results[i] = @agora.modelManager.getModel('Session').create()

						when 'descriptor'
							results[i] = @agora.modelManager.getModel('Descriptor').create descriptor:elementData.descriptor


				else if elementData.action == 'addData'
					datum = @agora.modelManager.getModel('Datum').create elementData.data
					results[i] = datum
				else if ((elementData.elementType == 'Product' && !elementData.elementId?) || (elementData.siteName && elementData.productSid)) && cb
					count++
					do (i) =>
						@agora.modelManager.getModel('Product').get elementData, (product) ->
							if elementData.variant
								for j in [0...product.get('variants').length()]
									if _.isEqual elementData.variant, product.get('variants').get(j).get('variant')
										results[i] = product.get('variants').get(j)
										break
								if !results[i]
									results[i] = @agora.modelManager.getModel('ProductVariant').create product_id:product.get('id'), variant:elementData.variant
							else
								results[i] = product
							unless --count || i < elements.length - 1
								cb.apply window, results
								cb = null
				else if elementData.view
					results[i] = @agora.View.clientViews[elementData.view].view
				else if elementData.elementType && elementData.elementId
					results[i] = @agora.modelManager.getInstance elementData.elementType, elementData.elementId

			(cb.apply window, results unless count) if cb

			results
