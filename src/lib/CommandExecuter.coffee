define -> class CommandExecuter
	constructor: (@background) ->

	returnResult: (command, result) ->
		@background.httpRequest "#{@background.apiRoot}returnCommand.php",
			method:'post'
			data:
				commandId:command.id
				result:JSON.stringify result

	executeCommand: (command, sendResponse) ->
		if command.command == 'scrapeProduct'
			agora.Site.site(command.arguments[0]).productScraper agora.background, command.arguments[1], (scraper) =>
				props = ['title', 'price', 'image', 'rating', 'ratingCount', 'more', 'reviews']
				scraper.scrape props, (properties) =>
					sendResponse properties
		else if command.command == 'getPage'
			@background.httpRequest command.arguments[0],
				cb: (response) =>
					sendResponse response
		else if command.command == 'updateScrapers'
			agora.updateScrapers (result) =>
				sendResponse result
		else if command.command == 'getVersion'
			sendResponse chrome.runtime.getManifest().version
		else if command.command == 'reloadExtension'
			sendResponse()
			chrome.runtime.reload()
		else if command.command == 'getData'
			sendResponse agora.db.data()

		else if command.command == 'getVariable'
			path = command.path.split '.'
			obj = window
			for comp in path
				obj = obj[comp]
			sendResponse JSON.decycle(obj)

		else 
			sendResponse 'INVALID_COMMAND'

		# else if command.command == 'callMethod'
		# 	path = command.path.split '.'
		# 	obj = window
		# 	for comp in path
		# 		obj = obj[comp]
		# 	sendResponse JSON.decycle(obj)

