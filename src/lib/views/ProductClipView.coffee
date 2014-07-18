define ['View', 'Formatter'], (View, Formatter) ->
	class ProductClipView extends View
		# @filter: (agora, args, cb) ->
		# 	if args.productSid
		# 		cb args
		# 	else if args.productUrl
		# 		Product = agora.modelManager.getModel 'Product'
		# 		Product.getFromUrl args.productUrl, args, (product) ->
		# 			args.productSid = product.get('productSid')
		# 			cb args

		@nextId: 1
		@id: (args) -> @nextId++
		
		initAsync: (args, done) ->
			__ = (product) =>
				@data = 
					title:@clientValueNamed 'ProductClipView.title', product.field('title'), product.displayValue 'title'
					site:@clientValueNamed 'ProductClipView.site', product.field 'siteName'
					price:@clientValueNamed 'ProductClipView.price', product.field('price'), product.displayValue 'price'
				done()

			if args.elementType && args.elementId
				__ @agora.modelManager.getInstance(args.elementType, args.elementId).get('element')
			else
				@agora.product args, __

		getData: (cb) ->
			cb @data