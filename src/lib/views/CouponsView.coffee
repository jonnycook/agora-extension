define ['View', 'Site', 'Formatter'], (View, Site, Formatter) ->
	class CouponsView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId
		
		initAsync: (args, done) ->
			@resolveObject args, (@product) =>
				@data = @clientValue product.field 'coupons'
				done()
