// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/SiteProduct'], function(SiteProduct) {
  var DiapersProduct;
  return DiapersProduct = (function(superClass) {
    extend(DiapersProduct, superClass);

    function DiapersProduct() {
      return DiapersProduct.__super__.constructor.apply(this, arguments);
    }

    DiapersProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var images;
          images = [];
          return cb({
            '': images
          }, '');
        };
      })(this));
    };

    return DiapersProduct;

  })(SiteProduct);
});

//# sourceMappingURL=DiapersProduct.js.map
