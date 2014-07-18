// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var KateSpadeSiteInjector, parseImgSrc;
      parseImgSrc = function(src) {
        var matches;
        matches = src.match(/http:\/\/s7d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/);
        if (!matches) {
          matches = src.match(/http:\/\/a248\.e\.akamai\.net\/f\/248\/9086\/10h\/origin-d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/);
          if (!matches) {
            return null;
          }
        }
        return "" + matches[1] + "_" + matches[2];
      };
      return KateSpadeSiteInjector = (function(_super) {
        __extends(KateSpadeSiteInjector, _super);

        function KateSpadeSiteInjector() {
          return KateSpadeSiteInjector.__super__.constructor.apply(this, arguments);
        }

        KateSpadeSiteInjector.prototype.productListing = {
          container: '.product-image',
          overlayZIndex: 1,
          imgSelector: 'a:not(.swatchanchor) img[src^="http://s7d4.scene7.com/is/image/KateSpade/"], a:not(.swatchanchor) img[src^="http://a248.e.akamai.net/f/248/9086/10h/origin-d4.scene7.com/is/image/KateSpade/"]',
          productSid: function(href, a, img) {
            var matches;
            matches = img.attr('src').match(/http:\/\/s7d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/);
            if (!matches) {
              matches = img.attr('src').match(/http:\/\/a248\.e\.akamai\.net\/f\/248\/9086\/10h\/origin-d4\.scene7\.com\/is\/image\/KateSpade\/([^_]*)_(\d*)/);
              if (!matches) {
                return null;
              }
            }
            return "" + matches[1] + "_" + matches[2];
          }
        };

        KateSpadeSiteInjector.prototype.productPage = {
          test: function() {
            return $('meta[property="og:type"]').attr('content') === 'product';
          },
          productSid: function() {
            var color, id;
            id = $('.product-primary-image img').attr('src').match(/\/KateSpade\/([^_]*)_/)[1];
            color = $("input[type=hidden][name=dwvar_" + id + "_color]").val();
            return "" + id + "_" + color;
          },
          imgEl: '.product-primary-image img',
          waitFor: '.product-primary-image img',
          overlayEl: '.s7zoomview'
        };

        return KateSpadeSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=KateSpadeSiteInjector.map
