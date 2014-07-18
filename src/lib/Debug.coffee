define ['underscore'], (_) ->
	class Debug
		@stackTrace: ->
			trace = Error().stack
			# console.log trace
			trace = trace.split('at ').slice 3
			# console.log trace
			_.map trace, (line) ->
				matches = line.match /(.*?) \(((?:[<>A-z0-9_\/.:\-])*):([^:]*):([^:]*)\)\s*/
				if matches
					function:matches[1], file:matches[2], line:matches[3], col:matches[4],l:line
				else
					matches = line.match /((?:[<>A-z0-9_\/.:\-])*):([^:]*):([^:]*)/
					if matches
						function:null, file:matches[1], line:matches[2], col:matches[3],l:line
					# else
						# console.log line

		@log: ->
			ignoreList = [
				['ConnectView']
				['_callObservers']
				['triggerContentScriptEvent']
				# ['update']
				['CreateView']
				['DeleteView']
				# ['adding']
				# ['callMethod']
				[/^Deleting view/]
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

			func = caller.function
			(return if func.match pattern) for pattern in [
				'^Update'
				'^Table'
			] if func


			args.push "#{caller.file}:#{caller.line}:#{caller.col}"
			args.unshift "[#{func}]" if func
			console.log.apply console, args

		@error: ->
			ignoreList = [
				# ['ConnectView']
				['_callObservers']
				['update']
				# ['CreateView']
				['adding']
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

			func = caller.function
			# for i in [1...trace.length]
			# 	func = trace[i].function
			# 	break if func


			args.push "#{caller.file}:#{caller.line}:#{caller.col}"
			args.unshift "[#{func}]" if func
			console.error.apply console, args
