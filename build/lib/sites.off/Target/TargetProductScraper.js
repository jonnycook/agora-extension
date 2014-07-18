// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var TargetProductScraper;
  return TargetProductScraper = (function(_super) {
    __extends(TargetProductScraper, _super);

    function TargetProductScraper() {
      return TargetProductScraper.__super__.constructor.apply(this, arguments);
    }

    TargetProductScraper.testProducts = [];

    TargetProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.target.com/p/-/A-" + this.productSid;
        }
      }
    };

    TargetProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp('<span class="fn" itemprop="name">([^<]*)'), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<span class="offerPrice" itemprop="price">\s*\$(\S*)/), 1)
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<img itemprop="image" height="[^"]*" width="[^"]*" alt="[^"]*" src="([^"]*)/), 1)
      }
    };

    return TargetProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=TargetProductScraper.map