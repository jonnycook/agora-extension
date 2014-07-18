// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var KohlsProductScraper;
  return KohlsProductScraper = (function(_super) {
    __extends(KohlsProductScraper, _super);

    function KohlsProductScraper() {
      return KohlsProductScraper.__super__.constructor.apply(this, arguments);
    }

    KohlsProductScraper.testProducts = [];

    KohlsProductScraper.prototype.parseSid = function(sid) {
      var color, id, _ref;
      _ref = sid.split('-'), id = _ref[0], color = _ref[1];
      return {
        id: id,
        color: color
      };
    };

    KohlsProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          var url;
          url = "http://www.kohls.com/product/prd-" + this.productSid.id + "/.jsp";
          if (this.productSid.color) {
            url += "?skuId=" + this.productSid.color;
          }
          return url;
        }
      }
    };

    KohlsProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.kohls.com/product/prd-" + this.productSid + "/.jsp";
        }
      }
    };

    KohlsProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:title" content="([^"]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper([[new RegExp(/<div class="sale">[\s]*Sale[\s]*\$([\S\s]*?)[\s]*<\/div>/), 1], [new RegExp(/br_data.sale_price = "\$([^"]*)/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:image" content="([^"]*)/), 1)
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var content, editorialReviews, erMatches, from, image, imageMatches, images, match, matches, options, overview, overviewMatches, rating, ratingURL, switches, text, title, value, _i, _j, _k, _len, _len1, _len2;
          switches = {
            images: true,
            description: true,
            rating: true,
            ratingCount: true,
            originalPrice: true,
            options: true,
            shipping: false
          };
          value = {};
          if (switches.overview) {
            overview = [];
            matches = this.resource.match(/<div id="product-commentary-overview-1"([\S\s]*?)<\/section>/);
            overviewMatches = matches[1].match(/<p([\S\s]*?)<\/p>/g);
            for (_i = 0, _len = overviewMatches.length; _i < _len; _i++) {
              match = overviewMatches[_i];
              text = match.match(/<p([\S\s]*?)<\/p>/);
              overview.push(text[1]);
            }
            value.overview = overview;
          }
          if (switches.description) {
            matches = this.resource.match(/<div class="Bdescription">([\S\s]*?)<\/div>/);
            if (matches) {
              value.description = matches[1];
            }
          }
          if (switches.options) {
            options = [];
            matches = this.resource.match(/var allVariants={([\S\s]*?)<\/script>/);
          }
          if (switches.rating) {
            rating = [];
            ratingURL = "http://kohls.ugc.bazaarvoice.com/9025/" + this.productSid + "/reviews.djs?format=embeddedhtml";
            this.execBlock(function() {
              this.get(ratingURL, function(response) {
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
            matches = this.resource.match(/var numberOfReviews = "([^"]*)/);
            if (matches) {
              value.reviewCount = matches[1];
            }
          }
          if (switches.editorialReviews) {
            editorialReviews = {};
            matches = this.resource.safeMatch(/<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/);
            erMatches = matches[1].match(/<article class="simple-html">([\S\s]*?)<\/article>/g);
            for (_j = 0, _len1 = erMatches.length; _j < _len1; _j++) {
              match = erMatches[_j];
              from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1];
              content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^<br \/>+|<br \/>+$/gm, '');
              editorialReviews[from] = content;
            }
            value.editorialReviews = editorialReviews;
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/br_data.price = "\$([^"]*)/);
            if (matches) {
              value.originalPrice = matches[1];
            }
          }
          if (switches.images) {
            images = {};
            matches = this.resource.match(/<div id="rightCarousel"([\S\s]*?)<\/div>/);
            imageMatches = matches[1].match(/<li([\S\s]*?)<\/li>/g);
            for (_k = 0, _len2 = imageMatches.length; _k < _len2; _k++) {
              match = imageMatches[_k];
              image = match.match(/rel="([^"]+)/);
              title = match.match(/title="([^"]+)/);
              images[title[1]] = image[1];
            }
            value.images = images;
          }
          return this.value(value);
        })
      }
    };

    return KohlsProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=KohlsProductScraper.map