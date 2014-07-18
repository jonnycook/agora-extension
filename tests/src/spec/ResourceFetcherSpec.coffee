req ['scraping/ResourceFetcher', 'TestBrowser'], (ResourceFetcher, TestBrowser) ->
	describe 'ResourceFetcher', ->
		it 'should get resource', ->
		
			testBrowser = new TestBrowser
			testBrowser.urlData =
				'http://test/1': 'one'
		
			resourceFetcher = new ResourceFetcher
				url: -> "http://test/#{@productSid}"
				
			resourceFetcher.browser = testBrowser
			
			finished = false
			resourceFetcher.fetch 1, (resource) ->
				expect(resource).toLookLike 'one'
				finished = true
				
			waitsFor -> finished