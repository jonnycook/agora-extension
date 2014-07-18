define -> d: ['View', 'util', 'icons'], c: -> 
	class AddDescriptorView extends View
		type: 'AddDescriptor'
		constructor: ->
			super
			@el = @viewEl '<div class="v-addDescriptor t-dialog">
				<h2>Add something</h2>
				<div class="content">

					<form class="dark">
						<div class="group descriptor">
							<div class="field"><input type="text" class="descriptor" placeholder="Describe what you are looking for"></div>
						</div>

						<div class="group">
							<div class="field"><label>Product</label> <input type="text" name="product" placeholder="Product"></div>
							<div class="field"><label>Purpose</label> <input type="text" name="purpose" placeholder="Purpose"></div>
							<div class="field"><label>Context</label> <input type="text" name="context" placeholder="Context"></div>
						</div>

						<div class="group properties">
							<div class="field"><label>Properties</label> <input type="text" name="properties" placeholder="Properties"></div>
						</div>

						<div class="group recipient">
							<div class="field"><label>Recipient</label> <input type="text" name="recipient" placeholder="Recipient"></div>
							<div class="field"><label>Relationship</label> <input type="text" name="recipient.relationship" placeholder="Relationship"></div>
							<div class="field"><label>Age</label> <input type="text" name="recipient.age" placeholder="Age"></div>
							<div class="field">
									<label>Sex</label>
									<select name="recipient.sex">
										<option>Sex</option>
										<option name="male">Male</option>
										<option name="female">Female</option>
									</select>
							</div>
						</div>

						<div class="group gift">
							<div class="field"><label>Gift</label> <input type="checkbox" name="gift"> </div>
							<div class="field gift"><label>Occasion</label> <input type="text" name="gift.occasion" placeholder="Occasion"></div>
						</div>
					</form>

					<span class="t-item -agora-newItem" />
				</div>
			</div>'

			icons.setIcon @el.find('.-agora-newItem'), 'list'


			parseTimerId = null

			descriptorEl = @el.find('input.descriptor')
			descriptorEl.keydown =>
				clearTimeout parseTimerId
				parseTimerId = setTimeout (=>
					@callBackgroundMethod 'parse', [descriptorEl.val()]
				), 500

			util.styleSelect @el.find('[name="recipient.sex"]'), autoSize:false

			el = @el.find('.-agora-newItem')
			util.tooltip @el.find('.-agora-newItem'), (=> descriptorEl.val()), position:'below'

			util.initDragging @el.find('.-agora-newItem'),
				data: (cb) => 
					descriptor = @descriptor ? {}
					descriptor.descriptor = descriptorEl.val()
					cb action:'new', type:'descriptor', descriptor:descriptor
				context: 'page'
				onDraggedOver: (activeEl, helperEl) ->
					if activeEl
						helperEl.addClass 'adding'
					else 
						helperEl.removeClass 'adding'
				helper: -> el.clone().addClass '-agora dragging'
				start: ->
					el.css opacity:.5
				stop: (event, ui) =>
					el.animate opacity:1
					ui.helper.detach()
					@close()

			setTimeout (=> descriptorEl.get(0).focus()), 50


		onData: (@data) ->
			data.observe =>
				descriptor = @descriptor = data.get().descriptor

				@el.find('[name="product"]').val descriptor.product?.type ? ''
				@el.find('[name="purpose"]').val descriptor.purpose ? ''
				@el.find('[name="context"]').val descriptor.context ? ''
				if descriptor.product?.properties
					@el.find('[name="properties"]').val descriptor.product.properties.join ', '
				else
					@el.find('[name="properties"]').val ''


				@el.find('[name="recipient"]').val descriptor.person?.name ? ''
				@el.find('[name="recipient.relationship"]').val descriptor.person?.relationship ? ''
				@el.find('[name="recipient.age"]').val descriptor.person?.age ? ''


				if descriptor.person?.sex
					@el.find('[name="recipient.sex"]').children("[name=#{descriptor.person?.sex}]").prop 'selected', true
				else
					@el.find('[name="recipient.sex"]').children(':first').prop 'selected', true
				@el.find('[name="recipient.sex"]').trigger 'change'

				if 'occasion' of descriptor
					@el.find('[name="gift"]').prop 'checked', true
					@el.find('[name="gift.occasion"]').val descriptor.occasion

				else
					@el.find('[name="gift"]').prop 'checked', false
					@el.find('[name="gift.occasion"]').val ''

				icons.setIcon @el.find('.-agora-newItem'), data.get().icon ? 'list'

