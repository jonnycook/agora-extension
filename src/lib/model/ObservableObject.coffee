define ['underscore', 'Debug'], (_,Debug) ->
	class ObservableObject
		clearObservers: ->
			@observers = []
			@tags = []			

		observeWithTag: (tag, observer) -> @observe observer, tag
		observe: (observer, tag=null) ->
			throw new Error 'bad!' unless observer
			observers = @observers
			if !observers
				@observers = observers = []
				@tags = []

			observers.push observer
			@tags.push tag:tag#, caller:Debug.stackTrace()[1]
			
		@radioSilence: (block) ->
			@_radioSilence = true
			block()
			@_radioSilence = false

		@pause: ->
			@paused = true
			@queue = []

		@resume: ->
			@paused = false
			for {observable:observable, observers:observers, obj:obj} in @queue
				@_call observable, observers, obj
			delete @queue

		@_call: (observable, observers, obj) ->
			#Debug.log '_callObservers', observable, obj
			observer(obj) for observer in observers

		stopObservingWithTag: (tag) ->
			if @observers
				index = @tags.indexOf tag
				unless index == -1
					@observers.splice index, 1
					@tags.splice index, 1

		stopObserving: (observer) ->
			if @observers
				index = @observers.indexOf observer
				unless index == -1
					@observers.splice index, 1
					@tags.splice index, 1
			
		_callObservers: (obj) ->
			if @observers
				if ObservableObject.paused
					ObservableObject.queue.push observable:@, observers:_.clone(@observers), obj:obj
				else
					ObservableObject._call @, _.clone(@observers), obj
			
		_fireMutation: (type, mutationInfo) ->
			@_callObservers _.extend({type:type}, mutationInfo) unless ObservableObject._radioSilence


		clear: ->
			@clearObservers()