(function() {

  req(['scraping/ResourceFetcher', 'TestBrowser'], function(ResourceFetcher, TestBrowser) {
    return describe('ResourceFetcher', function() {
      return it('should get resource', function() {
        var finished, resourceFetcher, testBrowser;
        testBrowser = new TestBrowser;
        testBrowser.urlData = {
          'http://test/1': 'one'
        };
        resourceFetcher = new ResourceFetcher({
          url: function() {
            return "http://test/" + this.productSid;
          }
        });
        resourceFetcher.browser = testBrowser;
        finished = false;
        resourceFetcher.fetch(1, function(resource) {
          expect(resource).toLookLike('one');
          return finished = true;
        });
        return waitsFor(function() {
          return finished;
        });
      });
    });
  });

}).call(this);
