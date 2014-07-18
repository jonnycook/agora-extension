define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class AddDataView extends View
		# constructor: ->
		# 	super
		# @id:  -> args.decisionId
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args.object, (@obj) =>
				if args.url
					if args.url.match /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
						@agora.background.httpRequest args.url,
							cb: (responseText, response) =>
								contentType = response.header('Content-Type')
								if contentType.match /^text\/html/
									matches = responseText.match /<title>([^<]*)<\/title>/i
									title = if matches then matches[1].trim()
										
									@data = type:'url', title:title
								else if contentType.match /^image\//
									@data = type:'image'

								done()
							error: =>
								done()
					else
						@data = {}
				else
					done()

		# @obj = @agora.modelManager.getInstance 'Decision', @args.decisionId
			
		methods:
			add: (view, data) ->
				data.element_type = @obj.modelName
				data.element_id = @obj.get 'id'
				@agora.modelManager.getModel('Datum').create data
