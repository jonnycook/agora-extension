define ['View', 'Site', 'Formatter', 'util'], (View, Site, Formatter, util) ->
	class ProductPriceView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId

		initAsync: (args, done) ->
			@resolveObject args, (@product) =>
				site = Site.site @product._get 'siteName'

				offerData = {}
				offerData.alternative = @ctx.clientValue()
				offerData.current = @ctx.clientValue()

				currentPrice = null

				update = null

				if 'offers' in site.features
					@product.retrieve 'offers'
					update = =>
						if @product.get('offer')
							currentPrice = @product.get('offer').price
							offerData.current.set
								price:@product.get('displayUserPrice')
								siteName:@product.get('offer').site
								siteIcon:@product.get('offer').url.match('(^https?://[^/]*)')[0] + '/favicon.ico'
								url:util.url @product.get('offer').url
								clear:true
						else
							currentPrice = @product.get 'price'
							offerData.current.set
								price:@product.get('displayPrice')
								siteName:site.name
								siteIcon:site.icon
								url:@product.get('url')


						@product.field('offers').with (offers) =>
							if offers?.new && parseFloat(offers.new[0].price) != parseFloat currentPrice
								match = offers.new[0].url.match('(^https?://[^/]*)')
								if !match
									console.log offers.new[0].url

								icon = if match then match[0] + '/favicon.ico' else null

								offerData.alternative.set
									cheaper:true
									price:'$' + util.numberWithCommas(parseFloat(offers.new[0].price).toFixed(2))
									siteName:offers.new[0].site
									siteIcon:icon
									url:util.url offers.new[0].url
							else
								offerData.current.get().cheaper = true
								offerData.current.trigger()
								offerData.alternative.set null
				else
					update = =>
						currentPrice = @product.get 'price'
						offerData.current.set
							price:@product.get('displayPrice')
							siteName:site.name
							siteIcon:site.icon
							url:@product.get('url')
							cheaper:true

				update()
				@ctx.observe @product.field('offer'), update if 'offers' in site.features
				@ctx.observe @product.field('price'), update

				@data = offerData
				done()

		methods:
			chooseAlternative: (view) ->
				@product.field('offers').with (offers) =>
					@product.set 'offer', url:util.url(offers.new[0].url), site:offers.new[0].site, price:offers.new[0].price

			clear: ->
				@product.set 'offer', null

		@client: ->
			class ProductPriceView extends View
				type: 'ProductPrice'
				init: (el) ->
					@useEl el
					@el.addClass 'v-productPrice'		

					@el.html '<span class="current offer"><a target="_blank" class="icon" /> <span class="price" /> <span class="clear" /></span>'

					@el.find('.clear').click =>
						@event 'clear'
						@callBackgroundMethod 'clear'

				onData: (data) ->
					# console.debug data
					offers = data

					updateCurrent = =>
						current = offers.current.get()

						util.tooltip @el.find('.current .icon').css('backgroundImage', "url(#{current.siteIcon})"), current.siteName
						@el.find('.current .price').html current.price
						@el.find('.current .icon').attr 'href', current.url

						if current.cheaper
							@el.find('.current').addClass 'cheaper'
						else
							@el.find('.current').removeClass 'cheaper'

						if current.clear
							@el.find('.current .clear').css display:''
						else
							@el.find('.current .clear').css display:'none'

					updateAlternative = =>
						alternative = offers.alternative.get()
						@el.find('.alternative').remove()

						if alternative
							@el.append '<span class="alternative offer"><a target="_blank" class="icon" /><span class="price" /></span>'
							if alternative.cheaper
								@el.find('.alternative').addClass 'cheaper'
							util.tooltip @el.find('.alternative .icon').css('backgroundImage', "url(#{alternative.siteIcon})"), alternative.siteName
							@el.find('.alternative .price').html alternative.price
							@el.find('.alternative .icon').attr 'href', alternative.url

							@el.find('.alternative .price').click =>
								@event 'chooseAlternative'
								@callBackgroundMethod 'chooseAlternative'


					updateCurrent()
					offers.current.observe updateCurrent

					updateAlternative()
					offers.alternative.observe updateAlternative
