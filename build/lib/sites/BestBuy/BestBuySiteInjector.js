// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var BestBuySiteInjector;
      return BestBuySiteInjector = (function(superClass) {
        extend(BestBuySiteInjector, superClass);

        function BestBuySiteInjector() {
          return BestBuySiteInjector.__super__.constructor.apply(this, arguments);
        }

        BestBuySiteInjector.prototype.productListing = {
          imgSelector: 'a img[src^="http://images.bestbuy.com/BestBuy_US/images/products/"]',
          productSid: function(href, a, img) {
            var id, matches;
            matches = href.match(/^http:\/\/www\.bestbuy\.com\/site\/.*?\/([^\.]+)\.p\?id=([^\&]+)/);
            return id = matches[1] + "-" + matches[2];
          }
        };

        BestBuySiteInjector.prototype.productPage = {
          test: function() {
            return $('#product-media-content').length;
          },
          productSid: function() {
            var id, matches;
            matches = document.location.href.match(/^http:\/\/www\.bestbuy\.com\/site\/.*?\/([^\.]+)\.p\?id=([^\&]+)/);
            return id = matches[1] + "-" + matches[2];
          },
          imgEl: '.image-gallery-main-slide a img',
          waitFor: '.image-gallery-main-slide a img'
        };

        return BestBuySiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=BestBuySiteInjector.js.map
