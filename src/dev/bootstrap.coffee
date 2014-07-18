require ['Agora', '../dev/DevBackground'], (Agora, DevBackground) ->
	window.devBackground = new DevBackground
	window.agora = new Agora devBackground,
		localTest: true
		initDb: (agora) ->
			mm = agora.modelManager

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

			createCompositeProduct = (type) ->
				composite = agora.modelManager.getModel('Composite').create type:type

				slots = systems[type]

				for slotType in slots
					slot = agora.modelManager.getModel('CompositeSlot').create type:slotType, composite_id:composite.get('id')

				composite


			product = mm.getModel('Product').getBySid('Dev', 'SID1')
			mm.getModel('Datum').create element_type:'Product', element_id:product.get('id'), type:'plainText', text:'Hello', url:'http://google.com', comment:'poop', title:'Title'
			mm.getModel('Datum').create element_type:'Product', element_id:product.get('id'), type:'video', text:'', url:'http://www.youtube.com/watch?v=mkRsz7didXI', comment:'', title:'(Sungha Jung) Felicity - Sungha Jung - YouTube'
			mm.getModel('Datum').create element_type:'Product', element_id:product.get('id'), type:'image', text:'', url:'http://agoraext.dev/resources/dev/519sTkNOmIL._AA300_.jpg', comment:'', title:'Product Image'
			mm.getModel('Datum').create element_type:'Product', element_id:product.get('id'), type:'url', text:'', url:'https://www.google.com/', comment:'', title:'Google'


			computerComposite = createCompositeProduct 'computer'

			cpuSlot = computerComposite.get('slots').find((i) -> i.get('type') == 'cpu')
			cpuSlot.set 'element_type', 'Product'
			cpuSlot.set 'element_id', mm.getModel('Product').getBySid('Dev', 'SID1').get('id')
			computerComposite.get('additionalContents').add mm.getModel('Product').getBySid('Dev', 'SID1')


			session = mm.getModel('Session').create title:'Session 1'
			mm.getModel('RootElement').create element_type:'Session', element_id:session.get 'id'

			bundle = mm.getModel('Bundle').create {}
			session.get('contents').add bundle
			bundle.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID1')
			session.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID2')
			bundle.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID3')


			bundle2 = mm.getModel('Bundle').create {}
			bundle2.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID1')
			bundle2.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID2')
			bundle2.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID3')

			bundle.get('contents').add bundle2


			session = mm.getModel('Session').create  title:'Session 2'
			mm.getModel('RootElement').create element_type:'Session', element_id:session.get 'id'

			session.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID4')
			session.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID5')

			session = mm.getModel('Session').create title:'Session 3'
			mm.getModel('RootElement').create element_type:'Session', element_id:session.get 'id'

			session.get('contents').add computerComposite

			list = mm.getModel('List').create()
			list.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID1')
			list.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID2')
			list.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID3')
			# list.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID4')
			list.get('contents').add bundle

			decision = mm.getModel('Decision').create
				list_id: list.get 'id'


			list.get('contents').add decision

			session.get('contents').add decision

			listElement = list.get('elements').find (instance) => instance.get('element_id') == list.get('contents').get(0).get('id') && instance.get('element_type') == 'Product'
			decision.get('selection').add listElement
			listElement = list.get('elements').find (instance) => instance.get('element_id') == list.get('contents').get(1).get('id') && instance.get('element_type') == 'Product'
			decision.get('selection').add listElement


			mm.getModel('RootElement').create element_type:'Product', element_id:mm.getModel('Product').getBySid('Dev', 'SID1').get 'id'


			# bundle.get('contents').add mm.getModel('Product').getBySid('Dev', 'SID1')
			# bundle.get('contents').add mm.getModel('Bundle').add {}

	agora.getContentScript 'http://agoraext.dev/', (script) ->
		eval script
