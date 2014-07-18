// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct'], function(SiteProduct) {
  var EtsyProduct;
  return EtsyProduct = (function(_super) {
    __extends(EtsyProduct, _super);

    function EtsyProduct(product) {
      this.product = product;
    }

    EtsyProduct.prototype.previewLayout = 'generic';

    EtsyProduct.prototype.images = function(cb) {
      return this.product.field('more')["with"]((function(_this) {
        return function(more) {
          var image, images, _i, _len, _ref;
          images = {};
          images[''] = [];
          _ref = more.images;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            image = _ref[_i];
            images[''].push({
              small: image.largeUrl,
              medium: image.fullUrl,
              large: image.fullUrl,
              larger: image.fullUrl,
              full: image.fullUrl
            });
          }
          return cb(images, '');
        };
      })(this));
    };

    return EtsyProduct;

  })(SiteProduct);
});

//# sourceMappingURL=EtsyProduct.map
