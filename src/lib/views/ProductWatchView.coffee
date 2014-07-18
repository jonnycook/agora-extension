define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->
	class ProductPopupView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (@product, @element) =>
				if @product
					@productWatch = @agora.modelManager.getModel('ProductWatch').find product_id:@product.productId()
					
					@data = if @productWatch
						conditionOption:@product.get('siteName') == 'Amazon'
						enableThreshold:@productWatch.get('enable_threshold')
						enableIncrement:@productWatch.get('enable_increment')
						enableStock:@productWatch.get('enable_stock')
						condition: switch @productWatch.get('watch_condition')
								when 0 then 'listing'
								when 1 then 'new'
								when 2 then 'refurbished'
								when 3 then 'used'
						threshold:@productWatch.get('watch_threshold')
						increment:@productWatch.get('watch_increment')
					else
						conditionOption:@product.get('siteName') == 'Amazon'
						enableThreshold:false
						enableIncrement:false
						enableStock:false
						condition:'listing'
						threshold:''
						increment:''

				done()
					
		methods:
			submit: (view, data) ->
				if !@productWatch
					@productWatch = @agora.modelManager.getModel('ProductWatch').create product_id:@product.productId()

				@productWatch.set 'watch_condition', switch data.condition
					when 'listing' then 0
					when 'new' then 1
					when 'refurbished' then 2
					when 'used' then 3
				@productWatch.set 'enable_stock', data.enableStock
				@productWatch.set 'enable_threshold', data.enableThreshold
				@productWatch.set 'enable_increment', data.enableIncrement
				@productWatch.set 'watch_increment', data.increment
				@productWatch.set 'watch_threshold', data.threshold

		# 	remove: ->
		# 		Bag = @agora.modelManager.getModel 'Bag'
		# 		Product = @agora.modelManager.getModel 'Product'
				
		# 		bag = Bag.withId @args.bagId
		# 		product = Product.getBySid @args.siteName, @args.productSid
				
		# 		@agora.removeFromBag product, bag

		# 	setSelected: (view, selected) ->
		# 		if @decision
		# 			if selected
		# 				_activity 'decision.select', @decision, @element.get('element')
		# 				@decision.get('selection').add @element
		# 			else
		# 				@decision.get('selection').remove @element
		# 				_activity 'decision.deselect', @decision, @element.get('element')


		# 	dismiss: ->
		# 		if @decision
		# 			util.dismissDecisionElement @decision, @element
