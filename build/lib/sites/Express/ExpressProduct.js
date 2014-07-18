// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct', 'util', 'underscore'], function(SiteProduct, util, _) {
  var ExpressProduct;
  return ExpressProduct = (function(_super) {
    __extends(ExpressProduct, _super);

    function ExpressProduct() {
      return ExpressProduct.__super__.constructor.apply(this, arguments);
    }

    ExpressProduct.prototype.variantImage = function(variant, cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var _ref;
          if (more) {
            return cb((_ref = more.images) != null ? _ref[variant.Color][0] : void 0);
          } else {
            return cb();
          }
        };
      })(this));
    };

    ExpressProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var color, colorImages, image, images, _ref;
          images = {};
          _ref = more.images;
          for (color in _ref) {
            colorImages = _ref[color];
            images[color] = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = colorImages.length; _i < _len; _i++) {
                image = colorImages[_i];
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
          return cb(images, more.color);
        };
      })(this));
    };

    ExpressProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', 'reviews', (function(_this) {
        return function(more, reviews) {
          var widgets;
          widgets = _this.genWidgets(more, {
            description: 'Description',
            sizes: 'Sizes',
            details: 'Details',
            colors: {
              title: 'Colors',
              map: function(color) {
                return util.ucfirst(color.name);
              }
            },
            reviews: {
              obj: reviews,
              map: {
                review: 'content'
              }
            }
          });
          return cb(widgets);
        };
      })(this));
    };

    return ExpressProduct;

  })(SiteProduct);
});

//# sourceMappingURL=ExpressProduct.map
