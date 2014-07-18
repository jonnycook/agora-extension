define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class ContactView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		# init: (args, done) ->
		# 	@resolveObject args, (obj) =>
		# 		@data = @ctx.clientArray obj.get('data'), (datum, onRemove) =>
		# 			ctx = @context()
		# 			onRemove -> ctx.destruct()
		# 			id:datum.get 'id'
		# 			type:ctx.clientValue datum.field 'type'
		# 			url:ctx.clientValue datum.field 'url'
		# 			title:ctx.clientValue datum.field 'title'
		# 			text:ctx.clientValue datum.field 'text'
		# 			comment:ctx.clientValue datum.field 'comment'
		# 		done()

		methods:
			submit: (view, subject, message) ->
				@agora.background.httpRequest "#{@agora.background.apiRoot}contact.php", 
					method: 'post'
					data:
						subject:subject
						message:message
