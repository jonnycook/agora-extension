define -> d: ['View', 'Frame', 'views/OffersView', 'views/DataView', 'views/AddFeelingView', 'views/AddArgumentView'], c: ->
	class ChatView extends View
		type: 'Chat'
		init: (@bagsbyEl) ->
			@el = @viewEl '<div class="v-chat">
					<div class="wrapper scroll vertical">
						<div class="intro">Hey there! It looks like you’re doing some shopping! Let me know if you have any questions or comments and I’ll get back to you ASAP.</div>
						<ul class="messages"><li class="message" /></ul>
					</div>
					<form>
						<input type="text" placeholder="Type a message and press enter to send..." class="message">
					</form>
				</div>
			'

			@el.find('form').submit -> false
			@messageEl = messageEl = @el.find('form .message')
			messageEl.keyup (e) =>
				if e.keyCode == 27
					@close()
					return
				else if e.keyCode == 13
					@callBackgroundMethod 'sendMessage', [messageEl.val()]
					messageEl.val ''

				@callBackgroundMethod 'writingMessage', [messageEl.val()]



			Q(window).blur =>
				@windowFocused = false

			Q(window).focus =>
				@windowFocused = true
				if @isReadingMessages()
					@callBackgroundMethod 'readNewMessages'


		isReadingMessages: ->
			@windowFocused && @open

		scrollToBottom: ->
			@el.find('.wrapper .scrollWrapper').scrollTop @el.find('.wrapper .scrollWrapper').get(0).scrollHeight


		onData: (@data) ->
			@withData data.online, (online) =>
				if online
					@el.addClass 'online'
					@bagsbyEl.addClass 'online'
				else
					@el.removeClass 'online'
					@bagsbyEl.removeClass 'online'
			# @withData data.writingReply, (writingReply) -> console.debug writingReply

			iface = @listInterface @el, '.messages .message', (el, data, pos, onRemove) =>
				el.html "<span class='sender#{if !data.sender then ' you' else ''}'>#{if data.sender then 'Bagsby' else 'you'}</span> <span class='content'>#{data.content}</span> "

			@data.newMessages.observe =>
				if @isReadingMessages()
					@callBackgroundMethod 'readNewMessages'

			@withData data.newUnreadMessages, (newUnreadMessages) =>
				if newUnreadMessages
					@bagsbyEl.addClass 'newMessages'
				else
					@bagsbyEl.removeClass 'newMessages'

			iface.onInsert = =>
				@sizeChanged?()
				if @lockedAtBottom
					@scrollToBottom()

			iface.onDelete = (el, del) =>
				del()
				@sizeChanged?()

			iface.setDataSource data.messages

		onDisplay: ->
			@lockedAtBottom = true
			setTimeout (=>@messageEl.get(0).focus()), 10
			@open = true
			@windowFocused = true
			@callBackgroundMethod 'readNewMessages'

			if !@initedScrollbar
				util.initScrollbar @el.find('.wrapper'), absolute:false
				@initedScrollbar = true

				wrapperEl = @el.find('.wrapper .scrollWrapper')
				# util.trapScrolling wrapperEl

				@lockedAtBottom = false
				lockBottom = =>
					if !@lockedAtBottom
						@lockedAtBottom = true

				unlockBottom = =>
					if @lockedAtBottom
						@lockedAtBottom = false

				wrapperEl.scroll =>
					if (wrapperEl.get(0).scrollHeight - wrapperEl.height()) - wrapperEl.scrollTop() <= 5
						lockBottom()
					else
						unlockBottom()
			@scrollToBottom()


		onClose: ->
			@open = false


