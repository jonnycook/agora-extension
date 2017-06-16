// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var KateSpadeProductScraper;
  return KateSpadeProductScraper = (function(superClass) {
    extend(KateSpadeProductScraper, superClass);

    function KateSpadeProductScraper() {
      return KateSpadeProductScraper.__super__.constructor.apply(this, arguments);
    }

    KateSpadeProductScraper.prototype.version = 2;

    KateSpadeProductScraper.prototype.parseSid = function(sid) {
      var color, ref, size, sku;
      ref = sid.split('_'), sku = ref[0], color = ref[1], size = ref[2];
      return {
        sku: sku,
        color: color,
        size: size
      };
    };

    KateSpadeProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          var url;
          url = "http://www.katespade.com/-/" + this.productSid.sku + ",en_US,pd.html?";
          if (this.productSid.color) {
            url += "dwvar_" + this.productSid.sku + "_color=" + this.productSid.color + "&";
          }
          if (this.productSid.size) {
            url += "dwvar_" + this.productSid.sku + "_size=" + this.productSid.size;
          }
          return url;
        }
      },
      reviewData: {
        url: function() {
          return "http://katespade.ugc.bazaarvoice.com/5036-en_us/" + this.productSid.sku + "/reviews.djs?format=embeddedhtml";
        }
      }
    };

    KateSpadeProductScraper.prototype.properties = {
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
        scraper: ScriptedResourceScraper(function() {
          var str;
          if (this.productSid.color) {
            str = this.productSid.sku + "_" + this.productSid.color;
            return this.value("http://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/KateSpade/" + str + "?op_sharpen=0&resMode=sharp2&wid=467&fmt=jpg");
          } else {
            return this.value(this.declarativeScraper('scraper', 'image'));
          }
        })
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var color, fn, images, j, len, more, ref;
          more = this.declarativeScraper('scraper', 'more');
          images = {};
          more.images = images;
          ref = more.colors;
          fn = (function(_this) {
            return function(color) {
              return _this.execBlock(function() {
                this.get("https://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/KateSpade/" + this.productSid.sku + "_" + color.id + "_is?req=set,json,UTF-8", function(response) {
                  var obj;
                  obj = JSON.parse(response.match(/^s7jsonResponse\((.*?),""\);$/)[1]);
                  images[color.name] = _.map(obj.set.item, function(i) {
                    return "https://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/" + i.i.n;
                  });
                  this.value(more);
                  return this.done(true);
                });
                return null;
              });
            };
          })(this);
          for (j = 0, len = ref.length; j < len; j++) {
            color = ref[j];
            fn(color);
          }
          return this.value(more);
        })
      },
      rating: {
        resource: 'reviewData',
        scraper: PatternResourceScraper([
          [
            /Write the first review<\\\/a>/, 0, function() {
              return 0;
            }
          ], [/alt=\\"(.*?) \/ 5\\"/, 1]
        ])
      },
      ratingCount: {
        resource: 'reviewData',
        scraper: PatternResourceScraper([
          [
            /Write the first review<\\\/a>/, 0, function() {
              return 0;
            }
          ], [/<span class=\\"BVRRNumber\\">(\d+)/, 1]
        ])
      },
      reviews: {
        resource: 'reviewData',
        scraper: ScriptedResourceScraper(function() {
          var authorMatches, contentMatches, dateMatches, i, ratingsMatches, ref, reviews, reviewsText, titleMatch, titleMatches;
          reviewsText = (ref = this.resource.match(/BVRRDisplayContentBodyID([\S\s]*)/)) != null ? ref[1] : void 0;
          if (reviewsText) {
            titleMatches = this.matchAll(reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1);
            contentMatches = this.matchAll(reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1);
            ratingsMatches = this.matchAll(reviewsText, /title=\\"(\d+) \/ 5\\"/, 1);
            authorMatches = this.matchAll(reviewsText, /<span class=\\"BVRRNickname\\">([^<]*?) <\\\/span>/, 1);
            dateMatches = this.matchAll(reviewsText, /<span class=\\"BVRRValue BVRRReviewDate\\">([^<]*)<\\\/span>/, 1);
            reviews = (function() {
              var j, len, results;
              results = [];
              for (i = j = 0, len = titleMatches.length; j < len; i = ++j) {
                titleMatch = titleMatches[i];
                results.push({
                  title: titleMatch,
                  content: contentMatches[i],
                  rating: ratingsMatches[i],
                  author: authorMatches[i],
                  date: dateMatches[i]
                });
              }
              return results;
            })();
            return this.value(reviews);
          } else {
            return this.value([]);
          }
        })
      }
    };

    return KateSpadeProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=KateSpadeProductScraper.js.map
