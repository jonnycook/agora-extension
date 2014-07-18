ENV = 'dev'

window.env = switch ENV
	when 'testing'
		domain: 'ext.agora.dev'
		updaterHost: 'localhost'
		autoUpdate:true
		# localTest:true
		# dontSubmitErrors:true
		dev:true
		debug:true
		gracefulFailure:true
		base: 'http://webapp.agora.dev/webapp.php'
		trackingId: 'UA-48396911-4'

	when 'dev'
		domain: 'ext.agora.dev'
		updaterHost: 'localhost'
		autoUpdate:true
		# localTest:true
		# dontSubmitErrors:true
		dev:true
		debug:true
		gracefulFailure:true
		base: 'http://webapp.agora.dev/webapp.php'
		trackingId: 'UA-48396911-4'
		tracking:true

	when 'dev-prod'
		domain: 'ext.agora.sh'
		# updaterHost: '50.116.20.54'
		autoUpdate:true
		# localTest:true
		dontSubmitErrors:true
		dev:true
		debug:true
		# gracefulFailure:true
		trackingId: 'UA-48396911-4'

	when 'prod'
		dev:true
		domain: 'ext.agora.sh'
		autoUpdate:true
		gracefulFailure:true
		base: 'http://agora.sh/view'
		trackingId: 'UA-48396911-5'
		tracking:true

	when 'remote-dev'
		trackingId: 'UA-48396911-4'
		domain: '66.228.54.96/ext'
		cookieDomain: '66.228.54.96'
		autoUpdate: true
		gracefulFailure:true
		base: 'http://66.228.54.96/webapp.php'
