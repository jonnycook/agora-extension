# array = [0, 1, 2, 3, 9, 4, 5, 6, 7, 8]
array = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]


sort = (array, args) ->
	{move:move, compare:compare, get:get} = args

	findBetween = (a, b, skips=[]) ->
		for i in [0...array.length]
			continue if i in [a, b]
			if compare(get(array, i), get(array, a)) > 0 && compare(get(array, i), get(array, b)) < 0
				return true
		false

	ranges = []
	rangeA = 0
	rangeB = 0
	range = []
	for i in [0...array.length - 1]
		range.push get(array, i)
		if compare(get(array, i), get(array, i + 1)) > 0 || findBetween i, i + 1
			ranges.push a:rangeA, b:rangeB, range:range, aValue:get(array, rangeA), bValue:get(array, rangeB)
			range = []
			rangeA = rangeB = i + 1
		else
			rangeB++
	range.push get(array, array.length - 1)

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



sort array,
	move:(array, from, to) ->
		[value] = array.splice from, 1
		array.splice to, 0, value
	compare: (a, b) ->
		a - b
	get: (array, i) -> array[i]
console.debug array

