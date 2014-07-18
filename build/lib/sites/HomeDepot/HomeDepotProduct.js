// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct', 'underscore'], function(SiteProduct, _) {
  var HomeDepotProduct;
  return HomeDepotProduct = (function(_super) {
    __extends(HomeDepotProduct, _super);

    function HomeDepotProduct() {
      return HomeDepotProduct.__super__.constructor.apply(this, arguments);
    }

    HomeDepotProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var name, otherImages, url, urlFirst, urlLast, _ref;
          otherImages = [];
          _ref = more.images;
          for (name in _ref) {
            url = _ref[name];
            urlFirst = url;
            urlLast = "";
            otherImages.push({
              small: urlFirst,
              medium: urlFirst + "300-" + urlLast,
              large: urlFirst + "500-" + urlLast,
              larger: urlFirst + "500-" + urlLast,
              full: urlFirst
            });
          }
          return cb({
            '': otherImages
          }, '');
        };
      })(this));
    };

    HomeDepotProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var widgets;
          widgets = _this.genWidgets(more, {
            features: 'Features',
            details: 'Details',
            specifications: 'Specifications'
          });
          return cb(widgets);
        };
      })(this));
    };

    return HomeDepotProduct;

  })(SiteProduct);
});

//# sourceMappingURL=HomeDepotProduct.map