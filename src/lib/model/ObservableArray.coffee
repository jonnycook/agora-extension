define ['./ObservableObject', 'underscore'], (ObservableObject, _) ->
	class ObservableArray extends ObservableObject
		constructor: (@_array) ->
			@_array ?= []
			
		get: (index) -> 
			if index < 0
				@get index + @_array.length
			else
				if index >= @_array.length
					throw new Error "index out of bounds: #{index}"
				@_array[index]

		insert: (position, value) ->
			if !value
				throw new Error 'false value'
			@_array.splice position, 0, value
			@_fireMutation 'insertion', position:position, value:value, length:@_array.length
			
		delete: (position, tag) ->
			if position >= @_array.length then throw new Error "#{position} out of range"
			value = @_array[position]
			if !value
				console.debug @_array
				throw new Error "#{position}"
			# console.log "delete #{@name} #{position}", value
			@_array.splice position, 1
			@_fireMutation 'deletion', position:position, value:value, length:@_array.length, tag:tag

		remove: (el, tag) ->
			index = @indexOf el
			if index != -1
				@delete index, tag
			else
				console.log el, 'not in array', @
			
		deleteIf: (predicate) ->
			deleteQueue = []
			@each (value, i) =>
				if predicate value
					deleteQueue.unshift i
									
			for i in deleteQueue
				@delete i
		
		push: (value) ->
			@insert @_array.length, value

		unshift: (value) ->
			@insert 0, value


		append: (array) ->
			for value in array
				@push value
			
		each: (iterator) ->
			_.each @_array, iterator
		
		indexOf: (el, start) -> @_array.indexOf el, start

		contains: (obj) -> @_array.indexOf(obj) != -1
			
		find: (predicate) ->
			for value in @_array
				return value if predicate value

		findAll: (predicate) ->
			values = []
			for value in @_array
				values.push value if predicate value
			values

		length: -> @_array.length
		
		move: (from, to) ->
			if from != to
				[el] = @_array.splice from, 1
				if !el
					throw new Error 'poop'
				@_array.splice to, 0, el
				@_fireMutation 'movement', from:from, to:to
		
		sort: (comp) -> @_array.sort comp

		clear: ->
			super
			@_array = []