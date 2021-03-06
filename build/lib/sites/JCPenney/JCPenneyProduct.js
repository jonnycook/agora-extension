// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/SiteProduct', 'underscore'], function(SiteProduct, _) {
  var JCPenneyProduct;
  return JCPenneyProduct = (function(superClass) {
    extend(JCPenneyProduct, superClass);

    function JCPenneyProduct() {
      return JCPenneyProduct.__super__.constructor.apply(this, arguments);
    }

    JCPenneyProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var color, i, image, images, imgs, j, len, len1, longId, otherImages, ref, ref1, ref2, shortId;
          otherImages = [];
          ref = more.images.pics;
          for (i = 0, len = ref.length; i < len; i++) {
            image = ref[i];
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
          ref1 = more.images.colorPics;
          for (color in ref1) {
            image = ref1[color];
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
            ref2 = more.colors;
            for (j = 0, len1 = ref2.length; j < len1; j++) {
              color = ref2[j];
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

//# sourceMappingURL=JCPenneyProduct.js.map
