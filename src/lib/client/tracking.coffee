define -> ->
	page: (path, params={}) ->
		# console.debug "tracking page \"#{path}\""
		contentScript.triggerBackgroundEvent 'tracking', type:'page', path:path, params:params

	event: (args...) ->
		contentScript.triggerBackgroundEvent 'tracking', type:'event', args:args

	time: (args...) ->
		contentScript.triggerBackgroundEvent 'tracking', type:'time', args:args
