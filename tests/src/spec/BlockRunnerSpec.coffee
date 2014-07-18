_it = ->

req ['BlockRunner'], (BlockRunner) ->
	describe 'BlockRunner', ->
		it 'should work', ->
			log = (str) ->
				console.log str
			
			block = new BlockRunner ->
				@eachSerially
					1: ->						
						@try
							a: ->
								log 'a'
		
							b: ->
								log 'b'
								true
							
			block.exec -> log 'done all'
			log 'end'
			
		it 'should work', ->
			done = false
			
			logs = []
			log = (str) -> 
				console.log str
				logs.push str
			
			block = new BlockRunner ->
				@onDone -> log 'done a'
				log 'run a'
				
				@execBlock ->
					@onDone -> log 'done a.b'
					log 'run a.b'
					
					@execBlock ->
						@onDone -> log 'done a.b.c'
						log 'run a.b.c'
						setTimeout (=> @done()), 2000
						null
					
				@execBlock ->
					@onDone -> log 'done a.d'
					log 'run a.d'
					setTimeout (=> @done()), 1000
					null
					
				#true
					
			block.exec ->
				log 'done all'
				
				expect(logs.toString()).toBe [
					'run a',
					'run a.b',
					'run a.b.c',
					'run a.d',
					'done a.d',
					'done a.b.c',
					'done a.b',
					'done a',
					'done all'
				].toString()
				done = true
				
			waitsFor -> done
