define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy', 'views/ItemView'], (View, Site, Formatter, util, _, taxonomy, ItemView) ->	
	class BarItemView extends ItemView
		@nextId: 1
		@id: (args) -> 
			if args.container
				"#c.{args.container.type}.#{args.container.id}.#{args.type}.#{args.id}"
			else if args.type && args.id
				"#{args.type}.#{args.id}"
			else if args.elementType && args.elementId
				id = "#{args.elementType}.#{args.elementId}"
				if args.decisionId
					id += ".#{args.decisionId}"
				id
			else
				@nextId++

		itemClass: (type) -> "views/ShoppingBarView/#{type}BarItem"
