req ['scraping/Resource'], (Resource) ->
	describe 'Resource', ->
		it 'should work', ->
			resource = new Resource "test"
			expect(resource).toLookLike 'test'
			expect(resource.safeMatch 'test').toBeTruthy
			expect(-> resource.safeMatch 'poop').toThrow 'poop not found'
			expect(resource.substr(0, 1)).toLookLike 't'
			