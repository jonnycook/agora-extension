define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->
	class UnauthorizedBarItem extends BarItem
		init: ->
			@data =
				type: 'Unauthorized'
				barItemData:{}
