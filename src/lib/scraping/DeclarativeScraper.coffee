define ->

	class Value
		constructor: (@name, @value) ->

	
	class DeclarativeScraper
		executeMatches: (matches, subject) ->
			values = []
			if matches
				for match, i in matches
					continue if match.disabled
					values = values.concat @execute match, subject, i
			values

		getPath: -> index:el.index, type:el.type for el in @path

		hasValue: (obj, key) ->
			obj && key of obj && obj[key] != null && obj[key] != ''


		executeMatch: (el, matches) ->
			values = []
			if el.captures
				for group,capture of el.captures
					r = @execute capture, matches[parseInt group], group
					if r
						values = values.concat r
			return @processValue el, values, matches

		processValue: (el, values, matches, tieredMatches, subject) ->
			if el.value

				name = el.value.name
				if @hasValue(el.value, 'name') && matches
					name = name.replace /\$(\d+):(\d+)/g, (match, p1, p2) ->
						return tieredMatches[parseInt p1][parseInt p2]

					name = name.replace /\$([a-z]*)(\d+)/g, (match, flag, p1) ->
						value = matches[parseInt p1]
						if flag == 'lc'
							value = value.toLowerCase()
						return value

				if @hasValue el.value, 'type'
					if el.value.type == 'array'
						array = []
						for value in values
							array.push value.value
						return [new Value name, array]
					else if el.value.type == 'object'
						obj = {}
						for value in values
							if !value.name
								console.debug el, values
								throw new Error 'ValueMustHaveName'
							a = obj
							parts = value.name.split '.'
							for part,i in parts
								if i == parts.length - 1
									a[part] = value.value
								else
									a[part] ?= {}
									a = a[part] 

						return [new Value name, obj]
				else if @hasValue el.value, 'content'
					content = el.value.content
					if matches
						content = content.replace /\$(\d+):(\d+)/g, (match, p1, p2) ->
							return tieredMatches[parseInt p1][parseInt p2].replace /"/g, '\\"'

						content = content.replace /\$([a-z]*)(\d+)/g, (match, flag, p1) ->
							value = matches[parseInt p1].replace /"/g, '\\"'
							if flag == 'lc'
								value = value.toLowerCase()
							return value

					return [new Value name, JSON.parse content]
				else if matches && @hasValue el.value, 'capture'
					return [new Value name, matches[el.value.capture]]
				else if @hasValue el.value, 'name'
					if values.length
						values[0].name = name
					else
						return [new Value name, subject]


			return values

		execute: (el, subject, index=0) ->
			retVal = null
			if el.type || el.pattern
				el.type ?= 'Match'
				@path.push type:'match', index:index, el:el
				switch el.type
					when 'Match'
						regExp = new RegExp el.pattern
						matches = subject.match regExp
						
						if matches
							values = []

							if el.captures
								try
									for group,capture of el.captures
										values = values.concat @execute capture, matches[parseInt group], group
								catch e
									if el.optional && e.message == 'FailedRequirement'
										retVal = []
									else
										throw e

							retVal = @processValue el, values, matches
						else if el.optional
							retVal = []
						else
							throw new Error 'FailedRequirement'

					when 'MatchAll'
						regExp = new RegExp el.pattern
						globalMatches = subject.match new RegExp el.pattern, 'g'

						
						tieredMatches = []
						if globalMatches
							values = []
							try
								for globalMatch,i in globalMatches
									matches = globalMatch.match regExp
									tieredMatches[i] = matches
									values = values.concat @executeMatch {type:'Match', captures:el.match.captures, value:el.match.value}, matches
							catch e
								if el.optional && e.message == 'FailedRequirement'
									retVal = []
								else
									throw e


							retVal = @processValue el, values, globalMatches, tieredMatches
						else if el.optional
							retVal = []
						else throw new Error 'FailedRequirement'


					when 'Or'
						# console.debug 'asdf'
						for match, i in el.matches
							continue if match.disabled
							try 
								value = @execute match, subject, i
								if value.length
									retVal = @processValue el, value, null, null, subject
									break
							catch e
								# console.debug 'asdf'
								if e.message != 'FailedRequirement'
									throw e
								else
									@path.pop()


						if !retVal
							if el.optional
								retVal = []
							else
								throw new Error 'FailedRequirement'

					when 'Switch'
						value = null
						try
							for caseObj, i in el.cases
								continue if caseObj.disabled
								if @hasValue(caseObj, 'pattern') && subject.match(new RegExp caseObj.pattern) || !@hasValue(caseObj, 'pattern')
									value = @processValue caseObj, @executeMatches(caseObj.matches, subject), null, null, subject
									break
						catch e
							if el.optional && e.message == 'FailedRequirement'
								retVal = []
							else
								throw e


						value = @processValue el, value, null, null, subject
						if value.length
							retVal = value
						else if el.optional
							retVal = []

						else throw new Error 'FailedRequirement'

					when 'Count'
						regExp = new RegExp el.pattern, 'g'
						matches = subject.match regExp
						if matches
							retVal = [new Value null, matches.length]
						else
							retVal = []


			else
				@path.push type:'text', index:index
				values = @executeMatches el.matches, subject

				retVal = @processValue el, values, null, null, subject

			if retVal == null

				throw new Error 'return is null'

			@path.pop()

			retVal

		constructor: (@scraper) ->
			@path = []
		scrape: (subject) -> @execute @scraper, subject

