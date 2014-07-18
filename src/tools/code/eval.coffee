output = null
RegExp.prototype._exec = RegExp.prototype.exec
RegExp.prototype.exec = (subject) ->
	matches = @_exec subject
	# console.debug subject, matches
	add type:'match', value:matches
	matches

String.prototype._match = String.prototype.match
String.prototype.match = (pattern) ->
	matches = @_match pattern
	# console.debug matches
	add type:'match', value:matches

	matches


matchName = null
set = (name) ->
	matchName = name

add = (opts) ->
	if matchName && !opts.name
		opts.name = matchName
		matchName = null
	# console.debug opts
	output.push opts

matchAll = (subject, pattern, group=false) ->
	return [] if not pattern
	pattern = pattern.source if pattern instanceof RegExp
	globalMatches = subject._match new RegExp pattern, 'g'
	if !globalMatches
		console.error "failed to match #{pattern}"
		return []
	regExp = new RegExp pattern
	# output.push globalMatches
	r = []
	for globalMatch in globalMatches
		matches = globalMatch._match regExp
		if group == false
			r.push matches
		else
			r.push matches[group]

	add type:(if group == false then 'matchAll' else 'match'), value:r

	r


window.addEventListener 'message', (event) ->
	window.subject = event.data.subject
	output = []
	code = event.data.code

	(->
		eval code
		matches = code._match /(\$\w*)\s*=/g
		if matches
			for match in matches
				[__, variableName, name] = /(\$(\w*))\s*=/._exec(match)
				eval "add({type:'variable', name:'#{name}', value:#{variableName}});"

	).apply
		matchAll:matchAll
		resource:
			_match: (args...) -> subject?._match args...
			toString: -> subject
			matchAll: (args...) -> matchAll subject, args...
			match: (pattern) -> subject.match pattern
		

	event.source.postMessage output, event.origin

