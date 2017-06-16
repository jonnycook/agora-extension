define ['model/ObservableArray', 'model/ObservableValue'], (ObservableArray, ObservableValue) ->
	class Chat
		constructor: (agora) ->
			@background = agora.background
			@messageQueue = []
			@messages = new ObservableArray
			@updateInterval = 10000
			@online = new ObservableValue
			@writingReply = new ObservableValue
			@writingReply._type = 'object'

		readMessages: ->
			if @lastRead != @last
				@lastRead = @last
				@lastReadChanged = true

		sendMessage: (message) ->
			@messageQueue.push message
			@update()

		setPendingMessage: (@pendingMessage) ->

		update: ->
			args = 
				last:@last
				messages:@messageQueue
				pendingMessage:@pendingMessage

			if @lastReadChanged
				args.lastRead = @lastRead
				@lastReadChanged = false

			@background.clearTimeout @updateTimerId
			@background.httpRequest "http://messages.agora.sh/updateChat.php",
				method:'post'
				dataType:'json'
				data:args
				cb: (response) =>
					@last = if response.last != null then parseInt response.last else null

					if 'lastRead' of response
						@lastRead = parseInt response.lastRead
						if @lastRead != @last
							@newMessages = true

					if response.messages
						@messages.append response.messages
					@updateInterval = response.updateInterval

					@updateTimerId = @background.setTimeout (=>@update()), @updateInterval

					@online.set response.online
					@writingReply.set response.writingReply
				error: =>
					@updateTimerId = @background.setTimeout (=>@update()), @updateInterval


			@messageQueue = []

		init: ->
			# @update()



