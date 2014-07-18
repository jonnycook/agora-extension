define ['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], (View, Site, Formatter, util, _, BarItem) ->
	class ProductBarItem extends BarItem
		init: ->
			product = @obj
			@data =
				type: 'Product'
				barItemData:
					id: product.get 'id'
					title:@ctx.clientValueNamed 'ProductBarItem.title', product.field('title'), product.displayValue('title')
					site: name:product.get('siteName'), url:product.get('siteUrl')
					price:@ctx.clientValueNamed 'ProductBarItem.price', product.field('price'), product.displayValue('price')
					image:@ctx.clientValueNamed 'ProductBarItem.image', product.field('image'), product.displayValue('image')
					url:product.get 'url'
					sid:product.get 'productSid'
					lastFeeling:util.lastFeeling @ctx, product
					status:@ctx.clientValue product.field 'status'
					purchased:@ctx.clientValue product.field 'purchased'


		dropped: (obj) ->
			tracking.event 'ShoppingBar', 'createDecision'
			obj = util.resolveObject obj
			list = @itemView.agora.modelManager.getModel('List').create()
			list.get('contents').add @obj
			list.get('contents').add obj

			if @itemView.descriptor
				list.set 'descriptor', @itemView.descriptor.get('descriptor')

			# listElement = list.get('elements').find (instance) => instance.get('element_id') == obj.get('id') && instance.get('element_type') == obj.modelName

			decision = @itemView.agora.modelManager.getModel('Decision').create list_id:list.get 'id'
			# decision.get('selection').add listElement

			_activity 'convert', @itemView.element, @obj, obj, decision 

			decision

		methods:
			click: ->