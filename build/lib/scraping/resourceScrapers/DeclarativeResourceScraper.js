// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['underscore', '../ResourceScraper', '../DeclarativeScraper'], function(_, ResourceScraper, DeclarativeScraper) {
  var DeclarativeResourceScraper;
  return DeclarativeResourceScraper = (function(superClass) {
    extend(DeclarativeResourceScraper, superClass);

    function DeclarativeResourceScraper(name, property, map) {
      this.name = name;
      this.property = property;
      this.map = map;
      if (this === window) {
        return ResourceScraper(arguments);
      }
    }

    DeclarativeResourceScraper.prototype.scrape = function(cb) {
      var e, error, i, len, ref, result, scraper, scrapers;
      scrapers = this.propertyScraper.productScraper.background.declarativeScrapers;
      for (i = 0, len = scrapers.length; i < len; i++) {
        scraper = scrapers[i];
        if (scraper.site === this.site.name && scraper.name === this.name) {
          if (scraper.properties[this.property]) {
            scraper = new DeclarativeScraper(scraper.properties[this.property]);
            try {
              result = (ref = scraper.scrape(this.resource)[0]) != null ? ref.value : void 0;
              cb(this.map ? this.map(result) : result);
              return;
            } catch (error) {
              e = error;
              e.info = {
                path: scraper.getPath()
              };
              throw e;
            }
          } else {
            cb();
            return;
          }
        }
      }
      throw new Error("failed to find scraper for " + this.site.name + " " + this.name);
    };

    return DeclarativeResourceScraper;

  })(ResourceScraper);
});

//# sourceMappingURL=DeclarativeResourceScraper.js.map
