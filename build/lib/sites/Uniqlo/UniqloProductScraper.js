// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var UniqloProductScraper;
  return UniqloProductScraper = (function(_super) {
    __extends(UniqloProductScraper, _super);

    function UniqloProductScraper() {
      return UniqloProductScraper.__super__.constructor.apply(this, arguments);
    }

    UniqloProductScraper.testProducts = {
      "086831-22": {
        "image": "http://uniqlo.scene7.com/is/image/UNIQLO/goods_22_086831?$pdp-medium$",
        "rating": "5",
        "ratingCount": "1",
        "title": "WOMEN SUPIMA COTTON TANK TOP",
        "price": "9.90",
        "more": {
          "description": "This tank top is made of soft Supima&reg; cotton in a shapely, feminine silhouette. Great for layering or wearing alone, this tank is available in a wide range of colors.",
          "materials": ["94% cotton, 6% spandex", "Machine wash cold", "Imported"],
          "sizes": ["XS", "S", "M", "L", "XL", "XXL"]
        }
      },
      "075819-68": {
        "image": "http://uniqlo.scene7.com/is/image/UNIQLO/goods_68_075819?$pdp-medium$",
        "rating": 0,
        "ratingCount": 0,
        "title": "WOMEN COLOR RIB SLEEVELESS TOP",
        "price": "5.90",
        "more": {
          "description": "This ribbed tank top offers a great fit in modern, minimalist style. Ideal for layering.",
          "materials": ["50% rayon, 50% cotton", "Machine wash cold, gentle cycle", "Imported"],
          "sizes": ["XS", "S", "M", "L", "XL"]
        }
      },
      "075481-09": {}
    };

    UniqloProductScraper.prototype.parseSid = function(sid) {
      var parts, _ref, _ref1, _ref2;
      parts = sid.split('-');
      return {
        id: parts[0],
        color: (_ref = parts[1]) != null ? _ref : '00',
        size: (_ref1 = parts[2]) != null ? _ref1 : '000',
        length: (_ref2 = parts[0]) != null ? _ref2 : '000'
      };
    };

    UniqloProductScraper.prototype.resources = {
      productData: {
        url: function() {
          return "http://www.uniqlo.com/us/store/gcx/getProductInfo.do?format=json&product_cd=" + this.productSid.id;
        }
      },
      reviewData: {
        url: function() {
          return "http://uniqloenus.ugc.bazaarvoice.com/5311-en_us/" + this.productSid.id + "/reviews.djs?format=embeddedhtml";
        }
      }
    };

    UniqloProductScraper.prototype.properties = {
      title: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          return data.goods_name.trim();
        })
      },
      price: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          return data.first_price;
        })
      },
      image: function(cb) {
        return cb("http://uniqlo.scene7.com/is/image/UNIQLO/goods_" + this.productSid.color + "_" + this.productSid.id + "?$pdp-medium$");
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
      more: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          var more;
          more = {};
          if (data.dtl_exp) {
            more.description = data.dtl_exp.trim();
          }
          more.materials = this.matchAll(data.material_info, /<li>([\S\s]*?)<\/li>/, 1);
          more.sizes = _.map(data.size_info_list, function(obj) {
            return obj.size_nm;
          });
          if (data.goods_sub_image_list) {
            more.images = _.map(data.goods_sub_image_list.split(';'), function(i) {
              return "http://uniqlo.scene7.com/is/image/UNIQLO/goods_" + i;
            });
          } else {
            more.images = [];
          }
          more.colors = _.map(data.color_info_list, function(obj) {
            return {
              name: obj.color_nm,
              id: obj.color_cd
            };
          });
          return more;
        })
      },
      reviews: {
        resource: 'reviewData',
        scraper: ScriptedResourceScraper(function() {
          var authorMatches, contentMatches, dateMatches, i, ratingsMatches, reviews, reviewsText, titleMatch, titleMatches, _ref;
          reviewsText = (_ref = this.resource.match(/BVRRDisplayContentBodyID([\S\s]*)/)) != null ? _ref[1] : void 0;
          if (reviewsText) {
            titleMatches = this.matchAll(reviewsText, /<span class=\\"BVRRValue BVRRReviewTitle\\">([\S\s]*?)<\\\/span>/, 1);
            contentMatches = this.matchAll(reviewsText, /<span class=\\"BVRRReviewText\\">([\S\s]*?)<\\\/span>/, 1);
            ratingsMatches = this.matchAll(reviewsText, /title=\\"(\d+) \/ 5\\"/, 1);
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

    return UniqloProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=UniqloProductScraper.map
