define -> class Public
	route: (obj) ->
		if obj.isA 'Decision'
			hash = md5(obj.saneId() + 'salty apple sauce')
			id = obj.saneId() + ''
			garbledId = ''
			for i in [0...id.length]
				garbledId += id[i] + hash[i]

			"#{env.base}/decisions/#{garbledId}"

	get: (type, id, cb) ->
		record = @agora.db.table(type).bySaneId id
		if record
			cb? true
		else
			@agora.background.httpRequest @agora.background.apiRoot + 'public/data.php',
				data:
					type:type
					id:id
				dataType: 'json'
				cb: (response) =>
					if response in ['accessDenied', 'invalidId']
						cb false
					else
						@agora.updater.transport.executeChanges response.data, 0, -> cb true, response.id