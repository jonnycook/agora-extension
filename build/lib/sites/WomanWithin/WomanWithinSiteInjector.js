// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var WomanWithinSiteInjector;
      return WomanWithinSiteInjector = (function(_super) {
        __extends(WomanWithinSiteInjector, _super);

        function WomanWithinSiteInjector() {
          return WomanWithinSiteInjector.__super__.constructor.apply(this, arguments);
        }

        WomanWithinSiteInjector.prototype.parseUrl = function(url) {
          var id, style, _ref, _ref1;
          id = (_ref = url.match(/[?&]pfid=(\d+)/i)) != null ? _ref[1] : void 0;
          if (id) {
            style = (_ref1 = url.match(/[?&]styleno=(\d+)/i)) != null ? _ref1[1] : void 0;
            if (style) {
              return "" + id + "-" + style;
            } else {
              return id;
            }
          }
        };

        WomanWithinSiteInjector.prototype.productListing = {
          mode: 2,
          overlayZIndex: 1,
          image: 'a img[src^="http://media.plussizetech.com/womanwithin/"]',
          forcePositioned: true
        };

        WomanWithinSiteInjector.prototype.productPage = {
          mode: 2,
          productSid: function() {
            var id, style, _ref, _ref1;
            if ($('#Main_Image_0').length) {
              id = (_ref = document.location.href.match(/[?&]pfid=(\d+)/i)) != null ? _ref[1] : void 0;
              style = (_ref1 = $('#Main_Image_0').attr('src').match(/.*?\_(\d*).jpg?[^']*/)) != null ? _ref1[1] : void 0;
              if (style) {
                return "" + id + "-" + style;
              } else {
                return id;
              }
            }
          },
          image: '#Main_Image_0',
          overlay: '#alt_main_image_0 .zoomLink span',
          attach: 'body'
        };

        return WomanWithinSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=WomanWithinSiteInjector.map