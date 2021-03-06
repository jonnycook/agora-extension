// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper) {
  var GeneralProductScraper;
  return GeneralProductScraper = (function(superClass) {
    extend(GeneralProductScraper, superClass);

    function GeneralProductScraper() {
      return GeneralProductScraper.__super__.constructor.apply(this, arguments);
    }

    GeneralProductScraper.productSid = function(background, url, cb) {
      return cb(url);
    };

    GeneralProductScraper.prototype.resources = {
      page: {
        url: function() {
          return this.productSid;
        }
      }
    };

    GeneralProductScraper.prototype.properties = {
      title: {
        resource: 'page',
        scraper: PatternResourceScraper(/<title>\s*([^<]*)<\/title>/i, 1)
      },
      price: {
        resource: 'page',
        scraper: PatternResourceScraper(/((?:\$|EUR )[0-9]+([.,][0-9]+)?)/, 1, true, '')
      }
    };

    return GeneralProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=GeneralProductScraper.js.map
