define ['View', 'Site', 'Formatter', 'util', 'underscore', 'model/ObservableValue'], (View, Site, Formatter, util, _, ObservableValue) ->	
	class ShoppingBarView extends View
		constructor: ->
			window.shoppingBarView = @
			super

		setUser: (user) ->
			if @unseenSharedObjectsCount
				@unseenSharedObjectsCount.destruct()

			@user = user

			if user
				@unseenSharedObjectsCount = @clientValue @agora.user.get('unseenSharedWithMe').length()

				@agora.user.get('unseenSharedWithMe').observe (mutation) =>
					@unseenSharedObjectsCount.set mutation.length

				@clearState()
				util.shoppingBar.pushRootState @user

		init: ->
			@shareObject = new ObservableValue()
			@path = []
			@ctx = @context()
			@data = {}
			@updaterStatus = @clientValue @agora.updater.status
			@updaterMessage = @clientValue @agora.updater.message

			@barContentsData = @clientValue()

			@isShared = @ctx.clientValue @shareObject, (value) -> value && value.isShared

			@setUser @agora.user

			@data =
				updaterStatus:@updaterStatus
				updaterMessage:@updaterMessage
				barContents:@barContentsData
				unseenSharedObjectsCount:@unseenSharedObjectsCount

		currentState: -> @path[@path.length - 1]

		updateShareObject: ->
			object = null
			for i in [@path.length-1..0]
				if @path[i].isShared()
					object = @path[i].shareObject()
					break

			isShared = null
			if object
				isShared = true
			else
				isShared = false
				object = @currentState().shareObject()

			shareObject = isShared:isShared, object:object

			if !_.isEqual @shareObject.get(), shareObject
				@shareObject.set shareObject

		initState: (state) ->
			if @stateCtx
				@stateCtx.destruct()

			@stateCtx = @ctx.context()

			clientContents = @clientArray @stateCtx, state.contents(), state.contentMap

			@updateShareObject()

			if @displaying
				util.unsync @displaying

			@displaying = clientContents
			@barContentsData.set
				moveUp: state.moveUp ? @path.length > 1
				contents: clientContents
				state: state.state
				args: state.args
				direction: state.direction ? 'ltr'
				shared: @isShared

		pushState: (state) ->
			if !state.state && @state
				state.state = @state
			state.shared().observeWithTag state, => @updateShareObject()

			@path.push state
			@initState state

		popState: ->
			@currentState().shared().stopObservingWithTag @currentState()
			@path.pop()
			@initState @currentState()

		clearState: ->
			@path = []

		ripped: (data) ->
			@currentState().ripped data

		dropped: (data) ->
			@currentState().dropped data

		methods:
			up: (view) ->
				@popState()

			move: (view, elementData, toData, dropAction) ->
				elementView = @agora.View.clientViews[elementData.view].view				
				elementView.delete()

				if toData == 'up'
					@path[@path.length - 2].dropped elementView, dropAction
				else
					toView = @agora.View.clientViews[toData.view].view
					toView.dropped elementView, dropAction

			drop: (view, elementData, onData, dropAction) ->
				if onData == 'up'
					@resolveElements elementData, (element) =>
						@path[@path.length - 2].dropped element, dropAction
						if element.isA('Product') || element.isA('ProductVariant')
							view.callMethod 'productAdded', [modelName:element.modelName, instanceId:element.get 'id']

				else if onData == 'priceWatch'
					@resolveElements elementData, (element) =>
						if element.isA('Product') || element.isA('ProductVariant')
							view.callMethod 'productAdded', [modelName:element.modelName, instanceId:element.get 'id']

				else
					@resolveElements elementData, onData, (element, onView) =>
						onView.dropped element, dropAction
						if element.isA('Product') || element.isA('ProductVariant')
							view.callMethod 'productAdded', [modelName:element.modelName, instanceId:element.get 'id']

			reorder: (view, fromIndex, toIndex) ->
				util.reorder @currentState().contents(), fromIndex, toIndex

			remove: (view, elementData, fromData) ->
				fromView = @agora.View.clientViews[fromData.view].view
				elementView = @agora.View.clientViews[elementData.view].view
				fromView.ripped elementView

			web: ->
				obj = @agora.modelManager.instance 'Decision', @currentState().args.decisionId
				chrome.tabs.create url:"http://agora.sh/Agora/webapp.php?decisionId=#{obj.record.globalId()}"

			wrap: (view, type, selection) ->
				cont = obj = null
				if type == 'decision'
					cont = @agora.modelManager.getModel('List').create()
					obj = @agora.modelManager.getModel('Decision').create list_id:cont.get 'id'
				else
					obj = cont = switch type
						when 'bundle'
							@agora.modelManager.getModel('Bundle').create()
						when 'session'
							@agora.modelManager.getModel('Session').create title:'New Session'


				parent = if type == 'session'
					null
				else
					false

				for viewId in selection
					view = @agora.View.clientViews[viewId].view
					cont.get('contents').add view.obj
					element = view.element

					if parent == false || parent != null
						if element.modelName == 'RootElement'
							parent = null

						else
							if parent
								if !element.get('parent').equals parent
									parent = null
							else
								parent = element.get('parent')

					view.element.delete()

				if parent == null
					@dropped obj
				else
					parent.get('contents').add obj

			delete: (view, selection) ->
				@agora.View.clientViews[viewId].view.element.delete() for viewId in selection

			extract: (view, selection) ->
				if @path.length > 1
					for viewId in selection
						view = @agora.View.clientViews[viewId].view
						@path[@path.length - 2].dropped view.obj
						view.element.delete()

			split: (view, selection) ->
				if @path.length > 1
					cont = @agora.modelManager.getModel('List').create()
					decision = @agora.modelManager.getModel('Decision').create list_id:cont.get 'id'

					for viewId in selection
						view = @agora.View.clientViews[viewId].view
						cont.get('contents').add view.obj
						view.element.delete()

					@path[@path.length - 2].dropped decision


			# addCollection: (view, elementData) ->
			# 	@resolveElements elementData, (element) => 
			# 		obj = if element instanceof View then element.obj else element
			# 		collectionEl = @agora.modelManager.getModel('CollectionElement').create()

			# 		list = if obj.modelName == 'List'
			# 			obj
			# 		else
			# 			l = @agora.modelManager.getModel('List').create collapsed:true
			# 			l.get('contents').add obj
			# 			l
			# 		collectionEl.set 'element_type', list.modelName
			# 		collectionEl.set 'element_id', list.get 'id'

			# enterCollections: (view) ->
			# 	@oldPath = @path
			# 	@path = []
			# 	@state = 'collections'
			# 	@pushState
			# 		direction: 'rtl'
			# 		# moveUp:false
			# 		contents: => @agora.modelManager.getModel('CollectionElement').all()
			# 		contentMap: (el) => elementType:'CollectionElement', elementId:el.get('id')
			# 		ripped: (view) ->	view.element.delete()
			# 		dropped: (element) =>
			# 			obj = if element instanceof View then element.obj else element
			# 			collectionEl = @agora.modelManager.getModel('CollectionElement').create()

			# 			list = if obj.modelName == 'List'
			# 				obj
			# 			else
			# 				l = @agora.modelManager.getModel('List').create collapsed:true
			# 				l.get('contents').add obj
			# 				l
			# 			collectionEl.set 'element_type', list.modelName
			# 			collectionEl.set 'element_id', list.get 'id'

			# exitCollections: ->
			# 	@path = @oldPath
			# 	delete @state
			# 	@initState @path[@path.length - 1]
