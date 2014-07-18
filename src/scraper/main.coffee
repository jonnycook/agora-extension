page = require('webpage').create()
webserver = require('webserver').create()
env = require './env.phantom'

webserver.listen 3002, (request, response) ->
	queryString = request.url.match(/^\/[^?]*(?:\?(.*))?$/)[1]
	queryStringParts = queryString.split '&'
	params = {}
	for part in queryStringParts
		[name, value] = part.split '='
		params[name] = unescape value

	console.log JSON.stringify params.products

	page.evaluate ((cb, products) ->
		scrapeProducts cb, products
	), params.cb, JSON.parse params.products
	response.closeGracefully()

# page.onResourceRequested = (request) ->
# 	console.log JSON.stringify request

page.onConsoleMessage = (msg) ->
	console.log msg


page.open env.page, (status) ->
	console.log status

