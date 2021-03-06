// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var VitacostProductScraper;
  return VitacostProductScraper = (function(superClass) {
    extend(VitacostProductScraper, superClass);

    function VitacostProductScraper() {
      return VitacostProductScraper.__super__.constructor.apply(this, arguments);
    }

    VitacostProductScraper.testProducts = [''];

    VitacostProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "" + this.productSid;
        }
      }
    };

    return VitacostProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=VitacostProductScraper.js.map
