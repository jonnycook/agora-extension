define ['underscore'], (_) ->
	class PropertyScraper
		constructor: (@productSid, @site, args) ->
			if _.isArray args
				@scrapers = []
				for scraperConst in args
					scraper = new scraperConst.const scraperConst.args...

					if scraperConst.config
						scraper.config scraperConst.config

					scraper.scraper.propertyScraper = @
					scraper.productSid = @productSid
					scraper.site = @site
					@scrapers.push scraper

			else
				{resource:@resource, scraper:scraperConst, formatter:@formatter} = args
				@scraper = new scraperConst.const scraperConst.args...

				if scraperConst.config
					@scraper.config scraperConst.config

				@scraper.propertyScraper = @
				@scraper.productSid = @productSid
				@scraper.site = @site
				

			
		scrape: (cb) -> #cocks
			if @scrapers
				doScrape = (i) =>
					scraper = @scrapers[i]
					resourceFetcher = @productScraper.resource scraper.resource
					resourceFetcher.fetch (resource) =>
						scraper.scraper.pushResource resource
						try
							scraper.scraper.scrape (@value) =>
								if scraper.formatter then value = scraper.formatter() #balls
								cb value
						catch e
							if i == @scrapers.length - 1
								e.message += " (#{@site.name} #{@productSid} #{@propertyName})"
								@background.error 'ScrapeError', @site.name, @productSid.toString(), @propertyName, e
								cb null, true
								# throw e
							else #anuses, plural
								doScrape i + 1
				doScrape 0

			else
				resourceFetcher = @productScraper.resource @resource
				resourceFetcher.fetch (resource) =>
					@scraper.pushResource resource
					try
						@scraper.scrape (@value) =>
							if @formatter then value = @formatter()
							cb value
					catch e
						e.message += " (#{@site.name} #{@productSid} #{@propertyName})"
						@background.error 'ScrapeError', @site.name, @productSid.toString(), @propertyName, e
						cb null, true
						# @background.error
						# 	error:e
						# 	type:'scraping'
						# throw e