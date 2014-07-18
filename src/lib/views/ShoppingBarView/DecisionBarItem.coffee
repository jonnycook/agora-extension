define ['View', 'Site', 'Formatter', 'util', 'underscore', 'views/items/DecisionItem', 'taxonomy'], (View, Site, Formatter, util, _, DecisionItem, taxonomy) ->	
	class DecisionBarItem extends DecisionItem
		onClick: ->
				util.shoppingBar.pushDecisionState @obj