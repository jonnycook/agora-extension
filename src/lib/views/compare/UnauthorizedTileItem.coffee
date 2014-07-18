define ['View', 'Site', 'Formatter', 'util', 'underscore', './TileItem'], (View, Site, Formatter, util, _, TileItem) ->
	class UnauthorizedTileItem extends TileItem
		init: ->
			@data =
				type: 'Unauthorized'
				barItemData:{}
