// Generated by CoffeeScript 1.10.0
define(['scraping/ProductScraper'], function(ProductScraper) {
  return ProductScraper.declarativeProductScraper('scraper', {
    parseSid: function(sid) {
      var name, ref, style;
      ref = sid.split(':'), style = ref[0], name = ref[1];
      return {
        style: style,
        name: name
      };
    },
    resources: {
      productPage: {
        url: function() {
          return "http://www.nastygal.com/-/" + (this.productSid.name.toLowerCase());
        }
      }
    },
    scraper: 'scraper',
    resource: 'productPage'
  });
});

//# sourceMappingURL=NastyGalProductScraper.js.map
