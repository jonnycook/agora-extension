// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var DiapersProductScraper;
  return DiapersProductScraper = (function(_super) {
    __extends(DiapersProductScraper, _super);

    function DiapersProductScraper() {
      return DiapersProductScraper.__super__.constructor.apply(this, arguments);
    }

    DiapersProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.diapers.com/p/--" + this.productSid;
        }
      },
      reviewPage: {
        url: function() {
          var str;
          str = this.productSid + '';
          return "http://www.diapers.com/amazon_reviews/" + (str.substr(0, 2)) + "/" + (str.substr(2, 2)) + "/" + (str.substr(4)) + "/mosthelpful_Default.html";
        }
      }
    };

    DiapersProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'title')
      },
      image: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'image')
      },
      price: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'price')
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
        scraper: DeclarativeResourceScraper('scraper', 'more')
      },
      reviews: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var obj, reviews;
          reviews = this.declarativeScraper('scraper', 'reviews');
          obj = {
            reviews: reviews
          };
          this.execBlock(function() {
            this.getResource('reviewPage', function(resource) {
              obj.amazonReviews = this.declarativeScraper('amazonReviews', 'reviews', resource);
              this.value(obj);
              return this.done(true);
            });
            return null;
          });
          return this.value(obj);
        })
      }
    };

    return DiapersProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=DiapersProductScraper.map