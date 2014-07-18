// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct'], function(SiteProduct) {
  var TheLimitedProduct;
  return TheLimitedProduct = (function(_super) {
    __extends(TheLimitedProduct, _super);

    function TheLimitedProduct() {
      return TheLimitedProduct.__super__.constructor.apply(this, arguments);
    }

    TheLimitedProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var color, i, images, num, _i, _len, _ref;
          images = {};
          num = more.images[more.color].large.length;
          _ref = more.colors;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            color = _ref[_i];
            images[color.name] = (function() {
              var _j, _results;
              _results = [];
              for (i = _j = 0; 0 <= num ? _j < num : _j > num; i = 0 <= num ? ++_j : --_j) {
                _results.push({
                  small: more.images[color.name].small[i],
                  medium: more.images[color.name].medium[i],
                  large: more.images[color.name].large[i],
                  larger: more.images[color.name].xlarge[i],
                  full: more.images[color.name].xlarge[i]
                });
              }
              return _results;
            })();
          }
          return cb(images, more.color);
        };
      })(this));
    };

    TheLimitedProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', 'reviews', (function(_this) {
        return function(more, reviews) {
          var widgets;
          widgets = _this.genWidgets(more, {
            salesDescription: 'Description',
            sizes: 'Sizes',
            longDescription: 'Details',
            colors: {
              title: 'Colors',
              map: function(color) {
                return color.name;
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

    return TheLimitedProduct;

  })(SiteProduct);
});

//# sourceMappingURL=TheLimitedProduct.map
