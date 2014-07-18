define ['../ResourceScraper', 'underscore'], (ResourceScraper, _) ->
	class JsonResourceScraper extends ResourceScraper
		constructor: (@map) -> return ResourceScraper arguments if @ == window
				
		scrape: (cb) ->
			obj = 
				matchAll: (string, pattern, group=false) ->
					matches = string.match new RegExp (if _.isString pattern then pattern else pattern.source), 'g'
					if matches
						if group==false
							for match in matches
								match.match pattern
						else
							for match in matches
								match.match(pattern)[group]
					else
						[]

			cb @map.call obj, JSON.parse @resource
