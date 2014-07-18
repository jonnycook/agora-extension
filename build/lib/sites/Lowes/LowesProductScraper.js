// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var LowesProductScraper;
  return LowesProductScraper = (function(_super) {
    __extends(LowesProductScraper, _super);

    function LowesProductScraper() {
      return LowesProductScraper.__super__.constructor.apply(this, arguments);
    }

    LowesProductScraper.testProducts = ['6051381'];

    LowesProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.lowes.com/pd_" + this.productSid;
        }
      }
    };

    return LowesProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=LowesProductScraper.map