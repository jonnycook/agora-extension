define ['taxonomy', 'util', 'underscore'], (taxonomy, util, _) ->
	class SiteProduct
		constructor: (@product) ->
		properties: (properties, cb) ->

		usedProperties: (type, cb) ->
			properties = taxonomy.properties type
			count = properties.length
			if count
				usedProperties = []
				for property in properties
					do (property) =>
						@property property, (value) =>
							if value != undefined
								usedProperties.push property
							cb usedProperties if !--count
			else
				cb []

		property: (path, cb) ->
			parts = path.split '.'
			func = @types?[parts[0]]?[parts[1]]
			if func
				func.call @, cb
			else
				cb()

		reviews: (cb) ->
			@product.with 'reviews', (reviews) ->
				cb reviews:reviews ? []


		genWidgets: (obj, widgetDefs) ->
			widgets = []
			for prop, widgetDef of widgetDefs
				value = if widgetDef.obj
					widgetDef.obj
				else
					parts = prop.split '.'
					o = obj
					for name in parts
						o = o[name]
					o

				continue if !value?
				dataType = if _.isString value
					'string'
				else if _.isArray value
					'array'
				else if _.isPlainObject value
					'object'

				type = if prop == 'reviews'
					'Reviews'
				else
					switch dataType
						when 'string'
							'html'
						when 'array'
							'List'
						when 'object'
							'Details'

				if type == 'Reviews'
					continue if value.length == 0

				if _.isString widgetDef
					widgetDef =
						title:widgetDef
						type:type

				widget =
					type:widgetDef.type ? type
					data:
						title:widgetDef.title

				if widget.type == 'html'
					widgetDef.stripHtml ?= true
					widget.data.maxHeight = if widgetDef.maxHeight? then widgetDef.maxHeight else 'none'
					

				else if widget.type == 'Reviews'
					widget.data.maxHeight = widgetDef.maxHeight if widgetDef.maxHeight?
					widget.data.count = widgetDef.count if widgetDef.count?

				if widget.type == 'html' && widgetDef.stripHtml
					widget.data.content = util.stripHtml value, null, @baseUrl
				else
					if widget.type == 'Reviews'
						value = _.map value, (review) =>
							newReview = _.clone review
							newReview.url = util.url newReview.url
							if widgetDef.map
								for p,mapping of widgetDef.map
									if _.isFunction mapping
										newReview[p] = mapping review
									else
										newReview[p] = review[mapping]

							newReview.review = util.stripHtml newReview.review, null, @baseUrl
							newReview

					else
						if widget.type == 'List'
							value = _.map value, (v) => util.stripHtml v, null, @baseUrl

						if widgetDef.map
							if dataType == 'array'
								value = _.map value, widgetDef.map
							else if dataType == 'string'
								if _.isString widgetDef.map
									value = value[widgetDef.map]
								else
									value = widgetDef.map value

					widget.data.content = value

				widgets.push widget
			widgets

