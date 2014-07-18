define ->
	class ListInterface
		constructor: (args) ->
			@new = args.new
			@el = args.el
			@array = args.array

			@reset()

		reset: ->
			@el.html ''

			if @array
				for el in @array
					@_add el

		_add: (data) ->
			removeFunc = null
			el = @new data,
				remove: =>
					el.remove()
					removeFunc?()
					if @array
						_.pull @array, data

				onRemove: (func) -> removeFunc = func


			@el.append el

		add: (data) ->
			@_add data
			if @array
				@array.push data
