define -> d: [], c: ->
	get: (type, opts={}) ->
		systems = 
			computer: [
				'harddrive'
				'monitor'
				'cpu'
				'ram'
				'motherboard'
				'graphicsCard'
				'powerSupply'
				'keyboard'
				'mouse'
				'soundcard'
				'cooling'
				'speakers'			
			]

		map = {}

		for name,components of systems
			for component,i in components
				map[component] = system:name, position:i

		file = position = size = null
		has2x = true
		# if map[type]?.system == 'computer'
		# 	file = 'computerComponents'
		# 	position = left:(10+48)*map[type].position, top:70
		# 	has2x = false
		# else
		file = type

		opts.color ?= 'darkGray'

		if opts.inverted
			file += '(inverted)'

		if opts.color == 'white'
			file += 'White'
		else if opts.color == 'lightGray'
			file += 'LightGray'
		else if opts.color == 'darkGray'
			file += 'DarkGray'
		else
			throw new Error 'invalid color'
			
		if opts.size == 'large'
			file += 'Large'

		if has2x && typeof window.devicePixelRatio != 'undefined' && window.devicePixelRatio > 1
			file += '@2x'

		sizes = if opts.inverted
				{}
			else if opts.size == 'large'
				babyToy: width:102, height:103
				list: width:109, height:117
				trousers: width:93, height:82
			else
				list: width:24, height:24
				computer: width:30, height:32
				bundle: width:30, height:27
				babyToy: width:30, height:30
				trousers: width:24, height:21

		size = sizes[type] ? width:48, height:48
		if opts.size == 'small'
			size.width /= 2
			size.height /= 2

		position:position, file:"images/icons/#{file}.png", size:size

	setIcon: (el, type, opts={}) ->
		if !type
			@clearIcon el
		else
			iconInfo = @get type, opts

			el.addClass 't-item' if opts.itemClass ? true

			if opts.inverted
				el.addClass 'icon-inverted'

			if iconInfo.position
				el.css backgroundPosition: "-#{iconInfo.position.left}px -#{iconInfo.position.top}px"
			else
				el.css backgroundPosition: 'center'

			el.css
				backgroundImage: "url('#{contentScript.resourceUrl(iconInfo.file)}')"
				backgroundRepeat: 'no-repeat'

			if opts.size == 'contain'
				el.css backgroundSize: 'contain'
			else if iconInfo.size
				el.css backgroundSize: "#{iconInfo.size.width}px #{iconInfo.size.height}px"

	clearIcon: (el) ->
		el.removeClass 'icon-inverted'
		el.css backgroundPosition:'', backgroundImage:'', backgroundRepeat:'' 
