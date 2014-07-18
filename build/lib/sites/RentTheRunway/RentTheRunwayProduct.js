// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct', 'util'], function(SiteProduct, util) {
  var RentTheRunwayProduct;
  return RentTheRunwayProduct = (function(_super) {
    __extends(RentTheRunwayProduct, _super);

    function RentTheRunwayProduct() {
      return RentTheRunwayProduct.__super__.constructor.apply(this, arguments);
    }

    RentTheRunwayProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var file, image, images;
          if (more != null ? more.images : void 0) {
            images = (function() {
              var _i, _len, _ref, _results;
              _ref = more.images;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                image = _ref[_i];
                file = /\/([^\/]*)$/.exec(image)[1];
                _results.push({
                  small: 'https://cdn.rtrcdn.com/sites/default/files/imagecache/acsr_small_image/product_images/' + file,
                  medium: 'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file,
                  large: 'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file,
                  larger: 'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file,
                  full: 'https://cdn.rtrcdn.com/sites/default/files/product_images/' + file
                });
              }
              return _results;
            })();
            return cb({
              '': images
            }, '');
          } else {
            return cb();
          }
        };
      })(this));
    };

    RentTheRunwayProduct.prototype.reviews = function(cb) {
      return this.product["with"]('reviews', (function(_this) {
        return function(reveiws) {
          return cb({
            reviews: util.mapObjects(reviews, {
              rating: function(review) {
                return review.rating / 10 * 5;
              }
            })
          });
        };
      })(this));
    };

    RentTheRunwayProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', 'reviews', (function(_this) {
        return function(more, reviews) {
          var widgets;
          widgets = _this.genWidgets(more, {
            details: 'Details',
            sizeInfo: 'Size Info',
            sizes: 'Sizes',
            styleNotes: 'Style Notes',
            reviews: {
              obj: reviews,
              map: {
                rating: function(review) {
                  return review.rating / 10 * 5;
                }
              }
            }
          });
          return cb(widgets);
        };
      })(this));
    };

    return RentTheRunwayProduct;

  })(SiteProduct);
});

//# sourceMappingURL=RentTheRunwayProduct.map
