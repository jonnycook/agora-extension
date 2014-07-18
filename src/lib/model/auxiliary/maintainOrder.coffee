define ->
	maintainOrder = (orderBy, instance, list) ->
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

		ordering = false
		order = ->
			return if ordering
			ordering = true

			index = list.indexOf instance
			to = null
			
			for i in [0..list.length()-1]
				continue if instance == list.get(i)
				
				result = compare(instance, list.get(i))
				
				if result < 0
					to = if index > i then i else i - 1
					break
				else if result == 0
					return
					
			if to == null
				to = list.length() - 1
			
			list.move index, to

			for i in [0..list.length()-1]
				list.get(i).set orderBy.field, i


			ordering = false
		
		instance.field(orderBy.field).observe order

		-> instance.field(orderBy.field).stopObserving order
