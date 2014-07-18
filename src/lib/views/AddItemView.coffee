define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class AddItemView extends View
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

		# methods:
		# 	setRow: (view, itemViewId, row) ->
		# 		element = @agora.View.clientViews[itemViewId].view.element
		# 		@obj.get('elements').for(element).set 'row', row
								
