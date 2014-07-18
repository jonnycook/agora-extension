define ['View', 'Site', 'Formatter', 'util', 'underscore'], (View, Site, Formatter, util, _) ->	
	class ChatView extends View
		# @nextId: 0
		# @id: (args) -> ++ @nextId

		newMessage: ->
			@background.clearTimeout @notifyNewMessageTimerId
			@background.clearTimeout @notifyNewUnreadMessagesTimerId
			@newMessages++
			@notifyNewMessageTimerId = @background.setTimeout (=>
				@data.newMessages.set @newMessages
				@background.clearTimeout @notifyNewUnreadMessagesTimerId
				@notifyNewUnreadMessagesTimerId = @background.setTimeout (=>
					@data.newUnreadMessages.set @newMessages
				), 50
			), 50

		init: ->
			@newMessages = if @agora.chat.newMessages then 1 else 0
			@agora.chat.messages.observe (mutation) =>
				if mutation.type == 'insertion'
					@newMessage()

			messages = @clientArray @ctx, @agora.chat.messages, (obj) -> obj
			@data =
				newMessages:@clientValue @newMessages
				newUnreadMessages:@clientValue @newMessages
				messages:messages
				online:@clientValue @agora.chat.online
				writingReply:@clientValue @agora.chat.writingReply


		methods:
			readNewMessages: ->
				@newMessages = 0
				@data.newMessages.set @newMessages
				@data.newUnreadMessages.set @newMessages
				@background.clearTimeout @notifyNewUnreadMessagesTimerId

				@agora.chat.readMessages()

			sendMessage: (view, message) ->
				@agora.chat.sendMessage message
			writingMessage: (view, message) ->
				@agora.chat.setPendingMessage message
