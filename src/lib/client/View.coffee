define -> ->
	class ClientObject
		constructor: (@args) ->
			{_id:@_id, contentScript:@contentScript, _name:@_name, view:@view} = @args
			# @view = args.view
			@listener = (data) =>
				data = _.clone data

				eventType = data.event
				delete data.event
				switch eventType
					when 'mutation'
						@onMutation? data
						observer data for observer in @observers if @observers
					when 'disconnection'
						@clearObservers()
			
			@contentScript.mapEvent "ClientObjectEvent:#{@_id}", @_name
			@contentScript.listen "ClientObjectEvent:#{@_id}", @listener, @args.view
			# @contentScript.triggerBackgroundEvent "ClientObjectUpdate", @_id

		observe: (cb, tag) ->
			throw new Error 'Null observer' if !cb
			@observers ?= []
			@observers.push cb
			@tags ?= []
			@tags.push tag
			
			# if @observers.length == 1
				
		stopObserving: (observer) ->
			if @observers
				index = @observers.indexOf observer
				if index != -1
					@observers.splice index, 1
				
				# unless @observers.length
				# 	@contentScript.stopListening "ClientObjectEvent:#{@_id}", @listener

		clearObservers: ->
			@observers = null
			@tags = null
			# @contentScript.stopListening "ClientObjectEvent:#{@_id}", @listener

		clearObjs: (removeFromView=true) ->
			if @objs
				obj.destruct removeFromView for obj in @objs
				delete @objs

		destruct: (removeFromView=true) ->
			@clearObservers()
			if removeFromView && @view
				@view.clientObjects.splice @view.clientObjects.indexOf(@), 1

			@clearObjs removeFromView
			@contentScript.stopListening "ClientObjectEvent:#{@_id}", @listener, @

		setObjs: (objs) ->
			@objs = objs

		deserialize: (data, objs) ->
			if @view
				@view.deserialize data, objs
			else
				deserialize data,
					{
						ClientArray: ClientArray
						ClientValue: ClientValue
					}
					{contentScript: @contentScript}
					null
					objs



	class ClientArray extends ClientObject
		__type:'ClientArray'
		constructor: (args) ->
			super
			@_array = args._array

		each: (cb) ->
			_.each @_array, cb
			
		forEach: (cb) ->
			@each cb

		setArray: (array) ->
			@_array = array
			# while @length
			# 	@delete()
			# for el,i in array
				# @insert el, i
		delete: (pos) -> 
			@_array.splice pos, 1
		insert: (el, pos) ->
			if pos == 0
				@_array.unshift el
			else if pos == @_array.length
				@_array.push el
			else
				@_array.splice pos, 0, el
		# push: (el) -> @_array.insert el, @_array.length
		# each: (cb) -> _.each @_array, cb
		# forEach: (cb) -> @each cb
		move: (from, to) ->
			if from != to
				[el] = @_array.splice from, 1
				@_array.splice to, 0, el

		_sync: (obj) ->
			@setArray @view.deserialize(obj._array)

		onMutation: (mutation) ->
			switch mutation.type
				when 'insertion'
					@insert @view.deserialize(mutation.value), mutation.position
				when 'deletion'
					@delete mutation.position
				when 'movement'
					@move mutation.from, mutation.to
				when 'setArray'
					@setArray @view.deserialize(mutation.array)


		get: (i) -> @_array[i]

		length: -> @_array.length
				
	window.ClientValue = class ClientValue extends ClientObject
		__type:'ClientValue'

		constructor: (args) ->
			super
			@_scalar = args._scalar


		_set: (value) ->
			@clearObjs()
			@objs = []
			@_scalar = @deserialize value, @objs

		_sync: (obj) ->
			@_set obj._scalar

		onMutation: (mutation) ->
			@_set mutation.value

		get: -> @_scalar

	deserialize = (obj, classMap, extraArgs, passThru, objs) ->
		if _.isObject obj
			obj = _.clone obj

			if _.isArray obj
				for item, i in obj
					obj[i] = deserialize item, classMap, extraArgs, passThru, objs
			else
				if className = obj.__class__
					delete obj.__class__
					if classObj = classMap[className]
						theseObjs = []
						obj = new classObj(_.extend(deserialize(obj, classMap, extraArgs, passThru, theseObjs), extraArgs))
						obj.setObjs? theseObjs
						passThru? obj
						objs?.push obj
					else
						throw new Error "no class #{className}"
				else if obj.constructor == Object
					for name, value of obj
						obj[name] = deserialize value, classMap, extraArgs, passThru, objs
		obj
	
	class ValueInterface
		constructor: (@view, @el, @attr=null) ->
		setMapping: (@mapping) -> @
		set: (@value) -> 
			v = if @mapping then @mapping @value else @value
			if @attr
				@el.attr @attr, v
			else
				@el.html v
		get: -> @value
		setDataSource: (@dataSource, @trigger) ->
			@dataSource.stopObserving @_observer if @_observer
			@set @dataSource.get()
			@trigger? @dataSource.get(), @el
			@dataSource.observe @_observer = (mutation) =>
				@set mutation.value
				@trigger? mutation.value, @el
		destruct: ->
			@dataSource.stopObserving @_observer if @_observer

	class ListInterface
		@id: 1
		setDataSource: (dataSource) ->
			@dataSource?.stopObserving @_observer

			@dataSource = dataSource
			@set dataSource
			dataSource.observe @_observer = (mutation) =>
				switch mutation.type
					when 'insertion'
						@insert @view.deserialize(mutation.value), mutation.position
					when 'deletion'
						@delete mutation.position
					when 'movement'
						@move mutation.from, mutation.to
					when 'setArray'
						@set @view.deserialize(mutation.array)
					
		destruct: ->
			@dataSource?.stopObserving @_observer

		constructor: (@view, @el, @selector, @mapping) ->
			@id = ListInterface.id++
			@template = $ @el.find(@selector).get 0
			# @template = $ @template.get 0

			if @template.length == 0
				#Debug.log view
				throw new Error 'Failed to find template'
			
			@prevSibling = @template.prev()
			@nextSibling = @template.next()
			@parent = @template.parent()

			if @parent.length == 0
				#Debug.log view
				throw new Error "BAD"			
			@els = []
			@deleteCbs = []
			
		get: (position) -> @els[position]
		
		clear: ->
			@el.find(@selector).remove()
			@els = []
			for cb in @deleteCbs
				cb?() 
			@deleteCbs = []
			@onLengthChanged?()
		
		set: (data) ->
			@clear()
			data.forEach (item, i) =>
				@insert item, i, false
			@onMutation?()
						
		delete: (i) ->
			el = @els[i]
			@els.splice i, 1
		
			if @onDelete
				@onDelete el, -> el.remove()
			else
				el.remove()
				
			@deleteCbs[i]?()
			@deleteCbs.splice i, 1
			@onLengthChanged?()
			@onMutation?()

		insert: (data, pos, signalMutation=true) ->
			setDeleteCb = (cb) =>
				@deleteCbs.splice pos, 0, cb
		
			el = @mapping @template.clone(), data, pos, setDeleteCb
			next = @els[pos]
			if next
				@parent.get(0).insertBefore el.get(0), next.get(0)
			else
				@parent.get(0).insertBefore el.get(0), @nextSibling.get(0)
			
			if pos == 0
				@els.unshift el
			else if pos == @els.length
				@els.push el
			else
				@els.splice pos, 0, el
				
			@onInsert? el
			@onLengthChanged?()

			@onMutation?() if signalMutation
					
		push: (data) ->
			@insert data, @els.length
			
		move: (from, to) ->
			el = @els[from]
			if from > to
				el.detach().insertBefore(@els[to])
			else
				el.detach().insertAfter(@els[to])

			[el] = @els.splice from, 1
			@els.splice to, 0, el
			
			[el] = @deleteCbs.splice from, 1
			@deleteCbs.splice to, 0, el

			@onMove? from, to
			@onMutation?()
			
		length: -> @els.length

	class Event
		constructor: ->
			@subscribers = []

		subscribe: (subscriber) ->
			@subscribers.push subscriber

		fire: (args...) ->
			subscriber args... for subscriber in @subscribers

	window.View_views = {}
	window.View_nextClientId = 1
	class View
		@flexibleViews: {}

		@clear: ->
			for id,view of View_views
				view.destruct()
			View_views = {}
			View_nextClientId = 1
			@flexibleViews = {}


		@windowResized: ->
			clearTimeout @resizeTimerId 
			@resizeTimerId = setTimeout (=>
				for viewId,view of @flexibleViews
					view.updateLayout?()
			), 50


		@isClientValue: (obj) -> obj.__type == 'ClientValue'
		@isClientArray: (obj) -> obj.__type == 'ClientArray'


		@createView: (className, args...) ->
			view = null
			if className
				className += 'View' unless className.match /View$/
				eval "klass = #{className}"
				if args && args.length
					view = new klass contentScript, args...
				else
					view = new klass contentScript
			else 
				view = new View(contentScript)
			view

		withData: (data, cb) ->
			if data.get()?
				cb data.get()
			data.observe (mutation) -> cb data.get(), mutation

		constructor: (@contentScript, args...) ->
			@clientId = View_nextClientId++
			@clientObjects = []
			@observedObjects = []
			@views = []
			@interfaces = []
			@trackingViews = []

			@mouseEnteredCount = 0

			@prevMouseEnteredCount = 0

			@init? args...

			if @flexibleLayout
				View.flexibleViews[@clientId] = @

			if !View.inited
				View.inited = true
				$(window).resize -> View.windowResized()

			@events =
				onDestruct: new Event
				onAttached: new Event
				onRepresent: new Event

		alsoRepresent: (view) ->
			@representList ?= []
			@representList.push view

		useEl: (el) ->
			@el = el
			el.data 'view', @

			el.mouseenter =>
				@_mouseenter true 

			el.mouseleave =>
				@_mouseleave true
			el

		viewEl: (html) ->
			el = $ html
			# el.attr 'agora:clientid', @clientId
			@useEl el
			el
			
		createView: (className, args...) ->
			# view = null
			# if className
			# 	className += 'View' unless className.match /View$/
			# 	eval "klass = #{className}"
			# 	if args && args.length
			# 		view = new klass(@contentScript, args...)
			# 	else
			# 		view = new klass @contentScript
			# else 
			# 	view = new View(@contentScript)
			view = View.createView className, args...
			@views.push view
			view.parent = @
			view

		view: -> @createView.apply @, arguments

		syncWithValue: (value, cb) ->
			cb value.get()
			@observe value, ->
				cb value.get()
		
		isAttached: -> typeof @id != 'undefined'
		
		attach: (cb) ->
			if !@type
				throw new Error 'No type!'

			@contentScript.triggerBackgroundEvent 'CreateView', type:@type, (response) =>
				# Debug.log @type, 'attached'
				@id = response.id
				@el.data 'view', @
				@el.attr 'agora:id', @id if @el
				View_views[@id] = @
				@contentScript.listen "ViewMethod:#{@id}", (args) =>
					@callMethod args.name, args.params
				cb() if cb
				@events.onAttached.fire()
				
		# should this detach child views as well?
		detach: ->
			@clearClientObjects()
			@contentScript.stopListening "ViewMethod:#{@id}"
			@contentScript.triggerBackgroundEvent 'DeleteView', id:@id if @id?

		represent: (@args, cb) ->
			if @isAttached()
				@onRepresent? @args
				view.represent @args for view in @representList if @representList
				@contentScript.triggerBackgroundEvent 'ConnectView', id:@id, args:@args, (response) =>
					if response == false
						
					else
						#Debug.log 'ConnectView', @id, @type, @, args, response
						@data = @deserialize response.data

						map = {}
						ids = []
						for clientObject in @clientObjects
							ids.push clientObject._id
							map[clientObject._id] = clientObject

						@contentScript.triggerBackgroundEvent 'GetClientObjects', ids, (response) =>
							for id, value of response
								map[id]._sync value

							@onData? @data
							cb?()
							@events.onRepresent.fire()

			else
				@attach => @represent @args, cb

		deserialize: (data, objs) ->
			deserialize data,
				{
					ClientArray: ClientArray
					ClientValue: ClientValue
				}
				{contentScript: @contentScript, view: @}
				((obj) => @clientObjects.push obj)
				objs
			
		callBackgroundMethod: (methodName, args, returnValueCb) ->		
			#Debug.log 'callBackgroundMethod', @, methodName, args	
			if @id
				@contentScript.triggerBackgroundEvent 'CallViewBackgroundMethod',
					view:@type, id:@id, methodName:methodName, args:args, timestamp:new Date().getTime()
					(response) ->
						returnValueCb response
			else
				throw new Error "not connected"

		_addInterface: (iface) ->
			@interfaces.push iface
			iface

		listInterface: (el, selector, mapping) ->
			@_addInterface new ListInterface @, el, selector, mapping
			
		valueInterface: (el, attr=null) ->
			@_addInterface new ValueInterface @, el, attr
			
		callMethod: (name, params) ->
			if @methods && method = @methods[name]
				method.apply @, params
				
		observe: (observable, observer) ->
			@observedObjects.push object:observable, observer:observer
			observable.observe observer, @

		observeObject: (observable, observer) -> @observe observable, observer

		clearClientObjects: ->
			clientObject.destruct false for clientObject in @clientObjects 
			@clientObjects = []

		clearInterfaces: ->
			iface.destruct() for iface in @interfaces
			@interfaces = []

		trackView: (view) ->
			view.trackingViews ?= []
			view.trackingViews.push @
			@trackedViews ?= []
			@trackedViews.push view

		clearViews: ->
			for view in _.clone @views
				if !view
					console.error 'null view!', @
				view?.destruct true, @
			@views = []

		stopObservingObjects: ->
			object.stopObserving observer for {object:object, observer:observer} in @observedObjects
			@observedObjects = []

		clear: ->
			@clearClientObjects()
			@stopObservingObjects()
			@clearViews()
			@clearInterfaces()

			view.destruct(true, @) for view in @trackedViews if @trackedViews
			delete @trackedViews

		pathElement: ->
			parts = @type.split('/')
			parts[parts.length - 1]

		path: ->
			if @type
				if @basePath
					"#{@basePath}/#{@pathElement()}"
				else if @parent
					"#{@parent.path()}/#{@pathElement()}"
				else
					"/#{@pathElement()}"
			else if @parent
				@parent.path()
			else 
				'/'

		event: (action, label=null) ->
			parts = @type.split '/'
			tracking.event parts[parts.length - 1], action, label

		separate: ->
			_.pull @parent.views, @
			_.pull view.trackedViews, @ for view in @trackingViews if @trackingViews
			delete @trackingViews

		destruct: (removeFromParent=true, destructor=null) ->
			return if @noDestruct
			@_mouseleave true if @mouseEntered
			unless @destructed
				if @flexibleLayout
					delete View.flexibleViews[@clientId]
				@detach()
				@clear()
				if @parent && removeFromParent
					_.pull @parent.views, @
				@destructed = true
				@events.onDestruct.fire()

		shown: ->


		_testMouseEntered: ->
			clearTimeout @_testMouseEnteredTimerId
			@_testMouseEnteredTimerId = setTimeout (=>
				if @mouseEnteredCount != @prevMouseEnteredCount
					if @mouseEnteredCount && !@prevMouseEnteredCount
						@onMouseenter?()
					else if !@mouseEnteredCount && @prevMouseEnteredCount
						@onMouseleave?()

					@prevMouseEnteredCount = @mouseEnteredCount

			), 100

		_mouseenter: (self=false) ->
			if self
				return if @mouseEntered
				@mouseEntered = true

			@mouseEnteredCount++
			@parent?._mouseenter()
			@_testMouseEntered()

		_mouseleave: (self=false) ->
			if self
				return if !@mouseEntered
				@mouseEntered = false

			@mouseEnteredCount--
			@parent?._mouseleave()
			@_testMouseEntered()