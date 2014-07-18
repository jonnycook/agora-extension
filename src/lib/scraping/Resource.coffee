define ['underscore'], (_) ->
	class Resource extends String
		constructor: (@value, @url) -> 
			String.call @, @value
			
		safeMatch: (pattern) ->
			matches = @match pattern
			if matches then matches else throw new Error "#{pattern} not found in #{@url}"
			
		matchAll: (pattern, group) ->
			pattern = pattern.source  if pattern instanceof RegExp
			r = []
			globalMatches = @match(new RegExp(pattern, "g"))
			if globalMatches
				regExp = new RegExp(pattern)
				i = 0

				while i < globalMatches.length
					matches = globalMatches[i].match(regExp)
					if typeof group is "undefined"
						r.push matches
					else
						r.push matches[group]
					++i
			r
			
		valueOf: ->	@value
		toString: -> @value
		substr: -> new Resource super
