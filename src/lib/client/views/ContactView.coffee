define -> d: ['View', 'util', 'icons'], c: -> 
	class ContactView extends View
		type: 'Contact'
		constructor: ->
			super
			@el = @viewEl '<div class="v-contact t-dialog">
				<h2>Contact</h2>
				<div class="content">
					<form class="dark">
						<input type="text" name="subject" placeholder="Subject (optional)">
						<div class="messageWrapper">
							<textarea placeholder="Message" name="message"></textarea>
						</div>
						<span class="thankYou">Thank you for contacting us! We will get back to you as soon as we can.</span>
						<input type="submit">
					</form>
				</div>
			</div>'

			@el.submit =>
				@callBackgroundMethod 'submit', [@el.find('[name="subject"]').val(), @el.find('[name="message"]').val()]
				@el.addClass 'sent'
				setTimeout (=> @close()), 1500
				false

			setTimeout (=>@el.find('[name="subject"]').get(0).focus()), 10
