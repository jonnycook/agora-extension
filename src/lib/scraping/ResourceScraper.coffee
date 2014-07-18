define ->
	class ResourceScraper
		constructor: (args) ->
			if @ == window
				return const:args.callee, args:args, config: (config) ->
					const:args.callee, args:args, config:config

		config: (config) ->
			for name,value of config
				@[name] = value
			@
		pushResource: (resource) ->
			@resource = resource