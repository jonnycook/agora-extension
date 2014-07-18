define -> class Formatter
	@price: (price) -> 
		if price
			price += ''
			parts = price.split '.'
			if parts.length == 1
				price += '.00'
			else
				if parts[1].length == 1
					price += '0'

			"$#{price}"


