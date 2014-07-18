define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class DataView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (obj) =>
				@data = @ctx.clientArray obj.get('data'), (datum, onRemove) =>
					ctx = @context()
					onRemove -> ctx.destruct()
					id:datum.get 'id'
					type:ctx.clientValue datum.field 'type'
					url:ctx.clientValue datum.field 'url'
					title:ctx.clientValue datum.field 'title'
					text:ctx.clientValue datum.field 'text'
					comment:ctx.clientValue datum.field 'comment'
				done()

		methods:
			delete: (view, id) ->
				@agora.modelManager.getInstance('Datum', id).delete()