// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var FancyProductScraper;
  return FancyProductScraper = (function(_super) {
    __extends(FancyProductScraper, _super);

    function FancyProductScraper() {
      return FancyProductScraper.__super__.constructor.apply(this, arguments);
    }

    FancyProductScraper.testProducts = ['405991157672181989'];

    FancyProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://fancy.com/things/" + this.productSid;
        }
      }
    };

    FancyProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="fancy:name" content="([^"]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper([[new RegExp(/<meta property="fancy:price" content="\$([^"]*)/), 1], [new RegExp(/<span id="itemprice" style="display:none">\$([^<]*)/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:image" content="([^"]*)/), 1)
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var content, image, imageMatches, images, match, matches, name, num, overviewMatches, quantity, select, switches, value, _i, _j, _k, _len, _len1, _len2;
          switches = {
            images: true,
            description: true,
            reacts: true,
            select: true,
            quantity: true,
            shipping: false
          };
          value = {};
          if (switches.description) {
            matches = this.resource.match(/<meta property="og:description" content="([^"]*)/);
            value.description = matches[1];
          }
          if (switches.select) {
            select = {};
            matches = this.resource.match(/<select name="option_id" id="option_id">([\S\s]*?)<\/select>/);
            overviewMatches = matches[1].match(/<option[^>]*>([^<]*)<\/option>/g);
            for (_i = 0, _len = overviewMatches.length; _i < _len; _i++) {
              match = overviewMatches[_i];
              name = match.match(/<option[^>]*>([^<]*)<\/option>/)[1];
              content = match.match(/value="([^"]*)/)[1];
              select[name] = content;
            }
            value.select = select;
          }
          if (switches.quantity) {
            quantity = {};
            matches = this.resource.match(/<select name="quantity" id="quantity">([\S\s]*?)<\/select>/);
            overviewMatches = matches[1].match(/<option[^>]*>([^<]*)<\/option>/g);
            for (_j = 0, _len1 = overviewMatches.length; _j < _len1; _j++) {
              match = overviewMatches[_j];
              name = match.match(/<option[^>]*>([^<]*)<\/option>/)[1];
              content = match.match(/value="([^"]*)/)[1];
              quantity[name] = content;
            }
            value.quantity = quantity;
          }
          if (switches.reacts) {
            matches = this.resource.match(/reacts="([^"]+)/);
            if (matches) {
              num = parseInt(matches[1], 10);
              value.reacts = num + 1;
            }
          }
          if (switches.images) {
            images = [];
            matches = this.resource.match(/<ul class="big">([\S\s]*?)<\/ul>/);
            imageMatches = matches[1].match(/background-image:url\(([^\)]+)/g);
            for (_k = 0, _len2 = imageMatches.length; _k < _len2; _k++) {
              match = imageMatches[_k];
              image = match.match(/background-image:url\(([^\)]+)/);
              images.push(image[1]);
            }
            value.images = images;
          }
          return this.value(value);
        })
      }
    };

    return FancyProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=FancyProductScraper.map