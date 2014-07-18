define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->
	class BeltBarItem extends BarItem
		init: ->
			count = @itemView.clientValue()
			updateCount = => count.set @obj.get('elements').length()
			@observe @obj.get('elements'), updateCount
			updateCount()

			@data =
				type: 'Belt'
				barItemData:
					shared:@ctx.clientValue @obj.field 'shared'
					preview:util.listPreview @ctx, @obj.get('elements')
					count:count

		dropped: (obj) ->
			obj = util.resolveObject obj#if element instanceof View then element.obj else element
			@obj.get('contents').add obj
			_activity 'add', @obj, obj

		methods:
			click: ->
				util.shoppingBar.pushBeltState @obj
