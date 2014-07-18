define ['View', 'Site', 'Formatter', 'util', 'underscore', './ListBarItem'], (View, Site, Formatter, util, _, ListBarItem) ->
	class SessionBarItem extends ListBarItem
		type: 'Session'
		itemData: ->
			title: @itemView.clientValue @obj.field 'title'

		methods:
			setTitle: (view, title) ->
				@obj.set 'title', title
			toggle: (view) ->
				if @obj.get 'collapsed'
					@obj.set 'collapsed', false
				else 
					@obj.set 'collapsed', true