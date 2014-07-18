req ['sites/Amazon/AmazonProductScraper', 'TestBrowser'], (AmazonProductScraper, TestBrowser) ->
	describe 'AmazonProductScraper', ->
		
		createScraper = -> new AmazonProductScraper('B003VUO6H4', new TestBrowser)
# 		
# 		it 'should scrape title', ->
# 			scraper = createScraper()
# 			scraper.properties.title.scrape (value) ->
# 				console.log value
# 				
		it 'should scrape price', ->
			scraper = createScraper()
			scraper.properties.price.scrape (value) ->
				console.log value
				
		it 'should scrape image', ->
			scraper = createScraper()
			scraper.properties.image.scrape (value) ->
				console.log value

				
		
# 		it 'should work', ->
# 			scraper = createScraper()
# 			
# 			scraper.scrape ['title', 'price'], (properties) =>
# 				console.log properties
