define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy'], (View, Site, Formatter, util, _, taxonomy) ->	
	class AddDescriptorView extends View
		# constructor: ->
		# 	super
		# @id:  -> args.decisionId
		init: ->
			# @obj = @agora.modelManager.getInstance 'Decision', @args.decisionId
			
			# clientContents = @ctx.clientArray @obj.get('competitiveList').get('elements'), (el) =>
			# 	element = @obj.get('elements').get el

			# 	row = @clientValue element.get 'row'
			# 	element.field('row').observe -> row.set element.get 'row'

			# 	row: row
			# 	barItem:
			# 		elementType:'CompetitiveListElement', elementId:el.get('id'), decisionId:@obj.get 'id'

			# @data = clientContents

			@data = @clientValue()

		methods:
			parse: (view, descriptor) ->
				@agora.background.httpRequest "#{@agora.background.apiRoot}parse.php", 
					data:
						descriptor:descriptor
					cb:(response) =>
						# console.log response
						@data.set descriptor:response, icon:taxonomy.icon response.product.type
