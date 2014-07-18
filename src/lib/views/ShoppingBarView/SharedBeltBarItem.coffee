define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->
	class SharedBeltBarItem extends BarItem
		init: ->
			userId = @itemView.objectReference.get('object_user_id')
			@user = @itemView.agora.modelManager.getInstance('User', "G#{userId}")

			@data =
				type: 'SharedBelt'
				barItemData:
					preview:util.listPreview @ctx, @user.get('rootElements')

		dropped: (obj) ->
			obj = util.resolveObject obj#if element instanceof View then element.obj else element
			rootEl = @itemView.agora.modelManager.getModel('RootElement').create user_id:@user.get('id'), element_type:obj.modelName, element_id:obj.get 'id'
			_activity 'add', @user, obj

		methods:
			click: ->
				util.shoppingBar.pushRootState @user
				# shoppingBarView.pushState
				# 	state: 'root'
				# 	contents: => @user.get('rootElements')
				# 	contentMap: (el) => elementType:'RootElement', elementId:el.get('id')
				# 	ripped: (view) ->	view.element.delete()
				# 	dropped: (element) =>
				# 		obj = util.resolveObject element#if element instanceof View then element.obj else element
				# 		rootEl = @itemView.agora.modelManager.getModel('RootElement').create user_id:@user.get('id'), element_type:obj.modelName, element_id:obj.get 'id'
