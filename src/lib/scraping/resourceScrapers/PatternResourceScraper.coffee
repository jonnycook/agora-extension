define ['../ResourceScraper', 'underscore'], (ResourceScraper, _) ->
	class PatternResourceScraper extends ResourceScraper
		constructor: (@pattern, @match, @default) -> return ResourceScraper arguments if @ == window
				
		scrape: (cb) ->
			map = @map ? ((value) -> value)
			if _.isArray @pattern
				for [pattern, match, m], i in @pattern
					matches = @resource[if i == @pattern.length - 1 then 'safeMatch' else 'match'] pattern
					# console.log pattern,matches
					if matches
						# console.log matches[match]
						cb (m ? map) matches[match]
						return
				cb null
			else
				matches = @resource[if @default? then 'match' else 'safeMatch'] @pattern
				if matches
					cb map matches[@match]
				else if @default?
					cb @default
				else cb null

