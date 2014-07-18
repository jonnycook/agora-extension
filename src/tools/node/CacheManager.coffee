fs = require 'fs'
path = require 'path'
crypto = require 'crypto'


md5 = (str) ->
	md5er = crypto.createHash 'md5'
	md5er.update str
	md5er.digest 'hex'


module.exports = class CacheManager
	cachePath: (name) ->
		cacheName = md5 name
		"../cache/#{cacheName}"
	
	cacheResponse: (name, response) ->
		fs.writeFile (@cachePath name), response
		
	getCachedResponse: (name) ->		
		cachePath = @cachePath name
		if path.existsSync cachePath
			fs.readFileSync cachePath, 'utf8'
		else
			null
			
	putThrough: (opts) ->
		response = @getCachedResponse opts.name
		if response
			console.log 'has cached response for ' + opts.name
			opts.cb response
		else
			console.log "no cache for #{opts.name}"
			opts.get (response) =>
				@cacheResponse opts.name, response
				opts.cb response

CacheManager.md5 = md5