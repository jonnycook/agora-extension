define -> d: ['View', 'util', 'icons'], c: -> 
	class EditDescriptorView extends View
		type: 'EditDescriptor'
		constructor: ->
			super
			@el = @viewEl '<div class="v-editDescriptor t-dialog">
				<h2>Edit Decision</h2>
				<div class="content">

					<form>
						<div class="fields dark">
						<div class="group descriptor">
							<div class="field"><input type="text" class="descriptor" name="descriptor" placeholder="Describe what you are looking for"></div>
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
										<option value="male">Male</option>
										<option value="female">Female</option>
									</select>
							</div>
						</div>

						<div class="group gift">
							<div class="field"><label>Gift</label> <input type="checkbox" name="gift"> </div>
							<div class="field gift"><label>Occasion</label> <input type="text" name="gift.occasion" placeholder="Occasion"></div>
						</div>

						<div class="buttons">
						<!--<input type="button" class="button cancel" value="cancel">-->
						<input type="submit" class="button" value="confirm">
						</div>

						</div>
					</form>
				</div>
			</div>'

			parseTimerId = null

			descriptorEl = @el.find('input.descriptor')
			# @lastDescriptor = descriptorEl.val()
			parsing = 0
			descriptorEl.keydown =>
				clearTimeout parseTimerId
				parseTimerId = setTimeout (=>
					if @lastDescriptor != descriptorEl.val()
						parsing++
						@lastDescriptor = descriptorEl.val()
						@callBackgroundMethod 'parse', [descriptorEl.val()]
				), 500

			util.styleSelect @el.find('[name="recipient.sex"]'), autoSize:false


			el = @el.find('.-agora-newItem')
			util.tooltip @el.find('.-agora-newItem'), (=> descriptorEl.val()), position:'below'

			@el.find('form').submit =>
				clearTimeout parseTimerId
				if @lastDescriptor != descriptorEl.val()
					@callBackgroundMethod 'parse', [descriptorEl.val(), true]
					@close()
					return false

				descriptor = {}

				descriptor.descriptor = descriptorEl.val()

				product = null

				if @el.find('[name="product"]').val() != ''
					product ?= {}
					product.type = @el.find('[name="product"]').val()

				if @el.find('[name="properties"]').val() != ''
					product ?= {}
					product.properties = _.map(@el.find('[name="properties"]').val().split(','), (p) -> p.trim()) 

				descriptor.product = product if product

				descriptor.purpose = @el.find('[name="purpose"]').val() if @el.find('[name="purpose"]').val() != ''
				descriptor.context = @el.find('[name="context"]').val() if @el.find('[name="context"]').val() != ''

				person = null
				
				if @el.find('[name="recipient"]').val() != ''
					person ?= {}
					person.name = @el.find('[name="recipient"]').val()

				if @el.find('[name="recipient.relationship"]').val() != ''
					person ?= {}
					person.relationship = @el.find('[name="recipient.relationship"]').val()

				if @el.find('[name="recipient.age"]').val() != ''
					person ?= {}
					person.age = @el.find('[name="recipient.age"]').val()

				if @el.find('[name="recipient.sex"] ').val() != ''
					person ?= {}
					person.sex = @el.find('[name="recipient.sex"]').val()

				descriptor.person = person if person

				descriptor.occasion = @el.find('[name="gift.occasion"]').val() if @el.find('[name="gift.occasion"]').val() != ''

				descriptor.version = @version

				@callBackgroundMethod 'updateDescriptor', descriptor

				@close()
				false

			setTimeout (=> descriptorEl.get(0).focus()), 50


		onData: (@data) ->
			_tutorial 'EditDescriptor', {positionEl:@el.find('[name="descriptor"]'), attachEl:@el}

			update = =>
				descriptor = @descriptor = data.get() ? {}
				@version = descriptor.version

				@el.find('[name="descriptor"]').val descriptor.descriptor if descriptor.descriptor

				@lastDescriptor = @el.find('[name="descriptor"]').val()

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
					@el.find('[name="recipient.sex"]').children("[value=#{descriptor.person?.sex}]").prop 'selected', true
				else
					@el.find('[name="recipient.sex"]').children(':first').prop 'selected', true
				@el.find('[name="recipient.sex"]').trigger 'change'

				if 'occasion' of descriptor
					@el.find('[name="gift"]').prop 'checked', true
					@el.find('[name="gift.occasion"]').val descriptor.occasion

				else
					@el.find('[name="gift"]').prop 'checked', false
					@el.find('[name="gift.occasion"]').val ''
			update()
			data.observe =>
				--@parsing
				update()




