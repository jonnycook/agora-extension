define ['View', 'util'], (View, util) ->
	class BuyView extends View
		@nextId:1
		@id: -> @nextId++
		init: (args) ->
			if args.id
				@decision = @agora.modelManager.getInstance('Decision', args.id)
			else if args.viewId
				view = @agora.View.clientViews[args.viewId].view
				if view.name == 'compare/Compare'
					@decision = view.currentDecision()


			products = []
			listElementIds = []
			@decision.get('selection').each (element) =>
				listElementIds.push element.saneId()
				products = products.concat util.resolveProducts element.get('element')


			twoTapProducts = []
			otherProducts = []
			for product in products
				product.set 'purchased', true
				if product.site().config.twoTap
					twoTapProducts.push "#{product.get('siteName')}/#{product.get('productSid')}"
				else
					otherProducts.push "#{product.get('siteName')}/#{product.get('productSid')}"

			if twoTapProducts.length
				@data =
					url:
						"http://ext.agora.sh/checkout.php?" +
						"decision=#{@decision.saneId()}&" +
						"products=#{otherProducts.join(',')}&" +
						"twoTapProducts=#{twoTapProducts.join(',')}&" +
						"listElements=#{listElementIds.join(',')}&" +
						"clientId=#{@agora.updater.clientId}"
			else
				@data = {}
				@agora.background.httpRequest "http://ext.agora.sh/checkout.php?" +
					"decision=#{@decision.saneId()}&" +
					"products=#{otherProducts.join(',')}&" +
					"listElements=#{listElementIds.join(',')}&" +
					"clientId=#{@agora.updater.clientId}"
