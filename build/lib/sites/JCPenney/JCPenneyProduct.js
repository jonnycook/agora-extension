// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct', 'underscore'], function(SiteProduct, _) {
  var JCPenneyProduct;
  return JCPenneyProduct = (function(_super) {
    __extends(JCPenneyProduct, _super);

    function JCPenneyProduct() {
      return JCPenneyProduct.__super__.constructor.apply(this, arguments);
    }

    JCPenneyProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var color, image, images, imgs, longId, otherImages, shortId, _i, _j, _len, _len1, _ref, _ref1, _ref2;
          otherImages = [];
          _ref = more.images.pics;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            image = _ref[_i];
            image = image.match(/^(.*?)\?/)[1];
            otherImages.push({
              small: image + '?scl=1&fmt=jpeg',
              medium: image + '?scl=1&fmt=jpeg',
              large: image + '?scl=1&fmt=jpeg',
              larger: image + '?scl=1&fmt=jpeg',
              full: image + '?scl=1&fmt=jpeg'
            });
          }
          images = {};
          _ref1 = more.images.colorPics;
          for (color in _ref1) {
            image = _ref1[color];
            imgs = [];
            image = image.match(/^(.*?)\?/)[1];
            imgs.push({
              small: image + '?scl=10&fmt=jpeg',
              medium: image + '?scl=6&fmt=jpeg',
              large: image + '?scl=3&fmt=jpeg',
              larger: image + '?scl=2&fmt=jpeg',
              full: image + '?scl=1&fmt=jpeg'
            });
            imgs = imgs.concat(otherImages);
            images[color] = imgs;
          }
          longId = _this.product.get('productSid').split('-')[1];
          shortId = null;
          if (longId) {
            _ref2 = more.colors;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              color = _ref2[_j];
              if (color.longId === longId) {
                shortId = color.shortId;
                break;
              }
            }
          }
          return cb(images, shortId);
        };
      })(this));
    };

    return JCPenneyProduct;

  })(SiteProduct);
});

//# sourceMappingURL=JCPenneyProduct.map
