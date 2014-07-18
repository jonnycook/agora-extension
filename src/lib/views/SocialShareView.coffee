define ['View'], (View) ->
	class SocialShareView extends View
		@nextId:1
		@id: -> @nextId++
		init: (args) ->
			if args.id
				@decision = @agora.modelManager.getInstance('Decision', args.id)
			else if args.viewId
				view = @agora.View.clientViews[args.viewId].view
				if view.name == 'compare/Compare'
					@decision = view.currentDecision()

			@data =
				access:@clientValue @decision.field 'access'
				url:@agora.public.route @decision
				owner:@decision.record.storeId == @agora.user.saneId()



		methods:
			setAccess: (view, access) ->
				@decision.set 'access', access