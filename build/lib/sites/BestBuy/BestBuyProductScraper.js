// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, _) {
  var BestBuyProductScraper;
  return BestBuyProductScraper = (function(_super) {
    __extends(BestBuyProductScraper, _super);

    function BestBuyProductScraper() {
      return BestBuyProductScraper.__super__.constructor.apply(this, arguments);
    }

    BestBuyProductScraper.prototype.parseSid = function(sid) {
      var id, sku, _ref;
      _ref = sid.split('-'), sku = _ref[0], id = _ref[1];
      return {
        sku: sku,
        id: id
      };
    };

    BestBuyProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.bestbuy.com/site/asdf/" + this.productSid.sku + ".p?id=" + this.productSid.id + "&skuId=" + this.productSid.sku;
        }
      },
      specificationsTab: {
        url: function() {
          var skuId;
          skuId = this.productSid.split('-')[1];
          return "http://www.bestbuy.com/site/asdf/" + this.productSid.sku + ".p;template=_specificationsTab";
        }
      }
    };

    BestBuyProductScraper.prototype.properties = {
      pageType: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var type;
          return type = this.resource.match(/<div class="[^"]*bbtabs[^"]*">([\S\s]*?)<\/div>/);
        })
      },
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(/<div id="sku-title" itemprop="name">\s*<h1>([^<]*)<\/h1>/, 1)
      },
      price: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var _ref, _ref1;
          return this.value((_ref = (_ref1 = this.resource.match(/<div class="item-price"><span class="denominator">[\S\s]*?<\/span>([^<]*)<\/div>/)) != null ? _ref1[1] : void 0) != null ? _ref : false);
        })
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(/<meta property="og:image" content="([^"]*)/, 1)
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var altText, check, desc, featureMatches, features, height, imageMatches, images, include, includeMatches, included, match, matches, specifications, switches, title, url, value, width, _i, _j, _k, _len, _len1, _len2;
          switches = {
            description: true,
            specifications: true,
            images: true,
            rating: true,
            ratingCount: true,
            originalPrice: true,
            features: true,
            model: true,
            shipping: true,
            included: true
          };
          value = {};
          if (switches.description) {
            matches = this.resource.match(/<div id="long-description" itemprop="description">([\S\s]*?)<\/div>/);
            if (matches) {
              value.description = matches[1];
            }
          }
          if (switches.included) {
            included = [];
            matches = this.resource.match(/<div id="included-items">([\S\s]*?)<\/div>/);
            if (matches) {
              includeMatches = matches[1].match(/<li>([\S\s]*?)<\/li>/g);
              for (_i = 0, _len = includeMatches.length; _i < _len; _i++) {
                match = includeMatches[_i];
                include = match.match(/<li>([\S\s]*?)<\/li>/);
                included.push(include[1]);
              }
              value.included = included;
            }
          }
          if (switches.shipping) {
            if (matches = this.resource.match(/<span class="free-shipping-sub-message">([\S\s]*?)<\/span>/)) {
              if (matches[1] === "on orders $25 and up") {
                value.shipping = "25andup";
              } else {
                value.shipping = "other";
              }
            } else {
              value.shipping = "free";
            }
          }
          if (switches.model) {
            matches = this.resource.match(/<span id="model-value" itemprop="model">([\S\s]*?)<\/span>/);
            if (matches) {
              value.model = matches[1];
            }
          }
          if (switches.features) {
            features = {};
            matches = this.resource.match(/<div id="features">([\S\s]*?)<div id="carousel-wrap"/);
            if (matches) {
              featureMatches = matches[1].match(/<div class="feature">([\S\s]*?)<\/div>/g);
              for (_j = 0, _len1 = featureMatches.length; _j < _len1; _j++) {
                match = featureMatches[_j];
                if (match.match(/<h4>([\S\s]*?)<\/h4>/)) {
                  title = match.match(/<h4>([\S\s]*?)<\/h4>/)[1];
                  desc = match.match(/<p>([\S\s]*?)<\/p>/)[1];
                  features[title] = desc;
                }
              }
              value.features = features;
            }
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/<div class="regular-price">Regular Price[\S\s]*?\$([\S\s]*?)<\/div>/);
            if (matches) {
              value.originalPrice = matches[1];
            }
          }
          if (switches.rating) {
            matches = this.resource.match(/<span class="average-score" itemprop="ratingValue">([\S\s]*?)<\/span>/);
            if (matches) {
              value.rating = matches[1];
            }
          }
          if (switches.reviewCount) {
            matches = this.resource.match(/<a href="#" class="tab-link" data-tab-link="reviews">\(([\S\s]*?) customer review/);
            if (matches) {
              value.reviewCount = matches[1];
            }
          }
          if (switches.images) {
            images = {};
            matches = this.resource.match(/data-gallery-images=[\s]*"([^"]*)/);
            if (matches) {
              imageMatches = matches[1].match(/\{([^\}]*)\}/g);
              if (imageMatches) {
                for (_k = 0, _len2 = imageMatches.length; _k < _len2; _k++) {
                  match = imageMatches[_k];
                  check = match.match(/&quot;altText&quot;:&quot;([\S\s]*?)&quot;,/);
                  if (check) {
                    altText = match.match(/&quot;altText&quot;:&quot;([\S\s]*?)&quot;,/)[1];
                    height = match.match(/&quot;height&quot;:([\S\s]*?),/);
                    width = match.match(/&quot;width&quot;:([\S\s]*?),/);
                    url = match.match(/&quot;path&quot;:&quot;([\S\s]*?)&quot;,/);
                    url = "http://pisces.bbystatic.com/image2/" + url[1] + ";canvasHeight=" + height[1] + ";canvasWidth=" + width[1];
                    images[altText] = url;
                  }
                }
                if (!check) {
                  images["main"] = this.resource.match(/<meta property="og:image" content="([^"]*)/)[1];
                }
                value.images = images;
              }
            }
          }
          if (switches.specifications) {
            specifications = {};
            this.execBlock(function() {
              this.getResource('specificationsTab', function(resource) {
                var details, name, specMatches, _l, _len3;
                matches = resource.match(/<tbody>([\S\s]*?)<\/tbody>/);
                specMatches = matches[1].match(/<tr>([\S\s]*?)<\/tr>/g);
                for (_l = 0, _len3 = specMatches.length; _l < _len3; _l++) {
                  match = specMatches[_l];
                  name = match.match(/<th[^>]*>([\S\s]*?)<\/th>/)[1];
                  details = match.match(/<td>([\S\s]*?)<\/td>/)[1];
                  desc = match.match(/<td>([\S\s]*?)<\/td>/g)[1];
                  desc = desc.match(/<td>([\S\s]*?)<\/td>/)[1];
                  specifications[name] = {
                    details: details,
                    desc: desc
                  };
                }
                value.specifications = specifications;
                this.value(value);
                return this.done(true);
              });
              return null;
            });
          }
          return this.value(value);
        })
      }
    };

    return BestBuyProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=BestBuyProductScraper.map
