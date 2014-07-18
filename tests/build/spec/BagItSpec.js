(function() {

  req(['BagIt', 'Site', 'TestBrowser'], function(BagIt, Site, TestBrowser) {
    return describe('BagIt', function() {
      it('should get site', function() {
        var site;
        site = Site.siteForUrl('http://www.amazon.com/test');
        return expect(site.name).toBe('Amazon');
      });
      return it('should call content script', function() {
        var bagIt, browser, called, eventSpy;
        browser = new TestBrowser;
        bagIt = new BagIt(browser);
        called = false;
        eventSpy = jasmine.createSpy().andCallFake(function(script) {
          expect(script).toMatch(/\/\* content script \*\//);
          called = true;
          eval("var result = " + script);
          return expect(result).toBe(true);
        });
        browser.triggerRequest({
          url: 'http://www.amazon.com/test'
        }, 'getScript', eventSpy);
        expect(eventSpy).toHaveBeenCalled;
        return waitsFor(function() {
          return called;
        });
      });
    });
  });

}).call(this);
