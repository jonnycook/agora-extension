define -> d: ['View', 'util', 'icons'], c: -> 
	class BuyView extends View
		type: 'Buy'
		constructor: ->
			super
			@viewEl '<div class="v-buy t-dialog">
				<h2>Buy</h2>

				<div class="content">
					<iframe />
				</div>
			</div>'


		onData: (data) ->
			if data.url
				@el.find('iframe').attr 'src', data.url
