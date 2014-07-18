// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var ModClothSiteInjector;
      return ModClothSiteInjector = (function(_super) {
        __extends(ModClothSiteInjector, _super);

        function ModClothSiteInjector() {
          return ModClothSiteInjector.__super__.constructor.apply(this, arguments);
        }

        ModClothSiteInjector.prototype.productListing = {
          image: 'li[data-id] a img, a img[src^="http://productshots"]',
          productSid: function(href, a, img) {
            var id, name, _ref, _ref1;
            if (a.parents('li[data-id]').length) {
              return "" + (a.parents('li[data-id]').attr('data-id')) + ":" + (href.match(/[^\/]*$/)[0]);
            } else {
              if (a.attr('data-analytics-ga')) {
                id = (_ref = a.attr('data-analytics-ga').match(/\[%22.*?%22,%22.*?%22,%22\d*:(\d*)/)) != null ? _ref[1] : void 0;
                if (id) {
                  name = (_ref1 = href.match(/\/-?([^\/]*)$/)) != null ? _ref1[1] : void 0;
                  if (name) {
                    return "" + id + ":" + (name.toLowerCase());
                  }
                }
              }
            }
          }
        };

        ModClothSiteInjector.prototype.productPage = {
          initPage: function() {
            return $('#image-container').after($('<div id="agora" />').css({
              zIndex: 4,
              position: 'absolute',
              top: 0,
              left: 0
            }));
          },
          mode: 2,
          test: function() {
            return $('meta[property="og:type"]').attr('content') === 'product';
          },
          productSid: function() {
            return "" + ($('.wishlist_btn_container').attr('data-product-id')) + ":" + (document.location.href.match(/([^\/]*?)(?:\?|$)/)[1]);
          },
          attach: '#agora',
          position: '#image-container',
          image: '#zoomable img'
        };

        return ModClothSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=ModClothSiteInjector.map
