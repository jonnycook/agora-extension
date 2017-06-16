define ['View', 'Site', 'Formatter', 'util', 'underscore', 'views/items/DecisionItem', 'taxonomy'], (View, Site, Formatter, util, _, DecisionItem, taxonomy) ->	
	class DecisionTileItem extends DecisionItem
		selectionObj: (obj) ->
			obj.compareViewId = @view.compareView.id
			obj

		onClick: ->
			@view.compareView.pushState
				dropped: (element) => @obj.get('list').get('contents').add util.resolveObject element
				ripped: (view) => view.element.delete true
				contents: => @obj.get('considering')
				contentMap: (el) => elementType:'ListElement', elementId:el.get('id'), decisionId:@obj.get 'id'
				state: 'Decision'
				args: decisionId: @obj.get 'id'
				breadcrumb: @obj
				obj:@obj
