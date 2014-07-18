// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var NastyGirlSiteInjector;
      return NastyGirlSiteInjector = (function(_super) {
        __extends(NastyGirlSiteInjector, _super);

        function NastyGirlSiteInjector() {
          return NastyGirlSiteInjector.__super__.constructor.apply(this, arguments);
        }

        NastyGirlSiteInjector.prototype.productListing = {
          mode: 2,
          image: 'a img',
          positionA: true,
          productSid: function(href, a, img) {
            var matches, name, _ref;
            if (matches = img.attr('src').match(/(?:http:)?\/\/images\d*\.nastygal\.com\/resources\/nastygal\/images\/products\/processed\/(\d*)/)) {
              name = (_ref = a.attr('href').match(/[^\/]*$/)) != null ? _ref[0] : void 0;
              if (name) {
                return "" + matches[1] + ":" + name;
              }
            }
          }
        };

        NastyGirlSiteInjector.prototype.productPage = {
          mode: 2,
          test: function() {
            return $('meta[property="og:type"]').attr('content') === 'product';
          },
          productSid: function() {
            var name, style, _ref;
            name = (_ref = document.location.href.match(/[^\/]*$/)) != null ? _ref[0] : void 0;
            style = $('.product-style').text().match(/(\d*)$/)[1];
            return "" + style + ":" + name;
          },
          attach: '.product-images',
          position: '.product-images',
          image: '#product-images-carousel img'
        };

        return NastyGirlSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=NastyGalSiteInjector.map
