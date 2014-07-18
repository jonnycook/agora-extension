define ['View', 'Site', 'Formatter', 'util', 'underscore', './TileItem'], (View, Site, Formatter, util, _, TileItem) ->
	class ProductTileItem extends TileItem
		init: ->
			product = @obj

			@properties = @ctx.clientArray()

			@propertiesCtx = @ctx.context()

			decision = @view.compareView.currentState().obj

			updateProperties = =>
				Product = @view.agora.modelManager.getModel 'Product'

				Product.siteProduct product, (siteProduct) =>
					properties = []
					@propertiesCtx.clear()

					displayOptions = @view.compareView.displayOptions.get() ? {displayComponents:[]}

					for property in displayOptions.displayComponents
						properties.push property:property, value:switch property
							when 'price'
								# site = Site.site product._get 'siteName'
								# price:@propertiesCtx.clientValue(product.field('price'), -> product.get 'displayPrice'), siteName:site.name, siteIcon:site.icon
								product.get 'id'
							when 'rating'
								if siteProduct.site.hasFeature 'rating'
									rating:@propertiesCtx.clientValue product.field('rating'), product.displayValue 'rating'
									ratingCount:@propertiesCtx.clientValue product.field('ratingCount'), product.displayValue 'ratingCount'
							when 'title'
								@propertiesCtx.clientValue product.field('title'), product.displayValue 'title'

							when 'feelings'
								util.feelings @propertiesCtx, product

							when 'arguments'
								util.arguments @propertiesCtx, product

							else
								if siteProduct
									cv = @propertiesCtx.clientValue()
									siteProduct.property property, (value) -> cv.set value
									cv

					@properties.setArray properties

			updateProperties()

			@ctx.observe @view.compareView.displayOptions, updateProperties

			@data =  
				type: 'Product'
				barItemData:
					id:product.get 'id'
					url:product.get 'url'
					sid:product.get 'productSid'
					site:name:product.get('siteName'), url:product.get('siteUrl')
					
					lastFeeling:util.lastFeeling @ctx, product
					lastArgument:util.lastArgument @ctx, product

					image:@view.clientValueNamed 'ProductBarItem.image', product.field('image'), product.displayValue 'image'
					# title:@view.clientValueNamed 'ProductBarItem.title', product.field('title')

					# price:@view.clientValueNamed 'ProductBarItem.price', product.field('displayPrice')

					properties:@properties

		dropped: (obj, dropAction) ->
			tracking.event 'Compare', 'createDecision'
			obj = util.resolveObject obj
			list = @view.agora.modelManager.getModel('List').create()
			list.get('contents').add @obj
			list.get('contents').add obj

			if @view.descriptor
				list.set 'descriptor', @view.descriptor.get('descriptor')

			# listElement = list.get('elements').find (instance) => instance.get('element_id') == obj.get('id') && instance.get('element_type') == obj.modelName

			decision = @view.agora.modelManager.getModel('Decision').create list_id:list.get 'id'
			# decision.get('selection').add listElement

			_activity 'convert', @view.element, @obj, obj, decision 

			decision

		methods:
			click: ->
				@view.compareView.pushState
					state: 'Product'
					breadcrumb: @obj
					obj: @obj
