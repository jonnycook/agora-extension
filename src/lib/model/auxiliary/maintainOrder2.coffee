define ['underscore'], (_) ->
	sort = (array, args) ->
		{move:move, compare:compare, get:get, length:length} = args

		findBetween = (a, b, skips=[]) ->
			for i in [0...length(array)]
				continue if i in [a, b]
				if compare(get(array, i), get(array, a)) > 0 && compare(get(array, i), get(array, b)) < 0
					return true
			false

		ranges = []
		rangeA = 0
		rangeB = 0
		range = []
		for i in [0...length(array) - 1]
			range.push get(array, i)
			if compare(get(array, i), get(array, i + 1)) > 0 || findBetween i, i + 1
				ranges.push a:rangeA, b:rangeB, range:range, aValue:get(array, rangeA), bValue:get(array, rangeB)
				range = []
				rangeA = rangeB = i + 1
			else
				rangeB++
		range.push get(array, length(array) - 1)

		ranges.push a:rangeA, b:rangeB, range:range, aValue:get(array, rangeA), bValue:get(array, rangeB)

		orderedRanges = ranges.slice(0, ranges.length).sort (a, b) -> a.range.length - b.range.length

		sortedRanges = ranges.slice(0, ranges.length)


		actions = []
		for r in orderedRanges
			originalPosition = 0
			from = 0


			for range, i in sortedRanges
				if range == r
					originalPosition = i
					sortedRanges.splice i, 1
					break
				else
					from += range.range.length

			to = 0

			for i in [0..sortedRanges.length]
				shouldMove = false

				if i == sortedRanges.length
					shouldMove = true
				else
					if compare(r.bValue, sortedRanges[i].aValue) <= 0
						shouldMove = true

				if shouldMove
					if originalPosition != i
						actions.push from:from, to:to, length:r.range.length

					sortedRanges.splice i, 0, r
					break
				else
					to += sortedRanges[i].range.length

		for action in actions
			a = 0
			for i in [action.from...action.from+action.length]
				from = i
				to = action.to + i - action.from

				move array, from, to


	(list, orderBy) ->
		startedTimer = false
		maintainOrder = (instance) ->
			compare = (a, b) =>
				if a.get(orderBy.field) < b.get(orderBy.field)
					result = -1
				else if a.get(orderBy.field) > b.get(orderBy.field)
					result = 1
				else
					result = 0
				
				if orderBy.direction == 'desc'
					result *= -1
				
				return result
				
			list.sort compare

			order = ->
				return if startedTimer
				startedTimer = true

				setTimeout (->
					startedTimer = false
					sort list,
						length: (array) -> array.length()
						compare: (a, b) =>
							if a.get(orderBy.field) < b.get(orderBy.field)
								result = -1
							else if a.get(orderBy.field) > b.get(orderBy.field)
								result = 1
							else
								result = 0
							
							if orderBy.direction == 'desc'
								result *= -1
							
							return result
						move: (array, from, to) ->
							array.move from, to
						get: (array, i) -> array.get i
				), 0
			
			instance.field(orderBy.field).observe order

			-> instance.field(orderBy.field).stopObserving order

		stopFuncs = []
		list.observe (mutation) ->
			instance = mutation.value
			if mutation.type == 'insertion'
				if instance.get(orderBy.field) == null
					instance.set(orderBy.field, list.length())

				stop = maintainOrder mutation.value
				stopFuncs.push obj:mutation.value, func:stop

			if mutation.type == 'deletion'
				for a,i in stopFuncs
					if a.obj == mutation.value
						a.func()
						stopFuncs.splice i, 1
						break

