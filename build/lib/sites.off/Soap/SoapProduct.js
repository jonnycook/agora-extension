// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct'], function(SiteProduct) {
  var SoapProduct;
  return SoapProduct = (function(_super) {
    __extends(SoapProduct, _super);

    function SoapProduct() {
      return SoapProduct.__super__.constructor.apply(this, arguments);
    }

    SoapProduct.prototype.images = function(cb) {
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

    return SoapProduct;

  })(SiteProduct);
});

//# sourceMappingURL=SoapProduct.map
