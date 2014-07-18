// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, DeclarativeResourceScraper, _) {
  var HMProductScraper;
  return HMProductScraper = (function(_super) {
    __extends(HMProductScraper, _super);

    function HMProductScraper() {
      return HMProductScraper.__super__.constructor.apply(this, arguments);
    }

    HMProductScraper.prototype.parseSid = function(sid) {
      var color, id, size, _ref;
      _ref = sid.split('-'), id = _ref[0], color = _ref[1], size = _ref[2];
      return {
        id: id,
        color: color,
        size: size
      };
    };

    HMProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.hm.com/us/product/" + this.productSid.id + "?article=" + this.productSid.id + "-" + this.productSid.color + "&variant=" + this.productSid.size;
        }
      }
    };

    HMProductScraper.prototype.properties = {
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
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var article, id, images, img, match, more, obj, _ref;
          more = this.declarativeScraper('scraper', 'more');
          match = /hm.data.product = (\{[\S\s]*?\})\s*<\/script>/.exec(this.resource)[1];
          obj = JSON.parse(match);
          images = {};
          _ref = obj.articles;
          for (id in _ref) {
            article = _ref[id];
            images[article.description] = (function() {
              var _i, _len, _ref1, _results;
              _ref1 = article.images;
              _results = [];
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                img = _ref1[_i];
                _results.push("http://lp.hm.com/hmprod?set=key[source],value[" + img.url + "]&set=key[rotate],value[0]&set=key[width],value[3692]&set=key[height],value[4317]&set=key[x],value[336]&set=key[y],value[263]&set=key[type],value[FASHION_FRONT]&hmver=0&call=url[file:/product/large]");
              }
              return _results;
            })();
          }
          more.images = images;
          return this.value(more);
        })
      }
    };

    return HMProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=HMProductScraper.map