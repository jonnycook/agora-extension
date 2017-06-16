// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var EtsySiteInjector;
      return EtsySiteInjector = (function(superClass) {
        extend(EtsySiteInjector, superClass);

        function EtsySiteInjector() {
          return EtsySiteInjector.__super__.constructor.apply(this, arguments);
        }

        EtsySiteInjector.prototype.productListing = {
          imgSelector: 'a[href^="/listing/"] img, a[href^="http://www.etsy.com/listing/"] img, a[href^="https://www.etsy.com/listing/"] img, a[href^="//www.etsy.com/listing/"] img',
          overlayPosition: 'topLeft',
          productSid: function(href, a, img) {
            var name, ref;
            name = (ref = href.match(/etsy\.com\/listing\/([^\/]+)/)) != null ? ref[1] : void 0;
            return name;
          }
        };

        EtsySiteInjector.prototype.productPage = {
          mode: 2,
          test: function() {
            return $('meta[name="twitter:card"]').attr('value') === 'product';
          },
          productSid: function() {
            return document.location.href.match(/etsy\.com\/listing\/([^\/]+)/)[1];
          },
          image: '#image-0 img',
          attach: '#image-main'
        };

        return EtsySiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=EtsySiteInjector.js.map
