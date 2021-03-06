// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/SiteProduct'], function(SiteProduct) {
  var EtsyProduct;
  return EtsyProduct = (function(superClass) {
    extend(EtsyProduct, superClass);

    function EtsyProduct(product) {
      this.product = product;
    }

    EtsyProduct.prototype.previewLayout = 'generic';

    EtsyProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var i, image, images, len, ref;
          images = {};
          images[''] = [];
          ref = more.images;
          for (i = 0, len = ref.length; i < len; i++) {
            image = ref[i];
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

    EtsyProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var widgets;
          console.debug(more);
          widgets = _this.genWidgets(more, {
            options: 'Options',
            description: 'Description',
            materials: 'Materials',
            tags: 'Tags'
          });
          return cb(widgets);
        };
      })(this));
    };

    return EtsyProduct;

  })(SiteProduct);
});

//# sourceMappingURL=EtsyProduct.js.map
