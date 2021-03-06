// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var WetSealProductScraper;
  return WetSealProductScraper = (function(_super) {
    __extends(WetSealProductScraper, _super);

    function WetSealProductScraper() {
      return WetSealProductScraper.__super__.constructor.apply(this, arguments);
    }

    WetSealProductScraper.prototype.parseSid = function(sid) {
      var color, size, sku, _ref;
      _ref = sid.split('_'), sku = _ref[0], color = _ref[1], size = _ref[2];
      return {
        sku: sku,
        color: color,
        size: size
      };
    };

    WetSealProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          var url;
          url = "http://www.wetseal.com/" + this.productSid.sku + ".html?";
          if (this.productSid.color) {
            url += "dwvar_" + this.productSid.sku + "_color=" + this.productSid.color + "&";
          }
          if (this.productSid.size) {
            url += "dwvar_" + this.productSid.sku + "_size=" + this.productSid.size;
          }
          return url;
        }
      },
      variationPage: {
        url: function() {
          return "http://www.wetseal.com/on/demandware.store/Sites-wetseal-Site/default/Product-Variation?pid=" + this.productSid.sku + "&dwvar_" + this.productSid.sku + "_color=" + this.productSid.color + "&format=ajax";
        }
      },
      reviewData: {
        url: function() {
          return "http://wetseal.ugc.bazaarvoice.com/9031-en_us/" + this.productSid.sku + "/reviews.djs?format=embeddedhtml";
        }
      }
    };

    WetSealProductScraper.prototype.properties = {
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
        scraper: DeclarativeResourceScraper('scraper', 'image', function(value) {
          return value.replace('&amp;', '&');
        })
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var color, images, matches, more, _fn, _i, _len, _ref;
          more = this.declarativeScraper('scraper', 'more');
          images = {};
          more.images = images;
          matches = /<h2>Alternate Views<\/h2>\s*<ul>([\S\s]*?)<\/ul>/.exec(this.resource);
          images[this.productSid.color] = this.matchAll(this.resource, /lgimg='\{"url":"([^"]*)/, 1);
          _ref = more.colors;
          _fn = (function(_this) {
            return function(color) {
              return _this.execBlock(function() {
                this.get("http://www.wetseal.com/on/demandware.store/Sites-wetseal-Site/default/Product-Variation?pid=" + this.productSid.sku + "&dwvar_" + this.productSid.sku + "_color=" + color.id + "&format=ajax", function(response) {
                  matches = /<h2>Alternate Views<\/h2>\s*<ul>([\S\s]*?)<\/ul>/.exec(response);
                  images[color.id] = this.matchAll(matches[1], /lgimg='\{"url":"([^"]*)/, 1);
                  this.value(more);
                  return this.done(true);
                });
                return null;
              });
            };
          })(this);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            color = _ref[_i];
            if (color.id === '') {
              continue;
            }
            _fn(color);
          }
          return this.value(more);
        })
      },
      rating: {
        resource: 'reviewData',
        scraper: PatternResourceScraper([
          [
            />Be the first to<\\\/span>/, 0, function() {
              return 0;
            }
          ], [/<span class=\\"BVRRNumber BVRRRatingRangeNumber\\">(\d*)<\\\/span>/, 1]
        ])
      },
      ratingCount: {
        resource: 'reviewData',
        scraper: PatternResourceScraper([
          [
            />Be the first to<\\\/span>/, 0, function() {
              return 0;
            }
          ], [/<span class=\\"BVRRCount BVRRNonZeroCount\\">Read <span class=\\"BVRRNumber\\">([^<]*)/, 1]
        ])
      },
      reviews: {
        resource: 'reviewData',
        scraper: ScriptedResourceScraper(function() {
          var authorMatches, contentMatches, dateMatches, i, ratingsMatches, reviews, reviewsText, titleMatch, titleMatches, _ref;
          reviewsText = (_ref = this.resource.match(/BVRRDisplayContentBodyID([\S\s]*)/)) != null ? _ref[1] : void 0;
          if (reviewsText) {
            titleMatches = this.matchAll(reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1);
            contentMatches = this.matchAll(reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1);
            ratingsMatches = this.matchAll(reviewsText, /alt=\\"(\d*) out of 5\\"/, 1);
            authorMatches = this.matchAll(reviewsText, /<span class=\\"BVRRNickname\\">([^<]*?) <\\\/span>/, 1);
            dateMatches = this.matchAll(reviewsText, /<span class=\\"BVRRValue BVRRReviewDate\\">([^<]*)<\\\/span>/, 1);
            reviews = (function() {
              var _i, _len, _results;
              _results = [];
              for (i = _i = 0, _len = titleMatches.length; _i < _len; i = ++_i) {
                titleMatch = titleMatches[i];
                _results.push({
                  title: titleMatch,
                  content: contentMatches[i],
                  rating: ratingsMatches[i],
                  author: authorMatches[i],
                  date: dateMatches[i]
                });
              }
              return _results;
            })();
            return this.value(reviews);
          } else {
            return this.value([]);
          }
        })
      }
    };

    return WetSealProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=WetSealProductScraper.map
