// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var AmericanApparelProductScraper;
  return AmericanApparelProductScraper = (function(_super) {
    __extends(AmericanApparelProductScraper, _super);

    function AmericanApparelProductScraper() {
      return AmericanApparelProductScraper.__super__.constructor.apply(this, arguments);
    }

    AmericanApparelProductScraper.prototype.parseSid = function(sid) {
      var color, id, _ref;
      _ref = sid.split('-'), id = _ref[0], color = _ref[1];
      return {
        id: id,
        color: color
      };
    };

    AmericanApparelProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://store.americanapparel.net/product/index.jsp?productId=" + this.productSid.id + "&c=" + this.productSid.color;
        }
      },
      reviewData: {
        url: function() {
          return "http://i.americanapparel.net/storefront/ratingsreviews/Reviews.aspx?r=1&s=" + this.productSid.id;
        }
      }
    };

    AmericanApparelProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'title')
      },
      price: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'price')
      },
      image: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'image')
      },
      rating: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'rating')
      },
      ratingCount: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'ratingCount')
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var color, match, more, name, obj, size, url;
          more = this.declarativeScraper('scraper', 'more');
          match = /<input type="hidden" value="([^"]*)" id="skuVarData"\/>/.exec(this.resource)[1];
          obj = JSON.parse(match.replace(/&quot;/g, '"'));
          more.colors = (function() {
            var _ref, _results;
            _ref = obj.colors;
            _results = [];
            for (name in _ref) {
              color = _ref[name];
              _results.push({
                name: name,
                image: color.hoverImage
              });
            }
            return _results;
          })();
          more.sizes = (function() {
            var _i, _len, _ref, _results;
            _ref = obj.sizes;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              size = _ref[_i];
              _results.push(size.value);
            }
            return _results;
          })();
          url = this.resource.match(/AA\.productImgsUrl = "([^"]*)";/)[1];
          this.execBlock(function() {
            this.get(url, function(response) {
              var image;
              more.images = (function() {
                var _i, _len, _ref, _results;
                _ref = JSON.parse(response);
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  image = _ref[_i];
                  _results.push("http://i.americanapparel.net" + image[1]);
                }
                return _results;
              })();
              this.value(more);
              return this.done(true);
            });
            return null;
          });
          return this.value(more);
        })
      },
      reviews: {
        resource: 'reviewData',
        scraper: DeclarativeResourceScraper('reviews', 'reviews')
      }
    };

    return AmericanApparelProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=AmericanApparelProductScraper.map
