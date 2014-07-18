// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct'], function(SiteProduct) {
  var WetSealProduct;
  return WetSealProduct = (function(_super) {
    __extends(WetSealProduct, _super);

    function WetSealProduct() {
      return WetSealProduct.__super__.constructor.apply(this, arguments);
    }

    WetSealProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var allImages, colorId, image, images, _ref;
          allImages = {};
          _ref = more.images;
          for (colorId in _ref) {
            images = _ref[colorId];
            allImages[colorId] = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = images.length; _i < _len; _i++) {
                image = images[_i];
                _results.push({
                  small: image,
                  medium: image,
                  large: image,
                  larger: image,
                  full: image
                });
              }
              return _results;
            })();
          }
          return cb(allImages, _this.product.get('productSid').split('_')[1]);
        };
      })(this));
    };

    return WetSealProduct;

  })(SiteProduct);
});

//# sourceMappingURL=WetSealProduct.map
