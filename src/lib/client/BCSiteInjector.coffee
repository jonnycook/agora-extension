define -> d: ['SiteInjector', 'views/ShoppingBarView'], c: ->
	class BCSiteInjector extends SiteInjector
		init: ->
			# compatibility layer
			t$ = => @contentScript.querySelector.apply @contentScript, arguments
			t$$ = => @contentScript.querySelectorAll.apply @contentScript, arguments
			$ = => @contentScript.safeQuerySelector.apply @contentScript, arguments

			eval "var pages = (#{@pages.toString()})()"
			@pages = pages
			
			
			that = @
			
			@Client = Client =
				productID: null
				clearProduct: (boolValue) ->
					console.log "Client.clearProduct(#{boolValue})"
					@productInit()
				productInit: `function() {
					this.inited = false;
					try {
						that.sid = this.productID = this.site.productID();

						if (!this.productID) {
							this.clearProduct();
							return;
						}
						
						//that.updateButton();
						
						
						// Debug
						console.log('Detected product:', this.productID);
						//this.productInfo(['title', 'price'], function(info) {
						//	console.log('Product Info', info);
						//});
						//
						//Drone.scrape(this.site.name, this.productID, ['title', 'price', 'image'], function(info) {
						//	console.log('Product Info (scraped)', info);
						//	console.log(info.price);
						//});
						
						//this.productCheckIn(function() {
						//	Client.inited = true;
						//});
					}
					catch (e) {
						console.log('Failed to init product');
						throw e;
						//this.mainCont.style.opacity = '.1';
						//this.scrapeError(this.site.name, '<unknown>', 'productID', e);
						//this.error = true;
					}
				}`
				
		# updateButton: ->
		# 	@buttonView.represent siteName:@siteName, productSid:@Client.productID

		# 	if @Client.site.drag
		# 		initProduct = (mousedover) =>
		# 			@sid = @Client.productID
		# 			$(@Client.site.drag).data agora:true

		# 			@products @Client.site.drag, siteName:@siteName, productSid:@Client.productID, mousedover

		# 			@bottomBarView.activeProduct = siteName:@siteName, productSid:@sid
						
		# 		initProduct()

		# 		$('body').delegate @Client.site.drag, 'mouseover', ->
		# 			unless $(@).data 'agora'
		# 				initProduct true
		# 				$(@).data agora:true

		
		run: ->
			@init()
			@url = document.location.href
			$ =>
				for pageMatch, page of @pages
					if @url.match pageMatch
						console.log "matched #{pageMatch}"
						@Client.site = page

						# @button = new Button @contentScript						
						# @buttonView = new ButtonView @contentScript, @button.el
						@Client.site.init()
						
						# @waitFor page.drag, (el) =>
						# console.log page.drag, $(page.drag)


						for el in $(page.drag)
							@products el, {productSid:@sid},
								area:'main'
								initOverlay: (overlay) ->
									overlay.addAlwaysShow 'productPage'
							# @Client.site.inject(el, @button.cont, @button.el)

						setInterval (=>
							# @Client.clearProduct()
							sid = @Client.site.productID()
							if @sid != sid
								@sid = sid
								for el in $(page.drag)
									@clearProductEl el
									@products el, {productSid:@sid},
										area:'main'
										initOverlay: (overlay) ->
											overlay.addAlwaysShow 'productPage'

						), 2000
						break

			@initPage =>
				@shoppingBarView = new ShoppingBarView @contentScript

				@shoppingBarView.el.appendTo document.body
				@shoppingBarView.represent()

				@onInitPage() if @onInitPage

					
					#@updateButton()

			true