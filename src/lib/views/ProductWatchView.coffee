define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->
	class ProductWatchView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (@product, @element) =>
				if @product
					@productWatch = @agora.modelManager.getModel('ProductWatch').find product_id:@product.productId()
					
					@data = if @productWatch
						enabled:@productWatch.get('enabled')
						conditionOption:@product.get('siteName') == 'Amazon'
						enableThreshold:@productWatch.get('enable_threshold')
						enableIncrement:@productWatch.get('enable_increment')
						enableStock:@productWatch.get('enable_stock')
						condition: switch @productWatch.get('watch_condition')
								when 0 then 'listing'
								when 1 then 'new'
								when 2 then 'refurbished'
								when 3 then 'used'
						threshold:if @productWatch.get('watch_threshold') then @productWatch.get('watch_threshold')/100 else ''
						increment:if @productWatch.get('watch_increment') then @productWatch.get('watch_increment')/100 else ''
						email:@clientValue @agora.user.field('alerts_email')
					else
						enabled:true
						conditionOption:@product.get('siteName') == 'Amazon'
						enableThreshold:false
						enableIncrement:false
						enableStock:false
						condition:'listing'
						threshold:''
						increment:''
						email:@clientValue @agora.user.field('alerts_email')

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
				@productWatch.set 'enabled', data.enabled
				@productWatch.set 'enable_stock', data.enableStock
				@productWatch.set 'enable_threshold', data.enableThreshold && data.threshold
				@productWatch.set 'enable_increment', data.enableIncrement && data.increment
				@productWatch.set 'watch_increment', if data.increment then data.increment*100 else null
				@productWatch.set 'watch_threshold', if data.threshold then data.threshold*100 else null
