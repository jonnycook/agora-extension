window.tracking = 
	enabled: false
	page: (path, params={}) ->
		console.log 'tracking page', path
		if @enabled && ga? && env.tracking != false
			if agora.user
				agora.updater.transport.ws.send "t#{agora.user.saneId()}\tpage\t#{path}"

			p = []
			p.push "#{name}=#{value}" for name,value of params
			ga 'send', 'pageview', path + '?' + p.join('&')

	event: (args...) ->
		console.log 'tracking event', args
		if @enabled && ga? && env.tracking != false
			if agora.user
				agora.updater.transport.ws.send "t#{agora.user.saneId()}\tevent\t#{args.join '\t'}"
			ga 'send', 'event', args...

	time: (category, variable, time, label=null) ->
		if @enabled && ga? && env.tracking != false
			if agora.user
				agora.updater.transport.ws.send "t#{agora.user.saneId()}\ttime\t#{category}\t#{variable}\t#{time}\t#{label ? ''}"
			ga 'send', 'timing', arguments...
