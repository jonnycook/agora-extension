// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'util', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, util, _) {
  var ExpressProductScraper;
  return ExpressProductScraper = (function(_super) {
    __extends(ExpressProductScraper, _super);

    function ExpressProductScraper() {
      return ExpressProductScraper.__super__.constructor.apply(this, arguments);
    }

    ExpressProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.express.com/catalog/product_detail.jsp?productId=" + this.productSid + "&categoryId=cat1040005";
        }
      },
      reviewData: {
        url: function() {
          return "http://express.ugc.bazaarvoice.com/6549/" + this.productSid + "/reviews.djs?format=embeddedhtml";
        }
      }
    };

    ExpressProductScraper.prototype.properties = {
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
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var more;
          more = this.declarativeScraper('scraper', 'more');
          this.execBlock(function() {
            this.post('http://www.express.com/catalog/gadgets/color_size_gadget.jsp', {
              productId: this.productSid.value,
              categoryId: 'cat1040005'
            }, function(response) {
              var color, colorMatch, colorMatches, colors, images, _fn, _i, _j, _len, _len1, _ref, _ref1;
              more.color = (_ref = response.match(/<span class="selectedColor">([^<]*)/)) != null ? _ref[1] : void 0;
              colors = [];
              colorMatches = this.matchAll(response, /<img class="cat-pro-swatch[^"]*" src="([^"]*)" width="51" height="34" alt="([^"]*)" \/>/);
              for (_i = 0, _len = colorMatches.length; _i < _len; _i++) {
                colorMatch = colorMatches[_i];
                colors.push({
                  id: colorMatch[1].match(/([^\/]*)_s\?/)[1],
                  name: colorMatch[2],
                  swatch: "http:" + colorMatch[1]
                });
              }
              more.colors = colors;
              more.sizes = this.matchAll(response, /<option class="availableSize" value="([^"]*)/, 1);
              images = {};
              more.images = images;
              _ref1 = more.colors;
              _fn = (function(_this) {
                return function(color) {
                  return _this.execBlock(function() {
                    this.get("http://images.express.com/is/image/expressfashion/" + color.id + "?req=set,json", function(response) {
                      var obj;
                      obj = JSON.parse(response.match(/^s7jsonResponse\((.*?),""\);$/)[1]);
                      images[color.name] = _.map(obj.set.item, function(i) {
                        return "http://images.express.com/is/image/" + i.i.n;
                      });
                      this.value(more);
                      return this.done(true);
                    });
                    return null;
                  });
                };
              })(this);
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                color = _ref1[_j];
                _fn(color);
              }
              this.value(more);
              return this.done();
            });
            return null;
          });
          return this.value(more);
        })
      },
      rating: {
        resource: 'reviewData',
        scraper: PatternResourceScraper([
          [
            /Be the first to<\\\/span>/, 0, function() {
              return 0;
            }
          ], [/BVRRRatingOverall_Rating_Summary_1.*?alt=\\"([.\d]*) out of 5\\"/, 1]
        ])
      },
      ratingCount: {
        resource: 'reviewData',
        scraper: PatternResourceScraper([
          [
            /Be the first to<\\\/span>/, 0, function() {
              return 0;
            }
          ], [/Read all <span class=\\"BVRRNumber\\">([\d,]*)<\\\/span> review/, 1]
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
            ratingsMatches = this.matchAll(reviewsText, /title=\\"(\d+) out of 5\\"/, 1);
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

    return ExpressProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=ExpressProductScraper.map
