req ['scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/Resource'], (ScriptedResourceScraper, Resource) ->
	describe 'ScriptedResourceScraper', ->
		it 'should work', ->
			scraper = new ScriptedResourceScraper ->
				@try
					hasSky: ->
						setTimeout (=>
							if @resource.match 'as'
								@value status:'has sky'
								@done true
							else
								@done false
						), 1000
						null
					
					noSky: ->
						@value status:'no sky'
						
						@eachSerially
							color: ->
								matches = @resource.match 'red|blue'
								color = matches[0]
								@value color:color
								setTimeout (=> @done true), 1000
								null
							moonOrPlanet: ->
								matches = @resource.match 'moon|planet'
								moonOrPlanet = matches[0]
								@value moonOrPlanet:moonOrPlanet
				
			scraper.pushResource new Resource("The sky is red under the planet")
			
			scraper.scrape ->
				console.log scraper.value()