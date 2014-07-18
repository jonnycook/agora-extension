require ['Agora', '../webapp/WebappBackground'], (Agora, WebappBackground) ->
	window.webappBackground = new WebappBackground
	window.agora = new Agora webappBackground,
		localTest:true
		autoUpdate:true
		onLoaded: (agora) ->
			agora.getContentScript 'http://webapp.agora', (script) ->
				eval script

		initDb: (agora) ->
			# agora.db.setData