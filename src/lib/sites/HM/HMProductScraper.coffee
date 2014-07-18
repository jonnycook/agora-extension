define ['scraping/ProductScraper',
	'scraping/resourceScrapers/PatternResourceScraper',
	'scraping/resourceScrapers/ScriptedResourceScraper', 
	'scraping/resourceScrapers/JsonResourceScraper',
	'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) ->

	class HMProductScraper extends ProductScraper
		parseSid: (sid) ->
			[id,color,size] = sid.split '-'
			id:id, color:color, size:size

		resources:
			productPage:
				url: -> "http://www.hm.com/us/product/#{@productSid.id}?article=#{@productSid.id}-#{@productSid.color}&variant=#{@productSid.size}"

		properties:
			title:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'title'
			image:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'image'
			price:
				resource: 'productPage'
				scraper: DeclarativeResourceScraper 'scraper', 'price'
			more:
				resource: 'productPage'
				scraper: ScriptedResourceScraper ->
					more = @declarativeScraper 'scraper', 'more'
					match = /hm.data.product = (\{[\S\s]*?\})\s*<\/script>/.exec(@resource)[1]

					obj = JSON.parse match

					images = {}

					for id,article of obj.articles
						images[article.description] = for img in article.images
							"http://lp.hm.com/hmprod?set=key[source],value[#{img.url}]&set=key[rotate],value[0]&set=key[width],value[3692]&set=key[height],value[4317]&set=key[x],value[336]&set=key[y],value[263]&set=key[type],value[FASHION_FRONT]&hmver=0&call=url[file:/product/large]"
					
					more.images = images
	
					@value more
