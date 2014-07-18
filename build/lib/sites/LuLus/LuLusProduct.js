// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct', 'util'], function(SiteProduct, util) {
  var LuLuProduct;
  return LuLuProduct = (function(_super) {
    __extends(LuLuProduct, _super);

    function LuLuProduct() {
      return LuLuProduct.__super__.constructor.apply(this, arguments);
    }

    LuLuProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var image, images, _i, _len, _ref;
          images = [];
          _ref = more.images;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            image = _ref[_i];
            images.push({
              small: image,
              medium: image,
              large: image,
              larger: image,
              full: image.replace('small', 'xlarge')
            });
          }
          return cb({
            '': images
          }, '');
        };
      })(this));
    };

    LuLuProduct.prototype.reviews = function(cb) {
      return this.product["with"]('reviews', (function(_this) {
        return function(reviews) {
          return cb({
            reviews: util.mapObjects(reviews, {
              rating: function(review) {
                return review.rating / 100 * 5;
              }
            })
          });
        };
      })(this));
    };

    LuLuProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', 'reviews', (function(_this) {
        return function(more, reviews) {
          var widgets;
          widgets = _this.genWidgets(more, {
            description: 'Description',
            sizes: 'Sizes',
            reviews: {
              obj: reviews,
              map: {
                review: 'content',
                rating: function(rating) {
                  return rating / 100 * 5;
                }
              }
            }
          });
          return cb(widgets);
        };
      })(this));
    };

    return LuLuProduct;

  })(SiteProduct);
});

//# sourceMappingURL=LuLusProduct.map