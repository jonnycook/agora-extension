// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var SearsProductScraper;
  return SearsProductScraper = (function(_super) {
    __extends(SearsProductScraper, _super);

    function SearsProductScraper() {
      return SearsProductScraper.__super__.constructor.apply(this, arguments);
    }

    SearsProductScraper.testProducts = [];

    SearsProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.sears.com/-/p-" + this.productSid;
        }
      },
      productData: {
        type: 'json',
        url: function() {
          return "http://www.sears.com/content/pdp/config/products/Sears/" + this.productSid;
        }
      },
      priceData: {
        type: 'json',
        url: function() {
          var part;
          part = this.productSid[this.productSid.length - 1] === 'P' ? this.productSid.substr(0, this.productSid.length - 1) : this.productSid;
          return "http://www.sears.com/content/pdp/products/pricing/" + part + "?variation=0&regionCode=0";
        }
      }
    };

    SearsProductScraper.prototype.properties = {
      title: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          return ("" + data.brandName + " " + data.title).trim();
        })
      },
      price: {
        resource: 'priceData',
        scraper: JsonResourceScraper(function(data) {
          return data['price-response']['item-response']['sell-price']['$'];
        })
      },
      image: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          if (data.images[0].url.indexOf('?') === -1) {
            return "" + data.images[0].url + "?hei=623&wid=623&qlt=50,0&op_sharpen=1&op_usm=0.9,0.5,0,0";
          } else {
            return data.images[0].url;
          }
        })
      }
    };

    return SearsProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=SearsProductScraper.map
