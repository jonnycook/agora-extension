define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->	
	class CompositeSlotBarItem extends BarItem
		@id: (args) -> args.id
		init: (id) ->
			slot = @obj
			@data =  
				type: 'CompositeSlot'
				barItemData:
					type: slot.get('type')
					id: @obj.get('id')
					elementType:@ctx.clientValue slot.field('element_type')
					elementId:@ctx.clientValue slot.field('element_id')

		dropped: (element) ->
			obj = util.resolveObject element
			@obj.set 'element_type', obj.modelName
			@obj.set 'element_id', obj.get 'id'
			null

		ripped: (element) ->
			@obj.set 'element_type', null
			@obj.set 'element_id', null
