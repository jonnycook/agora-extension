define ['underscore', 'text!taxonomySrc'], (_, taxonomySrc) ->
	lines = taxonomySrc.split /\n/

	taxonomy = {}
	currentItem = null

	for line in lines
		if line.trim() == ''
			continue

		if line[0] == '\t'
			line = line.trim()
			continue if line[0] == '#'

			if line[0] == '@'
				special = line.match(/^@(.*)\s/)[1]
				if special == 'icon'
					taxonomy[currentItem].icon = line.match(/^@icon (.*)$/)[1]
			else
				taxonomy[currentItem].properties.push line

		else
			matches = line.match /^(.*?)(?: \((.*?)\))?(?: : (.*?))?$/
			currentItem = matches[1]
			taxonomy[currentItem] = properties:[]

			if matches[2]
				taxonomy[currentItem].synonyms = matches[2].split ', '

			if matches[3]
				taxonomy[currentItem].isA = matches[3]

	nameMap = {}

	plural = (word) ->
		if word.match /ly$/
			word.substr(0, word.length - 1) + 'ies'
		else if word.match /s$/
			word + 'es'
		else
			word + 's'

	for type,obj of taxonomy
		nameMap[type] = type
		nameMap[plural type] = type
		if obj.synonyms
			for synonym in obj.synonyms
				nameMap[synonym] = type
				nameMap[plural synonym] = type

 
	canonicalTypeName = (typeName) ->
		if typeName then typeName = typeName.toLowerCase()
		return nameMap[typeName]
		if taxonomy[typeName]
			typeName
		else
			for type,obj of taxonomy
				if obj.synonyms && _.contains obj.synonyms, typeName
					return type
			typeName

	properties: (typeName) ->
		typeName = canonicalTypeName typeName
		return [] unless taxonomy[typeName]
		properties = []

		while typeName
			type = taxonomy[typeName]
			if type.properties
				properties = properties.concat ([typeName, prop] for prop in type.properties)

			typeName = type.isA

		properties.sort (a, b) ->
			if a[1] > b[1]
				1
			else if a[1] < b[1]
				-1
			else 
				0

		"#{typeName}.#{prop}" for [typeName, prop] in properties
		
	icon: (typeName) -> taxonomy[canonicalTypeName typeName]?.icon
