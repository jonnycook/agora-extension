window.require =
	baseUrl: (env.root ? '') + '/build/lib/'
	paths:
		taxonomySrc: '../../taxonomy'
		text: '../../libs/text'
		ChromeBackground: '../ChromeBackground'
		ChromeContentScript: '../ChromeContentScript',
		underscore: '../../libs/lodash.min'
		jQuery: '../../libs/jquery-1.7.2.min'
		# stacktrace: '../../libs/stacktrace-0.4'

	shim:
		underscore:
			exports: '_'

		jQuery:
			exports: '$'
