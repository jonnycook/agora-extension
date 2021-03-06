// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var ExpressSiteInjector, parseUrl;
      parseUrl = function(url) {
        var ref, ref1, ref2;
        return (ref = (ref1 = url.match(/[?&]productId=(\d*)/)) != null ? ref1[1] : void 0) != null ? ref : (ref2 = url.match(/\/pro\/(\d*)/)) != null ? ref2[1] : void 0;
      };
      return ExpressSiteInjector = (function(superClass) {
        extend(ExpressSiteInjector, superClass);

        function ExpressSiteInjector() {
          return ExpressSiteInjector.__super__.constructor.apply(this, arguments);
        }

        ExpressSiteInjector.prototype.productListing = {
          image: 'a img[src*="images.express.com/is/image/expressfashion/"]:not([src*=swatch])',
          productSid: function(href, a, img) {
            return parseUrl(href);
          }
        };

        ExpressSiteInjector.prototype.productPage = {
          mode: 2,
          productSid: function() {
            return parseUrl(document.location.href);
          },
          image: '#flyout img[src^="http://images.express.com/is/image/expressfashion"]',
          attach: '#glo-body-content',
          position: '#flyout',
          overlay: '#flyout',
          hideOverlay: false,
          zIndex: 999,
          variant: function() {
            if ($('.selectedColor').text()) {
              return {
                Color: $('.selectedColor').text()
              };
            }
          }
        };

        return ExpressSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=ExpressSiteInjector.js.map
