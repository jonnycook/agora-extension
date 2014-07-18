define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class AddArgumentsView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId#"#{args.type}/#{args.id}"
		# init: (id) ->
		# 	@product = @agora.modelManager.getInstance 'Product', id
		# 	console.log @product

		initAsync: (args, done) ->
			@resolveObject args, (@obj, @element) =>
				@data = util.arguments @ctx, obj
				done()

		methods:
			add: (view, pro, against, thought) ->
				@agora.modelManager.getModel('Argument').create element_type:@obj.modelName, element_id:@obj.get('id'), thought:thought, for:pro, against:against, timestamp:new Date()

			delete: (view, id) ->
				@agora.modelManager.getInstance('Argument', id).delete()