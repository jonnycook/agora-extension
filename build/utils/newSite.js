// Generated by CoffeeScript 1.10.0
var dir, fs, lcSiteName, siteName;

fs = require('fs');

console.log(process.argv);

siteName = process.argv[2];

dir = "src/lib/sites/" + siteName;

fs.mkdirSync(dir);

fs.writeFileSync(dir + "/research", '');

lcSiteName = siteName.toLowerCase();

fs.writeFileSync(dir + "/config.coffee", ("excludedFeatures: ['offers', 'deals', 'reviews', 'rating']\nhasProductClass:true\nslug: '" + lcSiteName + "'\nhosts: ['www." + lcSiteName + ".com']\ncurrency: 'dollar'\nscraper:true\nhasMore:false\nicon: 'http://www." + lcSiteName + ".com/favicon.ico'").trim());

fs.writeFileSync(dir + "/" + siteName + "Product.coffee", ("define ['scraping/SiteProduct', 'util', 'underscore'], (SiteProduct, util, _) ->\n	class " + siteName + "Product extends SiteProduct\n		images: (cb) ->\n			@product.with 'more', (more) =>\n				images = []\n				cb {'':images}, ''").trim());

fs.writeFileSync(dir + "/" + siteName + "ProductScraper.coffee", ((function() {
  switch (process.argv[3]) {
    case 'normal':
      return "define ['scraping/ProductScraper',\n	'scraping/resourceScrapers/PatternResourceScraper',\n	'scraping/resourceScrapers/ScriptedResourceScraper', \n	'scraping/resourceScrapers/JsonResourceScraper',\n	'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], (ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) ->\n\n	class " + siteName + "ProductScraper extends ProductScraper\n		parseSid: (sid) -> {}\n\n		resources:\n			productPage:\n				url: -> \"\"\n\n		properties:\n			title:\n				resource: 'productPage'\n				scraper: \n			# price:\n			# 	resource: 'productPage'\n			# 	scraper: \n			# image:\n			# 	resource: 'productPage'\n			# 	scraper: \n			# rating: \n			# 	resource: 'productPage'\n			# 	scraper:\n			# ratingCount: \n			# 	resource: 'productPage'\n			# 	scraper: \n			# more:\n			# 	resource: 'productPage'\n			# 	scraper: ScriptedResourceScraper ->\n			# 		more = @declarativeScraper 'scraper', 'more'\n\n			# 		@value more\n			# reviews:\n			# 	resource: 'productPage'\n			# 	scraper: ScriptedResourceScraper ->\n					";
    case 'declarative':
      return "define ['scraping/ProductScraper'], (ProductScraper) ->\n	ProductScraper.declarativeProductScraper 'scraper',\n		resources:\n			productPage:\n				url: -> \"\"\n		scraper: 'scraper'\n		resource: 'productPage'";
  }
})()).trim());

fs.writeFileSync(dir + "/" + siteName + "SiteInjector.coffee", ("define -> d: ['DataDrivenSiteInjector'], c: ->\n	class " + siteName + "SiteInjector extends DataDrivenSiteInjector\n		productListing:\n			image: 'a img'\n			productSid: (href, a, img) ->\n\n		productPage:\n			test: -> false\n			productSid: -> 0\n			imgEl: ''").trim());

//# sourceMappingURL=newSite.js.map
