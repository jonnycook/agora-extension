sites = ['Amazon']
classPaths = "sites/#{site}/#{site}Product" for site in sites
define classPaths, ->
	classes = arguments
	class: (site) ->
		index = sites.indexOf site
		classes[index]
