define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy', 'views/ItemView'], (View, Site, Formatter, util, _, taxonomy, ItemView) ->	
	class TileItemView extends ItemView
		@nextId: 1
		@id: (args) -> 
		# 	if args.container
		# 		"#c.{args.container.type}.#{args.container.id}.#{args.type}.#{args.id}"
		# 	else if args.type && args.id
		# 		"#{args.type}.#{args.id}"
		# 	else if args.elementType && args.elementId
		# 		id = "#{args.elementType}.#{args.elementId}"
		# 		if args.decisionId
		# 			id += ".#{args.decisionId}"
		# 		id
		# 	else
				@nextId++

		itemClass: (type) -> "views/compare/#{type}TileItem"

		initAsync: (args, done) ->
			@compareView = @agora.View.views['compare/Compare'][args.compareViewId]
			@public = @compareView
			super

		methods:
			delete: ->
				@delete()

			click: (view) ->
				@item?.methods?.click?.call @item, view

			reorder: (view, fromIndex, toIndex) ->
				util.reorder @obj.get('contents'), fromIndex, toIndex

			add: (view, type) ->
				composite = @agora.modelManager.getModel('Composite').createWithType type
				@obj.get('contents').add composite

			setSelected: (view, selected) ->
				if @decision
					if selected
						@decision.get('selection').add @element
						_activity 'decision.select', @decision, @element.get('element')
					else
						@decision.get('selection').remove @element
						_activity 'decision.deselect', @decision, @element.get('element')
			dismiss: ->
				if @decision
					util.dismissDecisionElement @decision, @element

			deleteFeeling: (view, id) ->
				@agora.modelManager.getInstance('Feeling', id).delete()

			deleteArgument: (view, id) ->
				@agora.modelManager.getInstance('Argument', id).delete()
