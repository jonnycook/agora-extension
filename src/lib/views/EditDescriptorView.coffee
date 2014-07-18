define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class EditDescriptorView extends View
		# constructor: ->
		# 	super
		# @id:  -> args.decisionId

		@nextId: 0
		@id: (args) -> ++ @nextId#"#{args.type}/#{args.id}"

		initAsync: (args, done) ->
			# @obj = @agora.modelManager.getInstance 'Decision', @args.decisionId
			
			# clientContents = @ctx.clientArray @obj.get('competitiveList').get('elements'), (el) =>
			# 	element = @obj.get('elements').get el

			# 	row = @clientValue element.get 'row'
			# 	element.field('row').observe -> row.set element.get 'row'

			# 	row: row
			# 	barItem:
			# 		elementType:'CompetitiveListElement', elementId:el.get('id'), decisionId:@obj.get 'id'

			# @data = clientContents


			init = =>
				descriptor = @decision.get('list').get('descriptor') ? {}
				descriptor.version = 0

				@data = @clientValue descriptor
				@version = 0
				@parsing = 0
				done()

			unless _.isPlainObject args
				@decision = @agora.modelManager.getInstance('Decision', @args)
				init()
			else
				@resolveObject args, (@decision) => init()
		methods:
			parse: (view, @descriptor, update) ->
				@parsing++
				@agora.background.httpRequest "#{@agora.background.apiRoot}parse.php", 
					data:descriptor:descriptor
					cb:(response) =>
						--@parsing
						if @shouldUpdate || update
							response.descriptor = @descriptor
							@decision.get('list').set 'descriptor', response
							_activity 'decision.setDescriptor', @decision, response
						else
							@lastDescriptor = response
							response.version = @version++
							@data.set response

			updateDescriptor: (view, descriptor) ->
				if descriptor.version == @version && !@parsing
					delete descriptor.version
					@decision.get('list').set 'descriptor', descriptor
					_activity 'decision.setDescriptor', @decision, descriptor
				else
					if @parsing
						@shouldUpdate = true
					else
						delete @lastDescriptor.version
						@lastDescriptor.descriptor = @descriptor
						@decision.get('list').set 'descriptor', @lastDescriptor
						_activity 'decision.setDescriptor', @decision, @lastDescriptor
