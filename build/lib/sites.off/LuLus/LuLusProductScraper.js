// Generated by CoffeeScript 1.7.1
define(['scraping/ProductScraper'], function(ProductScraper) {
  return ProductScraper.declarativeProductScraper('scraper', {
    resources: {
      productPage: {
        url: function() {
          return "http://www.lulus.com/products/" + this.productSid + ".html";
        }
      }
    },
    scraper: 'scraper',
    resource: 'productPage'
  });
});

//# sourceMappingURL=LuLusProductScraper.map