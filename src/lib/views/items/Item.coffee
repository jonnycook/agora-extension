define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class Item
		getData: (cb) ->
			cb @data

		observe: (object, observer) ->
			@ctx.observe object, observer if object