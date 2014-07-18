define ['View'], (View) ->
	class WebAppView extends View
		@id: (args) -> args
		initAsync: (args, done) ->
			@data = {}
			if args
				path = args
				parts = path.split '/'
				if parts[0] == 'decisions'
					@agora.public.get 'decisions', parts[1], (success, id) =>
						if success
							@data.decisionId = 'G' + id
						else
							@data.accessDenied = true
						done()
				else
					done()
			else
				done()
