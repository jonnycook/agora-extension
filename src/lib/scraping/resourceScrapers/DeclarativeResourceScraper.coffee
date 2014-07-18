define ['underscore', '../ResourceScraper', '../DeclarativeScraper'], (_, ResourceScraper, DeclarativeScraper) ->
	class DeclarativeResourceScraper extends ResourceScraper
		constructor: (@name, @property, @map) -> return ResourceScraper arguments if @ == window
			
		scrape: (cb) ->
			scrapers = @propertyScraper.productScraper.background.declarativeScrapers
			for scraper in scrapers
				if scraper.site == @site.name && scraper.name == @name
					if scraper.properties[@property]
						scraper = new DeclarativeScraper scraper.properties[@property]
						try
							result = scraper.scrape(@resource)[0]?.value
							cb if @map then @map result else result
							return
						catch e
							e.info = path:scraper.getPath()
							throw e
					else
						cb()
						return
			throw new Error "failed to find scraper for #{@site.name} #{@name}"