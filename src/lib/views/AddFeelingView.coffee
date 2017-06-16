define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class AddFeelingView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (@obj) =>
				@data = util.feelings @ctx, @obj
				done()

		methods:
			add: (view, positive, negative, thought) ->
				# negative = 0
				# positive = 0
				# for i in [0...feeling.length]
				# 	char = feeling[i]

				# 	if char == '-'
				# 		++negative
				# 	else if char == '+'
				# 		++positive
				# 	else
				# 		break

				# for j in [feeling.length-1...0]
				# 	char = feeling[j]

				# 	if char == '-'
				# 		++negative
				# 	else if char == '+'
				# 		++positive
				# 	else
				# 		break


				# thought = feeling.substring(i, j+1).trim()
				@agora.modelManager.getModel('Feeling').create element_type:@obj.modelName, element_id:@obj.get('id'), thought:thought, positive:positive, negative:negative, timestamp:new Date()

			delete: (view, id) ->
				@agora.modelManager.getInstance('Feeling', id).delete()
