// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/SiteProduct', 'underscore'], function(SiteProduct, _) {
  var AsosProduct;
  return AsosProduct = (function(superClass) {
    extend(AsosProduct, superClass);

    function AsosProduct() {
      return AsosProduct.__super__.constructor.apply(this, arguments);
    }

    AsosProduct.prototype.images = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var image, images, otherImages;
          if (more.color) {
            otherImages = _.map(more.images, function(image) {
              return {
                small: image.small,
                medium: image.medium,
                large: image.large,
                larger: image.large,
                full: image.large
              };
            });
            images = _.mapValues(more.colorImages, function(image) {
              return [
                {
                  small: image.small,
                  medium: image.xlarge,
                  large: image.xlarge,
                  larger: image.xlarge,
                  full: image.xxlarge
                }
              ].concat(otherImages);
            });
            return cb(images, more.color.toLowerCase().replace(/\s+/g, ''));
          } else {
            image = more.colorImages[_.keys(more.colorImages)[0]];
            images = [
              {
                small: image.small,
                medium: image.xlarge,
                large: image.xlarge,
                larger: image.xlarge,
                full: image.xxlarge
              }
            ].concat(_.map(more.images, function(image) {
              return {
                small: image.small,
                medium: image.medium,
                large: image.large,
                larger: image.large,
                full: image.large
              };
            }));
            return cb({
              '': images
            }, '');
          }
        };
      })(this));
    };

    AsosProduct.prototype.widgets = function(cb) {
      return this.product["with"]('more', (function(_this) {
        return function(more) {
          var widgets;
          widgets = _this.genWidgets(more, {
            description: {
              title: 'Description',
              maxHeight: 'none'
            },
            aboutMe: 'About Me',
            lookAfterMe: 'Look After Me',
            sizes: 'Sizes'
          });
          return cb(widgets);
        };
      })(this));
    };

    return AsosProduct;

  })(SiteProduct);
});

//# sourceMappingURL=AsosProduct.js.map
