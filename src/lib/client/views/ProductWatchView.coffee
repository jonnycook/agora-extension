define -> ->
	class ProductWatchView extends View
		type: 'ProductWatch'

		init: ->
			@viewEl '
				<div class="v-productWatch">
					<form>
						<div class="condition listing">
							<div class="option listing">Listing</div>
							<div class="option new">New</div>
							<div class="option refurbished">Refurbished</div>
							<div class="option used">Used</div>
						</div>

						<div class="alertConditions">
							<h2>Alert Conditions</h2>
							<div class="criterion increment">
								<input class="t-checkbox" type="checkbox"> 
								<label>Price drops by at least:</label>
								<input type="text">
							</div>
							<div class="criterion threshold">
								<input class="t-checkbox" type="checkbox">
								<label>Price reaches or goes below:</label>
								<input type="text">
							</div>
							<div class="criterion stock">
								<input class="t-checkbox" type="checkbox">
								<label>Item is back in stock</label>
							</div>
						</div>

						<input type="button" class="cancel" value="cancel">
						<input type="submit" value="save">
					</form>
				</div>'

			@el.find('.option.listing').click =>
				@setCondition 'listing'

			@el.find('.option.new').click =>
				@setCondition 'new'

			@el.find('.option.refurbished').click =>
				@setCondition 'refurbished'

			@el.find('.option.used').click =>
				@setCondition 'used'

			# @el.find('.option.used').click =>
			# 	@el.find('.condition').removeClass('listing new refurbished used').addClass 'used'
			# 	@callBackgroundMethod 'setCondition', 'used'

			# @el.find('.criterion.stock input[type="checkbox"]').change =>
			# 	@callBackgroundMethod 'setEnableStock', [@el.find('.criterion.stock input[type="checkbox"]').prop('checked')]

			# @el.find('.criterion.threshold input[type="checkbox"]').change =>
			# 	@callBackgroundMethod 'setEnableThreshold', [@el.find('.criterion.threshold input[type="checkbox"]').prop('checked')]

			# @el.find('.criterion.increment input[type="checkbox"]').change =>
			# 	@callBackgroundMethod 'setEnableIncrement', [@el.find('.criterion.increment input[type="checkbox"]').prop('checked')]


			@el.find('form').submit =>
				data =
					condition:@currentCondition
					enableStock:@el.find('.criterion.stock input[type="checkbox"]').prop('checked')
					enableThreshold:@el.find('.criterion.threshold input[type="checkbox"]').prop('checked')
					enableIncrement:@el.find('.criterion.increment input[type="checkbox"]').prop('checked')
					threshold:@el.find('.criterion.threshold input[type="text"]').val()
					increment:@el.find('.criterion.increment input[type="text"]').val()

				@callBackgroundMethod 'submit', [data]
				@close? true
				false


			@el.find('.cancel').click => @close? true


		setCondition: (condition) ->
			@el.find('.condition').removeClass('listing new refurbished used').addClass condition
			@currentCondition = condition

		onData: (data) ->
			if !data.conditionOption
				@el.find('.condition').remove()

			@setCondition data.condition
			@el.find('.criterion.threshold input[type="checkbox"]').prop 'checked', data.enableThreshold
			@el.find('.criterion.stock input[type="checkbox"]').prop 'checked', data.enableStock
			@el.find('.criterion.increment input[type="checkbox"]').prop 'checked', data.enableIncrement
			@el.find('.criterion.threshold input[type="text"]').val data.threshold
			@el.find('.criterion.increment input[type="text"]').val data.increment

