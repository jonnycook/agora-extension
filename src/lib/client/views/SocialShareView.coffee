define -> d: ['View', 'util', 'icons'], c: -> 
	class SocialShareView extends View
		type: 'SocialShare'
		constructor: ->
			super
			@viewEl '<div class="v-socialShare t-dialog">
				<h2>Share Decision</h2>

				<div class="content">
					<ul class="services">
						<li class="twitter"></li>
						<li class="facebook">
							<iframe></iframe>
						</li>
						<li class="googlePlus"></li>
					</ul>
					<input type="text" class="url">
					<select class="access">
						<option value="0">Private</option>
						<option value="1">Public (Unlisted)</option>
						<option value="2">Public (Listed)</option>
					</select>
				</div>
			</div>'

			@el.find('.url').focus -> @select()
			@el.find('.url').mouseup false

			# @el.find('.facebook').click =>
			# 	return if @el.hasClass 'private'

			# 	if !FB.inited
			# 		FB.init
			# 			appId: '706396949411182'
			# 			status: true
			# 			xbfml: true
			# 			version: 'v2.0'
			# 		FB.inited = true

			# 	FB.ui
			# 		method: 'share'
			# 		href:@url


			@el.find('.twitter').click =>
				return if @el.hasClass 'private'
				tracking.event 'SocialShare', 'Twitter'
				window.open("https://twitter.com/share?url=#{escape(@url)}", null, 'menubar=no,toolbar=no,resizable=yes,scrollbars=no,width=500,height=260')


			@el.find('.googlePlus').click =>
				return if @el.hasClass 'private'
				tracking.event 'SocialShare', 'Google+'
				window.open("https://plus.google.com/share?url=#{@url}", '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=no,height=420,width=510')

			@el.find('.access').change =>
				@callBackgroundMethod 'setAccess', @el.find('.access').val()

			util.styleSelect @el.find('.access'), class:'access', label:false, autoSize:false


		onData: (data) ->
			@url = data.url
			@el.find('.facebook iframe').attr 'src', "//agora.sh/facebookShare.php?url=#{@url}"
			if data.owner
				@el.addClass 'owner'
				@sizeChanged?()

			@el.find('.url').val data.url
			@withData data.access, (access) =>
				if access == 0
					@el.addClass 'private'
					@el.find('.url').prop 'disabled', true
				else
					@el.removeClass 'private'
					@el.find('.url').prop 'disabled', false

				@el.find('.access').prop 'selectedIndex', access
				@el.find('.access').trigger 'change'