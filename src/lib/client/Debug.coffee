define -> ->
	class Debug
		@stackTrace: ->
			trace = Error().stack
			trace = trace.split("\n").slice 3, -2
			_.map trace, (line) ->
				matches = line.match /at (.*?) \(/
				if matches
					matches[1]

		@log: ->
			ignoreList = [
				['triggerBackgroundEvent', 'DeleteView']
				['triggerBackgroundEvent']
				['callBackgroundMethod']
				[/^listen/]
				[/^stopListening/]
				['CLIENT:']
				[/^Process/]
				['ConnectView']
				['ReceivedRequest']
			]

			for list in ignoreList
				matched = true
				for item,i in list

					if typeof item == 'string'
						if arguments[i] != item
							matched = false
					else
						if !item.exec arguments[i]
							matched = false

					break if not matched

				if matched
					return

			trace = @stackTrace()

			args = Array.prototype.slice.call arguments, 0, arguments.length
			caller = trace[1]

			# func = caller
			# for i in [1...trace.length]
			# 	func = trace[i].function
			# 	break if func


			# args.push "[#{caller}]"
			# args.unshift "[#{func}]" if func
			args.unshift 'CLIENT:'
			console.debug.apply console, args