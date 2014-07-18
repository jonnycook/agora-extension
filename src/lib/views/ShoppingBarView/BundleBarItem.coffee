define ['View', 'Site', 'Formatter', 'util', 'underscore', './ListBarItem'], (View, Site, Formatter, util, _, ListBarItem) ->
	class BundleBarItem extends ListBarItem
		type: 'Bundle'