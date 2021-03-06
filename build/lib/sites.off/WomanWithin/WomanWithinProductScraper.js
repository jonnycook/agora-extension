// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var WomanWithinProductScraper;
  return WomanWithinProductScraper = (function(_super) {
    __extends(WomanWithinProductScraper, _super);

    function WomanWithinProductScraper() {
      return WomanWithinProductScraper.__super__.constructor.apply(this, arguments);
    }

    WomanWithinProductScraper.prototype.parseSid = function(sid) {
      var sku, style, _ref;
      _ref = sid.split('-'), sku = _ref[0], style = _ref[1];
      return {
        sku: sku,
        style: style
      };
    };

    WomanWithinProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          var url;
          url = "http://www.womanwithin.com/clothing/-.aspx?pfId=" + this.productSid.sku + "&producttypeid=1";
          if (this.productSid.style) {
            url += "&styleno=" + this.productSid.style;
          }
          return url;
        }
      }
    };

    WomanWithinProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'title')
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
      reviews: {
        resource: 'productPage',
        scraper: DeclarativeResourceScraper('scraper', 'reviews')
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var more;
          more = this.declarativeScraper('scraper', 'more');
          return this.value(more);
        })
      },
      image: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var image, style, _ref;
          style = this.productSid.style;
          image = (_ref = this.resource.match("mainimageUrl='(.*?\_" + style + ".jpg?[^']*)' colorName")) != null ? _ref[1] : void 0;
          if (image) {
            image = image.replace(/&amp;/g, '&');
          } else {
            image = /<meta property="og:image" content="([^"]*)/.exec(this.resource)[1];
          }
          return this.value(image);
        })
      }
    };

    return WomanWithinProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=WomanWithinProductScraper.map
