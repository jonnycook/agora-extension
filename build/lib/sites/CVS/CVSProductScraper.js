// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var CVSProductScraper;
  return CVSProductScraper = (function(_super) {
    __extends(CVSProductScraper, _super);

    function CVSProductScraper() {
      return CVSProductScraper.__super__.constructor.apply(this, arguments);
    }

    CVSProductScraper.testProducts = ['681325'];

    CVSProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.cvs.com/shop/product-detail/-?skuId=" + this.productSid;
        }
      }
    };

    CVSProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: new PatternResourceScraper(new RegExp(/<h1 class="prodName">([^<]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: new PatternResourceScraper([[new RegExp(/data-salePrice="\$([^"]*)/), 1], [new RegExp(/<span itemprop="price">[\s]+\$([^<]*)/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: new PatternResourceScraper(new RegExp(/<img itemprop="image" src="([^"]*)/), 1)
      },
      more: {
        resource: 'productPage',
        scraper: new ScriptedResourceScraper(function() {
          var col, content, match, matches, overview, overviewMatches, price, specMatches, specs, switches, text, title, value, _i, _j, _len, _len1;
          switches = {
            overview: false,
            rating: false,
            reviewCount: false,
            originalPrice: true
          };
          value = {};
          if (switches.overview) {
            overview = [];
            matches = this.resource.match(/<div class="productIngredients" id="prodDesc"([\S\s]*?)<\/div>/);
            overviewMatches = matches[1].match(/<p([\S\s]*?)<\/p>/g);
            for (_i = 0, _len = overviewMatches.length; _i < _len; _i++) {
              match = overviewMatches[_i];
              text = match.match(/<p([\S\s]*?)<\/p>/);
              overview.push(text[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " "));
            }
            specs = {};
            specMatches = matches[1].match(/<li([^<]+)/g);
            if (specMatches) {
              for (_j = 0, _len1 = specMatches.length; _j < _len1; _j++) {
                match = specMatches[_j];
                col = match.match(/(:)/);
                if (col) {
                  title = match.match(/<li>([^:]+)/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
                  content = match.match(/:([^<]+)/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
                  specs[title] = content;
                } else {
                  title = match.match(/<li>([^<]+)/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
                  specs[title] = null;
                }
              }
              overview.push(specs);
            }
            value.overview = overview;
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/<div class="priceStrike">([\S\s]*?)<\/div>/);
            if (matches) {
              price = matches[1];
              value.originalPrice = price.match(/\$([\S\s]*)/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
            }
          }
          return this.value(value);
        })
      }
    };

    return CVSProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=CVSProductScraper.map
