req ['Agora', 'Site', 'TestBrowser'], (Agora, Site, TestBrowser) ->
	describe 'Agora', ->
		it 'should get site', ->
			site = Site.siteForUrl 'http://www.amazon.com/test'
			expect(site.name).toBe 'Amazon'
		
		it 'should call content script', () ->
			browser =  new TestBrowser
			agora = new Agora browser
			
			called = false
			eventSpy = jasmine.createSpy()
				.andCallFake (script) ->
					expect(script).toMatch /\/\* content script \*\//
					#expect(script).toMatch '[{,]\s*run\s*\:'
					called = true
					
					eval "var result = #{script}"
					expect(result).toBe(true)
			
			browser.triggerRequest
				url: 'http://www.amazon.com/test'
				'getScript'
				eventSpy
				
			expect(eventSpy).toHaveBeenCalled
			
			waitsFor -> called