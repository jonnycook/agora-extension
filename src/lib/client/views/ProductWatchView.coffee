define -> ->
	class ProductWatchView extends View
		type: 'ProductWatch'

		init: ->
			@viewEl '
				<div class="v-productWatch">
					<form>
						<h1>Tracking</h1>
						<div class="enabled">
							<div class="option off">off</div>
							<div class="option on">on</div>
						</div>

						<div class="condition listing">
							<h2>Filter</h2>
							<div class="options">
								<div class="option listing">Listing</div>
								<div class="option new">New</div>
								<div class="option refurbished">Refurbished</div>
								<div class="option used">Used</div>
							</div>
						</div>

						<div class="alertConditions">
							<h2>Alert conditions</h2>
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

						<div class="email">
							sending alerts to <span class="value"></span> <a href="#" class="edit"></a>
						</div>

						<input type="button" class="cancel" value="cancel">
						<input type="submit" value="save">
					</form>
				</div>'

			@el.find('.enabled .off').click => @setEnabled off
			@el.find('.enabled .on').click => @setEnabled on

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
					enabled:@currentEnabled
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

		setEnabled: (enabled) ->
			@currentEnabled = enabled
			@el.find('.enabled').removeClass('on off').addClass if enabled then 'on' else 'off'

		onData: (data) ->
			@withData data.email, (email) =>
				if email
					@el.find('.email').removeClass('noEmail').html "sending alerts to <span class='value'>#{email}</span> <a href='#' class='edit'></a>"
				else
					@el.find('.email').addClass('noEmail').html "no alerts email <a href='#' class='edit'></a>"

			if !data.conditionOption
				@el.find('.condition').remove()

			@setCondition data.condition
			@setEnabled data.enabled
			@el.find('.criterion.threshold input[type="checkbox"]').prop 'checked', data.enableThreshold
			@el.find('.criterion.stock input[type="checkbox"]').prop 'checked', data.enableStock
			@el.find('.criterion.increment input[type="checkbox"]').prop 'checked', data.enableIncrement
			@el.find('.criterion.threshold input[type="text"]').val data.threshold
			@el.find('.criterion.increment input[type="text"]').val data.increment

