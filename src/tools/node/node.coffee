# require('console-trace')
# 	always: true

requirejs = require 'requirejs'
requirejs.config
	nodeRequire: require
	baseUrl: "#{__dirname}/../lib/"
	paths:
		underscore: '../../libs/lodash.min'
		text: '../../libs/text'
	# shim:
	# 	underscore:
	# 		exports: '_'

# XMLHttpRequest = require('XMLHttpRequest').XMLHttpRequest

request = require 'request'

$ = ajax:require 'najax'
# $.support.cors = true
# $.ajaxSettings.xhr = -> new XMLHttpRequest


CacheManager = require './CacheManager'


util = require('util')

urlUtil = require 'url'
fs = require 'fs'

requirejs ['Background', 'Site', 'underscore', 'models/init'], (Background, Site, _, initModels) ->
	class NodeBackground extends Background
		constructor: (opts) ->
			super
			@cache = opts.useCache
			
		onRequest: ->

		_httpGet: (url, opts) ->
			console.log 'start', url

			$.ajax url, 
				type:opts.method
				data:opts.data
				headers: {'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.72 Safari/537.36'}
				success: (response, status) =>

					fs.writeFileSync 'out.html', url + "\n" + response
					opts.cb? response, 
						status: status
						header: (name) -> xhr.getResponseHeader name

				error: ->
					console.log 'error', url

				complete: (xhr, status) =>
					# console.log 'complete', url, status, xhr.status
					if status == 'error'
						if (xhr.status + '')[0] == '3'
							redirectUrl = urlUtil.resolve(url, xhr.getResponseHeader 'Location')
							@_httpGet redirectUrl, opts

				dataType:opts.dataType
				error: opts.error
		
		require: (libs, cb) ->
			requirejs libs, cb

		httpRequest: (url, opts={}) ->
			if @cache
				@cache.putThrough
					name: url
					cb: opts.cb
					get: (sendValue) =>
						cb = opts.cb
						opts.cb = (response) =>
							@cache.cacheResponse url, response
							sendValue response
						@_httpGet url, opts
			else
				@_httpGet url, opts
	
	background = new NodeBackground
		useCache: null#new CacheManager

	{db:db, modelManager:modelManager} = initModels background


	Product = modelManager.getModel 'Product'

	Product.node = true

	if process.argv[2]
		site = Site.site process.argv[2]
		switch process.argv[3]
			when 'product'
				if process.argv[5]
					Product.siteProduct Product.getBySid(site.name, process.argv[4]), (siteProduct) ->
						siteProduct.property [process.argv[5]], (property) ->
							console.log property
				else
					site.productScraper background, process.argv[4], (scraper) ->
						scraper.scrape ['more'], (properties) ->
							console.log properties

			when 'test'
				site.productScraperClass background, (ProductScraper) ->
					if ProductScraper.testProducts
						for sid in ProductScraper.testProducts
							site.productScraper background, sid, (scraper) ->
								properties = ['price', 'title', 'image', 'more']
								if 'reviews' in site.features
									properties.push 'reviews'
								scraper.scrape properties, (values) ->
									console.log "#{scraper.productSid} #{values.title}"
	else
		for siteName in ['Amazon', 'Zappos']
			site = Site.site siteName
			do (site) ->
				site.productScraperClass background, (ProductScraper) ->
					if ProductScraper.testProducts
						for sid in ProductScraper.testProducts
							site.productScraper background, sid, (scraper) ->
								properties = ['price', 'title', 'image']
								if 'reviews' in site.features
									properties.push 'reviews'
								scraper.scrape properties, (values) ->
									console.log "#{scraper.productSid} #{values.title}"

			console.log 'done'

	# Site.site(product.site).productScraper background, product.sid, (scraper) ->

	return

	# Product.scraper
	# 	siteName:'Newegg', productSid:'N82E16822149223'
	# 	(scraper) ->
	# 		scraper.scrape ['more'], (product) ->
	# 			console.log product

	# return
		
	products = []


	if process.argv[2]
		products.push site:process.argv[2], sid:process.argv[3]
	else
		products = [
			# {site:'Amazon', sid:'B008LBC8YQ'}
			# {site:'Amazon', sid:'B0050SWQ86'}
			{site:'Newegg', sid:'N82E16824236174'}

			# { productUrl: 'http://www.zappos.com/smartwool-heathered-rib-3-pair-pack-black', }
		]

	for product in products
		((product) ->
			Site.site(product.site).productScraper background, product.sid, (scraper) ->
				scraper.scrape ['image'], (properties) ->
					console.log properties

			# console.log Product.getBySid(product.site, product.sid)
			# Site.site(product.site).product(background, Product.getBySid(product.site, product.sid), (product) ->
			# 	product.images (image) ->
			# 		console.log images
			# )
		)(product)