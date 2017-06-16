// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var Singer22ProductScraper;
  return Singer22ProductScraper = (function(superClass) {
    extend(Singer22ProductScraper, superClass);

    function Singer22ProductScraper() {
      return Singer22ProductScraper.__super__.constructor.apply(this, arguments);
    }

    Singer22ProductScraper.prototype.parseSid = function(sid) {
      return {};
    };

    Singer22ProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.singer22.com/" + this.productSid + ".html";
        }
      }
    };

    Singer22ProductScraper.prototype.properties = {
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
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var match, more, obj;
          more = this.declarativeScraper('scraper', 'more');
          match = /var arrProductImages = (\{[\S\s]*?\}\})/.exec(this.resource)[1];
          obj = JSON.parse(match);
          more.colorImages = obj;
          return this.value(more);
        })
      }
    };

    return Singer22ProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=Singer22ProductScraper.js.map
