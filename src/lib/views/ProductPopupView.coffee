define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->
	class ProductPopupView extends View
		# @id: (args) -> "#{args.siteName}/#{args.productSid}"
		# @id: (args) -> 
		# 	id = "#{args.elementType}.#{args.elementId}"
		# 	if args.decisionId
		# 		id += ".#{args.decisionId}"
		# 	id

		@nextId: 0
		@id: (args) -> ++ @nextId


		initAsync: (args, done) ->
			@resolveObject args, (@product, @element) =>
				if @product
					# @product.model.update @product
					@product.update()
					# @product.update()
					# @element = @agora.modelManager.getInstance args.elementType, args.elementId
					# product = @product = @element.get 'element'

					site = Site.site product._get 'siteName'
					
					@data = 
						title:@clientValue product.field('title'), product.displayValue 'title'
						site:{name:product.get('siteName'), url:product.get('siteUrl'), icon:site.icon}
						price:@clientValue product.field('price'), product.displayValue 'price'
						image:@clientValue product.field('image'), product.displayValue 'image'
						url:product.get 'url'
						# offersPane: site.config.offersPane
						lastFeeling:util.lastFeeling @ctx, product
						lastArgument:util.lastArgument @ctx, product

					if site.hasFeature 'rating'
						_.extend @data,
							rating:@clientValue product.field('rating'), product.displayValue 'rating'
							ratingCount:@clientValue product.field('ratingCount'), product.displayValue 'ratingCount'

					if args.decisionId
						selected = @clientValueNamed 'selected'
						@decision = @agora.modelManager.getInstance('Decision', args.decisionId)

						updateSelected = =>
							selected.set @decision.get('selection').contains @element

						updateSelected()
						@decision.get('selection').observe updateSelected

						@data.selected = selected
				done()
					
		methods:
			remove: ->
				Bag = @agora.modelManager.getModel 'Bag'
				Product = @agora.modelManager.getModel 'Product'
				
				bag = Bag.withId @args.bagId
				product = Product.getBySid @args.siteName, @args.productSid
				
				@agora.removeFromBag product, bag

			setSelected: (view, selected) ->
				if @decision
					if selected
						_activity 'decision.select', @decision, @element.get('element')
						@decision.get('selection').add @element
					else
						@decision.get('selection').remove @element
						_activity 'decision.deselect', @decision, @element.get('element')


			dismiss: ->
				if @decision
					util.dismissDecisionElement @decision, @element
