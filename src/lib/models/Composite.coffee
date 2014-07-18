define ['model/Model', 'Site'], (Model, Site) ->
	class Composite extends Model
		createWithType: (type) ->
			composite = @create type:type
			systems = 
				computer: [
					'harddrive'
					'monitor'
					'cpu'
					'ram'
					'motherboard'
					'graphicsCard'
					'powerSupply'
					'keyboard'
					'mouse'
					'soundcard'
					'cooling'
					'speakers'
				]

			slots = systems[type]

			for slotType in slots
				slot = @manager.getModel('CompositeSlot').create type:slotType, composite_id:composite.get('id')

			composite
