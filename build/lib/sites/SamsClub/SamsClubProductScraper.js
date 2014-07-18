// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var SamsClubProductScraper;
  return SamsClubProductScraper = (function(_super) {
    __extends(SamsClubProductScraper, _super);

    function SamsClubProductScraper() {
      return SamsClubProductScraper.__super__.constructor.apply(this, arguments);
    }

    SamsClubProductScraper.testProducts = ['11690047'];

    SamsClubProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.samsclub.com/sams/-/prod" + this.productSid + ".ip";
        }
      }
    };

    SamsClubProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<span itemprop="name">([^<]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper([[new RegExp(/'item_price':'([^']*)/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<div class="[^"]*" id='plImageHolder'>[\s]*<img src='([^\?]*)/), 1).config({
          map: function(value) {
            return "" + value + "?$img_size_500x500$";
          }
        })
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var content, editorialReviews, erMatches, from, imageMatches, images, jsonUrl, match, matches, rating, ratingURL, reviewCount, style, styleImages, styleNum, swatch, switches, value, _fn, _i, _j, _len, _len1;
          switches = {
            images: true,
            details: true,
            rating: true,
            ratingCount: true,
            originalPrice: false,
            shipping: false
          };
          value = {};
          if (switches.details) {
            matches = this.resource.match(/<div class="[^"]*" id="tabItemDetails">([\S\s]*?)id="tabRatings"/);
            value.details = "<div>" + matches[1] + "> </div>";
          }
          if (switches.rating) {
            rating = [];
            ratingURL = "http://samsclub.ugc.bazaarvoice.com/1337/prod" + this.productSid + "/reviews.djs?format=embeddedhtml";
            this.execBlock(function() {
              this.get(ratingURL, function(response) {
                var match;
                match = response.match(/<span class=\\"BVRRNumber BVRRRatingNumber\\">([^<]*)/);
                if (match) {
                  rating.push(match[1]);
                }
                this.done(true);
                return this.value(value);
              });
              return null;
            });
            value.rating = rating;
          }
          if (switches.reviewCount) {
            reviewCount = [];
            ratingURL = "http://samsclub.ugc.bazaarvoice.com/1337/prod" + this.productSid + "/reviews.djs?format=embeddedhtml";
            this.execBlock(function() {
              this.get(ratingURL, function(response) {
                var match;
                match = response.match(/<span class=\\"BVRRNumber\\">([^<]*)/);
                if (match) {
                  reviewCount.push(match[1]);
                }
                this.done(true);
                return this.value(value);
              });
              return null;
            });
            value.reviewCount = reviewCount;
          }
          if (switches.editorialReviews) {
            editorialReviews = {};
            matches = this.resource.safeMatch(/<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/);
            erMatches = matches[1].match(/<article class="simple-html">([\S\s]*?)<\/article>/g);
            for (_i = 0, _len = erMatches.length; _i < _len; _i++) {
              match = erMatches[_i];
              from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1];
              content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^<br \/>+|<br \/>+$/gm, '');
              editorialReviews[from] = content;
            }
            value.editorialReviews = editorialReviews;
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/"listPrice" : ([\S\s]*?),/);
            if (matches) {
              value.originalPrice = matches[1];
            }
          }
          if (switches.images) {
            images = {};
            matches = this.resource.match(/<div class="variantSwatches([\S\s]*?)<div class="clearfix"/);
            if (matches) {
              imageMatches = matches[1].match(/<a([\S\s]*?)<\/a>/g);
              _fn = (function(_this) {
                return function(jsonUrl, styleImages) {
                  return _this.execBlock(function() {
                    this.get(jsonUrl, function(response) {
                      var num, numMatch, numMatches, _k, _len2;
                      numMatches = response.match(/\/([0-9A-Z_]*?);/g);
                      for (_k = 0, _len2 = numMatches.length; _k < _len2; _k++) {
                        numMatch = numMatches[_k];
                        num = numMatch.match(/\/([0-9A-Z_]*?);/)[1];
                        styleImages.push("http://scene7.samsclub.com/is/image/samsclub/" + num + "?$img_size_380x380$");
                      }
                      this.done(true);
                      return this.value(value);
                    });
                    return null;
                  });
                };
              })(this);
              for (_j = 0, _len1 = imageMatches.length; _j < _len1; _j++) {
                match = imageMatches[_j];
                style = match.match(/data-value="([^"]+)/)[1];
                swatch = match.match(/src='([^']+)/)[1];
                styleNum = match.match(/http:\/\/scene7.samsclub.com\/is\/image\/samsclub\/([\S\s]*?)_S1/)[1];
                jsonUrl = "http://scene7.samsclub.com/is/image/samsclub/" + styleNum + "?req=imageset,json&id=init";
                styleImages = [];
                _fn(jsonUrl, styleImages);
                styleImages.push(swatch);
                images[style] = styleImages;
              }
            } else {
              styleNum = this.resource.match(/var imageList = '([\S\s]*?)';/)[1];
              jsonUrl = "http://scene7.samsclub.com/is/image/samsclub/" + styleNum + "?req=imageset,json&id=init";
              styleImages = [];
              (function(_this) {
                return (function(jsonUrl, styleImages) {
                  return _this.execBlock(function() {
                    this.get(jsonUrl, function(response) {
                      var num, numMatch, numMatches, _k, _len2;
                      numMatches = response.match(/\/([0-9A-Z_]*?);/g);
                      for (_k = 0, _len2 = numMatches.length; _k < _len2; _k++) {
                        numMatch = numMatches[_k];
                        num = numMatch.match(/\/([0-9A-Z_]*?);/)[1];
                        styleImages.push("http://scene7.samsclub.com/is/image/samsclub/" + num + "?$img_size_380x380$");
                      }
                      this.done(true);
                      return this.value(value);
                    });
                    return null;
                  });
                });
              })(this)(jsonUrl, styleImages);
              images["main"] = styleImages;
            }
            value.images = images;
          }
          return this.value(value);
        })
      }
    };

    return SamsClubProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=SamsClubProductScraper.map