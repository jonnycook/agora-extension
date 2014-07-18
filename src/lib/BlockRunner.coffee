define ['underscore'], (_) ->
	class BlockRunner
		constructor: (@code) ->
			@ref = 0
		
		onDone: (cb) ->
			@_onDone ?= []
			@_onDone.unshift cb
			
			
		done: (@result) -> @release()
				
		retain: -> ++@ref
		release: ->
			if @ref == 0
				throw new Error 'ref is already 0'
			else
				--@ref
				if @ref == 0
					if @_onDone then cb(@result) for cb in @_onDone
					@calledDone = true


		try: (blockMap) ->
			names = _.keys blockMap
			blocks = _.values blockMap
			i = 0
			
			@retain()
			
			nextBlock = =>
				block = blocks[i]
				if block
					++ i
					b = @spawnBlock block, names[i - 1]
					b.resultMap = (result) ->
						if result == true then true
						else if result == null then null
						else false
					
					b.onDone (result) =>
						if result == false
							nextBlock()
						else
							# console.debug b.path
							@release()
					b.exec()
					
				else
					@release()
					
			nextBlock()

		
		eachSerially: (blockMap) ->
			names = _.keys blockMap
			blocks = _.values blockMap
			i = 0
			
			@retain()
			
			nextBlock = =>
				block = blocks[i]
				if block
					++ i
					
					b = @spawnBlock block, names[i - 1]
					b.onDone ->
						nextBlock()
					b.exec()
				else
					@release()
					
			nextBlock()
							
		spawnBlock: (code, name = '') ->
			@retain()
			@children = true # ugly
			
			b = ->
			b.prototype = @
			
			if @root then b.prototype = @root else b.prototype = @
			
			block = new b code
			block.parent = @
			block.name = name
			block.code = code
			block.root = b.prototype
			block.children = 0
			block.ref = 0
			block._onDone = []
			block.result = null
			
			if @path
				block.path = @path.concat [name]
			else
				block.path = [name]
		
			block.onDone => @release()
			block
			
		execBlock: (code) ->
			block = @spawnBlock code
			block.exec()
		
		exec: (_done) ->
			if _done then @onDone _done
			
			@retain()
			@result = @code()
			if @resultMap then @result = @resultMap @result
			
			if @result != null || @children then @release()
