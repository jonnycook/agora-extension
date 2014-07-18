define ['View', 'Site', 'Formatter', 'util', 'underscore', './Item', 'taxonomy'], (View, Site, Formatter, util, _, Item, taxonomy) ->	
	class DecisionItem extends Item
		selectionObj: (obj) -> obj
		init: (done) ->
			listSize = @itemView.clientValueNamed 'listSize'
			updateListSize = => listSize.set @obj.get('list').get('contents').length()
			@observe @obj.get('list').get('contents'), updateListSize
			updateListSize()

			selectionSize = @itemView.clientValueNamed 'selectionSize'
			updateSelectionSize = => selectionSize.set @obj.get('selection').length()
			@observe @obj.get('selection'), updateSelectionSize
			updateSelectionSize()

			selection = @itemView.clientArrayNamed "#{@obj.modelName}.selection"

			util.syncArrays @ctx, @obj.get('selection'), selection, (element, onRemove, i) =>
				@selectionObj
					elementType: element.modelName
					elementId: element.get('id')

			descriptor = @obj.get('list').field('descriptor')

			@data = 
				type: 'Decision'
				barItemData:
					listSize:listSize
					selectionSize:selectionSize
					selection:selection
					preview:util.listPreview @ctx.context(), @obj.get('list').get('elements')
					descriptor: @itemView.clientValue descriptor
					icon:@itemView.clientValue descriptor, -> taxonomy.icon descriptor.get()?.product?.type
					shared:@ctx.clientValue @obj.field 'shared'

		dropped: (element, dropAction) =>
			obj = util.resolveObject element
			@obj.get('list').get('contents').add obj
			_activity 'add', @obj, obj
			null

		methods:
			click: ->
				@onClick()
