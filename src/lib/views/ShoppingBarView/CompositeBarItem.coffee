define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->	
	class CompositeBarItem extends BarItem
		init: ->
			composite = @obj
			@data =  
				type: 'Composite'
				barItemData:
					type: composite.get('type')

		dropped: (obj) ->
			obj = util.resolveObject obj
			@obj.get('additionalContents').add obj
			null

			
		methods:
			click: ->
				shoppingBarView.pushState
					dropped: (obj) =>
						obj = util.resolveObject obj
						@obj.get('additionalContents').add obj

					ripped: (view) =>
						@obj.get('additionalElements').remove view.element

					contents: => @obj.get('contents')

					contentMap: (el) ->
						if el.modelName == 'CompositeSlot'
							type:'CompositeSlot', id:el.get 'id'
						else
							elementType:'CompositeElement', elementId:el.get 'id'
