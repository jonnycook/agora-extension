define ['View', 'Site', 'Formatter', 'util', 'model/ObservableArray', 'underscore'], (View, Site, Formatter, util, ObservableArray, _) ->
	minPrice = (prices) ->
		m = null
		for price in prices
			if price
				if m == null || price < m
					m = price
		m ? 0

	class ProductWatchesView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		init: ->
			ctx = @context()
			productWatches = new ObservableArray
			util.filteredArray ctx, @agora.modelManager.getModel('ProductWatch').all(), productWatches, 
				(record) => record.get 'enabled'
				false
				(ctx, record, test) -> ctx.observe record.field('enabled'), test


			@data =
				productWatches: @clientArray ctx, productWatches, (productWatch, onRemove, ctx) =>
					initialPriceCv = ctx().clientValue()
					currentPriceCv = ctx().clientValue()
					targetPriceCv = ctx().clientValue()
					console.log productWatch.get('product_id')
					product = productWatch.get 'product'

					update = ->
						currentPrices = [productWatch.get('listing'), productWatch.get('new'), productWatch.get('refurbished'), productWatch.get('used')]
						initialPrices = [productWatch.get('initial_listing'), productWatch.get('initial_new'), productWatch.get('initial_refurbished'), productWatch.get('initial_used')]

						currentPrice = minPrice currentPrices.slice 0, productWatch.get('watch_condition') + 1
						initialPrice = minPrice initialPrices.slice 0, productWatch.get('watch_condition') + 1

						currentPriceCv.set currentPrice/100
						initialPriceCv.set initialPrice/100

					ctx().observe productWatch.field('watch_condition'), update
					ctx().observe productWatch.field('initial_listing'), update
					ctx().observe productWatch.field('initial_new'), update
					ctx().observe productWatch.field('initial_refurbished'), update
					ctx().observe productWatch.field('initial_used'), update
					ctx().observe productWatch.field('listing'), update
					ctx().observe productWatch.field('new'), update
					ctx().observe productWatch.field('refurbished'), update
					ctx().observe productWatch.field('used'), update

					update()

					updateTargetPrice = ->
						if productWatch.get('watch_threshold') && productWatch.get('enable_threshold')
							targetPriceCv.set productWatch.get('watch_threshold')/100
						else
							targetPriceCv.set null
					ctx().observe productWatch.field('watch_threshold'), updateTargetPrice
					ctx().observe productWatch.field('enable_threshold'), updateTargetPrice
					updateTargetPrice()


					id:productWatch.get 'id'
					title:ctx().clientValue product.field('title'), product.displayValue 'title'
					image:ctx().clientValue product.field('image'), product.displayValue 'image'
					targetPrice:targetPriceCv
					initialPrice:initialPriceCv
					currentPrice:currentPriceCv
					url:product.get 'url'
					state:ctx().clientValue productWatch.field 'state'

