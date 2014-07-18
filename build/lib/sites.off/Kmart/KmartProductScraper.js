// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var KmartProductScraper;
  return KmartProductScraper = (function(_super) {
    __extends(KmartProductScraper, _super);

    function KmartProductScraper() {
      return KmartProductScraper.__super__.constructor.apply(this, arguments);
    }

    KmartProductScraper.testProducts = [];

    KmartProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.kmart.com/-/p-" + this.productSid;
        }
      },
      productData: {
        type: 'json',
        url: function() {
          return "http://www.kmart.com/content/pdp/config/products/Kmart/" + this.productSid;
        }
      },
      priceData: {
        type: 'json',
        url: function() {
          var part;
          part = this.productSid[this.productSid.length - 1] === 'P' ? this.productSid.substr(0, this.productSid.length - 1) : this.productSid;
          return "http://www.kmart.com/content/pdp/products/pricing/" + part + "?variation=0&regionCode=0";
        }
      }
    };

    KmartProductScraper.prototype.properties = {
      title: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          return ("" + data.brandName + " " + data.title).trim();
        })
      },
      price: [
        {
          resource: 'productPage',
          scraper: PatternResourceScraper([[new RegExp(/<span class="pricing" itemprop="price">\$([^<]*)/), 1], [new RegExp(/<span class="salePrice" itemprop="price">\s*\$(\S*)/), 1]])
        }, {
          resource: 'priceData',
          scraper: JsonResourceScraper(function(data) {
            return data['price-response']['item-response']['sell-price']['$'];
          })
        }
      ],
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

    return KmartProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=KmartProductScraper.map
