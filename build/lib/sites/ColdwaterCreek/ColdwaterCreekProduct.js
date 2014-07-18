// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/SiteProduct'], function(SiteProduct) {
  var ColdwaterCreekProduct;
  return ColdwaterCreekProduct = (function(_super) {
    __extends(ColdwaterCreekProduct, _super);

    function ColdwaterCreekProduct() {
      return ColdwaterCreekProduct.__super__.constructor.apply(this, arguments);
    }

    ColdwaterCreekProduct.prototype.images = function(cb) {
      var imageSizes;
      imageSizes = function(image) {
        var fullImage, mediumImage;
        mediumImage = image.replace('36x45', '422x528');
        fullImage = image.replace('36x45', '960x1200');
        return {
          small: mediumImage,
          medium: fullImage,
          large: fullImage,
          larger: fullImage,
          full: fullImage
        };
      };
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var color, colorImages, firstImage, image, images, _ref;
          images = {};
          _ref = more.images;
          for (color in _ref) {
            colorImages = _ref[color];
            firstImage = colorImages[0].replace(/(\/[A-Z0-9]*_[A-Z0-9]*)_([A-Z0-9]*)/, '$1_S');
            images[color] = [imageSizes(firstImage)].concat((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = colorImages.length; _i < _len; _i++) {
                image = colorImages[_i];
                _results.push(imageSizes(image));
              }
              return _results;
            })());
          }
          return cb(images, more.color);
        };
      })(this));
    };

    ColdwaterCreekProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', 'reviews', (function(_this) {
        return function(more, reviews) {
          var widgets;
          widgets = _this.genWidgets(more, {
            description: 'Description',
            sizes: 'Sizes',
            materials: 'Materials',
            colors: {
              title: 'Colors',
              map: function(color) {
                return color.name;
              }
            },
            reviews: {
              obj: reviews
            }
          });
          return cb(widgets);
        };
      })(this));
    };

    return ColdwaterCreekProduct;

  })(SiteProduct);
});

//# sourceMappingURL=ColdwaterCreekProduct.map