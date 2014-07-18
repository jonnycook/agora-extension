// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var LulusSiteInjector;
      return LulusSiteInjector = (function(_super) {
        __extends(LulusSiteInjector, _super);

        function LulusSiteInjector() {
          return LulusSiteInjector.__super__.constructor.apply(this, arguments);
        }

        LulusSiteInjector.prototype.productListing = {
          mode: 2,
          selectors: {
            'div.category div.category-image': {
              image: function(el) {
                return el.find('.image img:first');
              },
              anchor: function(el) {
                return el.find('.mousetrap .trap-link');
              },
              anchorProxy: true,
              productData: function(href, a, img, el) {
                var matches;
                matches = href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html");
                if (matches) {
                  return {
                    productSid: matches != null ? matches[1] : void 0
                  };
                }
              }
            },
            'a img[src^="http://cdn.lulus.com/images/product/"], a img[src^="/images/product/"]': {
              productData: function(href, a, img) {
                var matches;
                matches = href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html");
                if (matches) {
                  return {
                    productSid: matches != null ? matches[1] : void 0
                  };
                }
              }
            }
          }
        };

        LulusSiteInjector.prototype.productPage = {
          mode: 2,
          test: function() {
            return document.location.href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html");
          },
          productSid: function() {
            return document.location.href.match("http://www\\.lulus\\.com/products.*?/([^./]*)\\.html")[1];
          },
          image: '#zoom1 img',
          overlay: '.mousetrap',
          attach: 'body',
          zIndex: 9999
        };

        return LulusSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=LuLusSiteInjector.map
