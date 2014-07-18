define ['View', 'Site', 'Formatter', 'util', 'underscore', './ListTileItem'], (View, Site, Formatter, util, _, ListTileItem) ->
	class BundleTileItem extends ListTileItem
		type: 'Bundle'
