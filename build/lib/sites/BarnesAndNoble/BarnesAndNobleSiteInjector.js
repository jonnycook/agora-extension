// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var BarnesAndNobleSiteInjector;
      return BarnesAndNobleSiteInjector = (function(superClass) {
        extend(BarnesAndNobleSiteInjector, superClass);

        function BarnesAndNobleSiteInjector() {
          return BarnesAndNobleSiteInjector.__super__.constructor.apply(this, arguments);
        }

        BarnesAndNobleSiteInjector.prototype.productListing = {
          imgSelector: 'a[href^="http://www.barnesandnoble.com/w/"] img, a[href^="http://www.barnesandnoble.com/p/"] img, a[href^="http://www.barnesandnoble.com/v/"] img',
          productSid: function(href, a, img) {
            var name, ref;
            name = (ref = href.match(/^http:\/\/www\.barnesandnoble\.com\/.\/.*?\/([^?]+)/)) != null ? ref[1] : void 0;
            return name;
          }
        };

        BarnesAndNobleSiteInjector.prototype.productPage = {
          test: function() {
            return $('meta[property="og:type"]').attr('content') === 'product';
          },
          productSid: function() {
            return document.location.href.match(/^http:\/\/www\.barnesandnoble\.com\/.\/.*?\/([^?]+)/)[1];
          },
          imgEl: '#product-image-smaller-1 div img',
          waitFor: '#product-image-smaller-1 div img'
        };

        return BarnesAndNobleSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=BarnesAndNobleSiteInjector.js.map
