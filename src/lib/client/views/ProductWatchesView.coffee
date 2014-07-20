define -> ->
	formatPrice = (price) -> "$#{price}"
	class ProductWatchesView extends View
		type: 'ProductWatches'
		flexibleLayout:true
		init: ->
			@updateFuncs = []
			@viewEl '<div class="-agora v-productWatches">
				<div class="productWatches">
					<div class="productWatch hasTarget targetMet">
						<a href="#" target="_blank" class="title" />
						<a href="#" target="_blank" class="image" />
						<div class="meter">
							<label class="min" />
							<label class="max" />
							<label class="currentPrice">current <span class="value" /></label>
							<div class="diff" />
							<div class="targetPrice" />
							<div class="initialPrice" />
							<div class="currentPrice" />

							<label class="targetPrice">target <span class="value" /></label>
							<label class="initialPrice">initial <span class="value" /></label>
						</div>
					</div>
				</div>
			</div>'

		updateLayout: ->
			func() for func in @updateFuncs

		onData: (data) ->
			iface = @listInterface @el, '.productWatches .productWatch', (el, data, pos, onRemove) =>
				view = @view()
				onRemove = ->
					view.destruct()
					@updateFuncs.splice @updateFuncs.indexOf(update), 1

				update = =>
					currentPrice = data.currentPrice.get()
					initialPrice = data.initialPrice.get()
					targetPrice = data.targetPrice.get()

					if currentPrice
						el.removeClass 'outOfStock'
						currentPriceEl = el.find('div.currentPrice')
						initialPriceEl = el.find('div.initialPrice')
						targetPriceEl = el.find('div.targetPrice')
						diffEl = el.find('.diff')

						meterWidth = el.find('.meter').width()

						min = Math.min currentPrice, initialPrice, targetPrice
						min = Math.max 0, min - min*.1
						max = Math.max(currentPrice, initialPrice, targetPrice) * 1.1

						el.find('label.min').html formatPrice Math.floor min
						el.find('label.max').html formatPrice Math.floor max

						currentPricePos = (currentPrice - min)/(max - min) * meterWidth
						initialPricePos = (initialPrice - min)/(max - min) * meterWidth

						currentPriceEl.css 'left', currentPricePos
						initialPriceEl.css 'left', initialPricePos

						el.find('label.initialPrice .value').html formatPrice initialPrice
						el.find('label.initialPrice').css left:initialPricePos-el.find('label.initialPrice').outerWidth()/2, textAlign:''

						currentPriceWidth = el.find('label.currentPrice').outerWidth()
						el.find('label.currentPrice .value').html formatPrice currentPrice
						pos = Math.max(el.find('label.min').position().left + el.find('label.min').outerWidth() + 10, Math.min(currentPricePos-currentPriceWidth/2, el.find('label.max').position().left - 10 - currentPriceWidth))
						el.find('label.currentPrice').css left:pos

						left = right = 0

						if targetPrice
							if currentPrice <= targetPrice
								el.addClass 'targetMet'
							else
								el.removeClass 'targetMet'

							targetPricePos = (targetPrice - min)/(max - min) * meterWidth

							targetPriceEl.css 'left', targetPricePos

							el.find('label.targetPrice .value').html formatPrice targetPrice
							el.find('label.targetPrice').css left:targetPricePos, marginLeft:-el.find('label.targetPrice').outerWidth()/2, textAlign:''

							meterPos = el.find('.meter').offset().left
							initialPriceLabel = el.find('label.initialPrice')
							targetPriceLabel = el.find('label.targetPrice')
							initialPriceLabelLeft = initialPriceLabel.offset().left - meterPos
							initialPriceLabelRight = initialPriceLabelLeft + initialPriceLabel.outerWidth()

							targetPriceLabelLeft = targetPriceLabel.offset().left - meterPos
							targetPriceLabelRight = targetPriceLabelLeft + targetPriceLabel.outerWidth()

							# console.debug targetPriceLabelLeft < initialPriceLabelRight, targetPriceLabelLeft > initialPriceLabelLeft, targetPriceLabelLeft, initialPriceLabelRight


							if (initialPriceLabelLeft < targetPriceLabelRight && initialPriceLabelLeft > targetPriceLabelLeft ||
													initialPriceLabelRight < targetPriceLabelRight && initialPriceLabelRight > targetPriceLabelLeft) ||

							(targetPriceLabelLeft < initialPriceLabelRight && targetPriceLabelLeft > initialPriceLabelLeft ||
													targetPriceLabelRight < initialPriceLabelRight && targetPriceLabelRight > initialPriceLabelLeft)
								mid = (initialPricePos + targetPricePos)/2
								if initialPrice < targetPrice
									initialPriceLabel.css left:mid - initialPriceLabel.outerWidth() - 2, marginLeft:0, textAlign:'right'
									targetPriceLabel.css left:mid + 2, marginLeft:0, textAlign:'left'
								else
									targetPriceLabel.css left:mid - targetPriceLabel.outerWidth() - 2, marginLeft:0, textAlign:'right'
									initialPriceLabel.css left:mid + 2, marginLeft:0, textAlign:'left'

							el.addClass 'hasTarget'

							left = Math.min currentPricePos, targetPricePos
							right = Math.max currentPricePos, targetPricePos
						else
							el.removeClass 'hasTarget'
							if currentPrice <= initialPrice
								el.addClass 'targetMet'
							else
								el.removeClass 'targetMet'

							left = Math.min initialPricePos, currentPricePos
							right = Math.max initialPricePos, currentPricePos

						diffEl.css left:left, width:right - left
					else
						el.addClass 'outOfStock'

				@updateFuncs.push update

				data.currentPrice.observe update
				data.targetPrice.observe update
				data.initialPrice.observe update

				view.withData data.image, (image) -> el.find('.image').css 'backgroundImage', "url('#{image}')"
				view.withData data.title, (title) -> el.find('.title').html title
				el.find('.title, .image').attr 'href', data.url

				view.withData data.state, (state) ->
					if state
						el.addClass 'inited'
					else
						el.removeClass 'inited'

				setTimeout update, 0

				el

			# iface.onInsert = =>
			# 	@sizeChanged?()

			# iface.onDelete = (el, del) =>
			# 	del()
			# 	@sizeChanged?()

			iface.setDataSource data.productWatches
