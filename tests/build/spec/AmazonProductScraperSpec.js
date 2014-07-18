(function() {

  req(['sites/Amazon/AmazonProductScraper', 'TestBrowser'], function(AmazonProductScraper, TestBrowser) {
    return describe('AmazonProductScraper', function() {
      var createScraper;
      createScraper = function() {
        return new AmazonProductScraper('B003VUO6H4', new TestBrowser);
      };
      it('should scrape price', function() {
        var scraper;
        scraper = createScraper();
        return scraper.properties.price.scrape(function(value) {
          return console.log(value);
        });
      });
      return it('should scrape image', function() {
        var scraper;
        scraper = createScraper();
        return scraper.properties.image.scrape(function(value) {
          return console.log(value);
        });
      });
    });
  });

}).call(this);
