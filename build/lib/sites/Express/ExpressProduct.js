// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/SiteProduct', 'util', 'underscore'], function(SiteProduct, util, _) {
  var ExpressProduct;
  return ExpressProduct = (function(superClass) {
    extend(ExpressProduct, superClass);

    function ExpressProduct() {
      return ExpressProduct.__super__.constructor.apply(this, arguments);
    }

    ExpressProduct.prototype.variantImage = function(variant, cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var ref;
          if (more) {
            return cb((ref = more.images) != null ? ref[variant.Color][0] : void 0);
          } else {
            return cb();
          }
        };
      })(this));
    };

    ExpressProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var color, colorImages, image, images, ref;
          images = {};
          ref = more.images;
          for (color in ref) {
            colorImages = ref[color];
            images[color] = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = colorImages.length; i < len; i++) {
                image = colorImages[i];
                results.push({
                  small: image,
                  medium: image,
                  large: image,
                  larger: image,
                  full: image
                });
              }
              return results;
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

//# sourceMappingURL=ExpressProduct.js.map
