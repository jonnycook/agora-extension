define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy'], (View, Site, Formatter, util, _, taxonomy) ->
	class DecisionPreviewView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (@decision) =>		
				listSize = @clientValueNamed 'listSize'
				updateListSize = => listSize.set decision.get('list').get('contents').length()
				@observeObject decision.get('list').get('contents'), updateListSize
				updateListSize()

				selectionSize = @clientValueNamed 'selectionSize'
				updateSelectionSize = => selectionSize.set decision.get('selection').length()
				@observeObject decision.get('selection'), updateSelectionSize
				updateSelectionSize()

				selection = @clientArrayNamed "#{decision.modelName}.selection"

				util.syncArrays @ctx, decision.get('selection'), selection, (element, onRemove, i) =>
					elementType: element.modelName
					elementId: element.get('id')

				descriptor = decision.get('list').field('descriptor')

				@data = 
					listSize:listSize
					selectionSize:selectionSize
					selection:selection
					preview:util.listPreview @ctx.context(), decision.get('list').get('elements')
					descriptor: @clientValue descriptor
					icon:@clientValue descriptor, -> taxonomy.icon descriptor.get()?.product?.type
					shared:@ctx.clientValue decision.field 'shared'
				done()
