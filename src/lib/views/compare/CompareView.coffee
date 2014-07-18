define ['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy', 'model/ObservableValue'], (View, Site, Formatter, util, _, taxonomy, ObservableValue) ->	
	class CompareView extends View
		@nextId: 1
		@id: (args) -> @nextId++

		currentDecision: ->
			for i in [@path.length-1..0]
				if @path[i].state == 'Decision'
					return @path[i].obj

		initAsync: (args, done) ->
			@path = []
			@ctx = @context()
			@data = @clientValue()

			@public = args.public

			init = =>
				@pushState
					state: 'Decision'
					dropped: (element) => @decision.get('list').get('contents').add util.resolveObject element
					ripped: (view) => view.element.delete()
					contents: => if @public then @decision.get('listElements') else @decision.get('considering')
					contentMap: (el) => elementType:'ListElement', elementId:el.get('id'), decisionId:@decision.get 'id'
					args: decisionId: @decision.get 'id'
					breadcrumb: @decision
					obj:@decision
				done()

			if args.decision.id
				@decision = @agora.modelManager.getInstance 'Decision', args.decision.id
				init()
			else
				@resolveObject args.decision, (@decision) =>
					init()

		currentState: -> @path[@path.length - 1]

		initState: (state) ->
			@stateCtx ?= @context()
			@stateCtx.clear()


			if @public
				@displayOptions = new ObservableValue {displayComponents:['title', 'price', 'rating']}, true
			else
				@displayOptions = @currentState().obj.field('display_options') 



			breadcrumbs = []



			for {breadcrumb:breadcrumb} in @path
				breadcrumbs.push if breadcrumb.modelName == 'Decision'
					util.listPreview @stateCtx.context(), breadcrumb.get('list').get('elements')
				else if breadcrumb.modelName == 'Product'
					@stateCtx.clientValue breadcrumb.field 'image'

			if state.state == 'Decision'
				clientContents = @stateCtx.clientArray state.contents(), (el) => _.merge state.contentMap(el), compareViewId:@id

				if @displaying
					util.unsync @displaying
				@displaying = clientContents

				data = 
					contents:clientContents
					state:state.state
					args:state.args
					breadcrumbs:breadcrumbs

				if state.obj.modelName == 'Decision'
					decision = state.obj
					data.dismissalList = @stateCtx.clientArray decision.get('dismissed'), (el, onRemove) =>
						obj = el.get('element')
						if obj.modelName == 'Product'
							obj.get 'image'
						else if obj.modelName == 'Decision'
							ctx = @stateCtx.context()
							onRemove -> ctx.destruct()
							util.listPreview ctx, obj.get('selection')
						else if obj.modelName == 'Bundle'
							ctx = @stateCtx.context()
							onRemove -> ctx.destruct()
							util.listPreview ctx, obj.get('elements')

					data.properties = @stateCtx.clientValue()
					updateProperties = =>
						products = []
						state.contents().each (el) ->
							for product in util.resolveProducts el.get('element')
								products.push product

						@stateCtx.context('properties').destruct()

						properties = []
						displayOptions = @displayOptions.get() ? {displayComponents:[]}


						for prop in [
								{label:'Title', path:'title', count:products.length}
								{label:'Rating', path:'rating'}
								{label:'Price', path:'price', count:products.length}
								{label:'Feelings', path:'feelings', count:products.length}
								# {label:'Arguments', path:'arguments'}
								]
							properties.push
								path:prop.path
								label:prop.label
								count:prop.count
								selected:@stateCtx.context('properties').clientValue displayOptions.displayComponents.indexOf(prop.path) != -1

						data.properties.set properties					

						descriptorProduct = decision.get('list').get('descriptor')?.product?.type ? decision.get('list').get('descriptor')?.product

						done = =>
							setTimeout (=>
								properties[1].count = propertyCounts.rating
								for propertyPath in propertyPaths
									properties.push
										path:propertyPath
										label:propertyPath.split('.')[1]
										selected:@stateCtx.context('properties').clientValue displayOptions.displayComponents.indexOf(propertyPath) != -1
										count:propertyCounts[propertyPath] ? 0

								data.properties.set properties
							), 1000


						propertyPaths = if descriptorProduct then taxonomy.properties(descriptorProduct) else []

						propertyCounts = rating:0
						count = products.length

						Product = @agora.modelManager.getModel 'Product'

						for product in products
							Product.siteProduct product, (siteProduct) ->
								if siteProduct
									if siteProduct.site.hasFeature 'rating'
										propertyCounts.rating++

									if descriptorProduct
										siteProduct.usedProperties descriptorProduct, (usedProperties) ->
											for property in usedProperties
												propertyCounts[property] ?= 0
												++ propertyCounts[property]

											done() if !-- count
									else
										done() if !-- count
								else
									done() if !-- count
										

					updateProperties()
					util.observeContents @stateCtx, decision.get('considering'), updateProperties

					data.descriptor = @stateCtx.clientValue()
					updateDescriptor = =>
						descriptor = decision.get('list').get('descriptor')?.descriptor
						data.descriptor.set descriptor ? ''
					updateDescriptor()

					data.icon = @stateCtx.clientValue()
					updateIcon = =>
						data.icon.set taxonomy.icon decision.get('list').get('descriptor')?.product?.type
					updateIcon()

					@stateCtx.observe decision.get('list').field('descriptor'), ->
						updateDescriptor()
						updateProperties()
						updateIcon()

				@data.set data

			else if state.state == 'Product'
				@data.set
					state:state.state
					breadcrumbs:breadcrumbs
					productId:state.obj.get 'id'

		pushState: (state) ->
			if !state.state && @state
				state.state = @state

			@path.push state
			@initState state

		popState: ->
			@path.pop()
			@initState @currentState()

		ripped: (data) ->
			@currentState().ripped data

		dropped: (data) ->
			@currentState().dropped data

		methods:
			up: (view) ->
				@popState()

			move: (view, elementData, toData, dropAction) ->
				toView = @agora.View.clientViews[toData.view].view
				elementView = @agora.View.clientViews[elementData.view].view				
				elementView.delete()
				toView.dropped elementView, dropAction

			drop: (view, elementData, onData, dropAction) ->
				@resolveElements elementData, onData, (element, onView) ->
					onView.dropped element, dropAction

			reorder: (view, fromIndex, toIndex) ->
				util.reorder @currentState().contents(), fromIndex, toIndex

			remove: (view, elementData, fromData) ->
				fromView = @agora.View.clientViews[fromData.view].view
				elementView = @agora.View.clientViews[elementData.view].view
				fromView.ripped elementView

			split: (view, selection) ->
				cont = @agora.modelManager.getModel('List').create()
				decision = @agora.modelManager.getModel('Decision').create list_id:cont.get 'id'

				for viewId in selection
					view = @agora.View.clientViews[viewId].view
					cont.get('contents').add view.obj
					element = view.element
					view.element.delete()

				if @path.length == 1
					obj = decision
					rootEl = @agora.modelManager.getModel('RootElement').create element_type:obj.modelName, element_id:obj.get 'id'
				else
					@path[@path.length - 2].dropped decision

			extract: (view, selection) ->
				parent = if @path.length == 1
					shoppingBarView
				else
					@path[@path.length - 2]
					
				for viewId in selection
					view = @agora.View.clientViews[viewId].view
					parent.dropped view.obj 
					view.element.delete()

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

			gotoRoot: ->
				@path = [@path[0]]
				@initState @path[0]

			gotoPath: (view, index) ->
				@path = @path.slice 0, index + 1
				@initState @path[index]

			restore: (view, index) ->
				decision = @currentState().obj
				decision.get('considering').add decision.get('dismissed').get(index)

			removeDismissed: (view, index) ->
				decision = @currentState().obj
				decision.get('dismissed').get(index).delete()

			clearDismissalList: ->
				@currentState().breadcrumb.get('dismissalList').get('contents').removeAll()

			openProduct: (view, productData) ->
				@resolveObject productData, (product) =>
					@pushState
						state: 'Product'
						breadcrumb: product
						obj: product

			setProperty: (view, name, selected) ->
				displayOptions = @displayOptions.get() ? {displayComponents:[]}
				if selected
					if displayOptions.displayComponents.indexOf(name) == -1
						displayOptions.displayComponents.push name
				else
					_.pull displayOptions.displayComponents, name
				@displayOptions.set displayOptions

