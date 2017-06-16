// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'underscore', 'util'], function(View, _, util) {
  var ProductPreviewView;
  return ProductPreviewView = (function(superClass) {
    extend(ProductPreviewView, superClass);

    function ProductPreviewView() {
      return ProductPreviewView.__super__.constructor.apply(this, arguments);
    }

    ProductPreviewView.nextId = 0;

    ProductPreviewView.id = function() {
      return ++this.nextId;
    };

    ProductPreviewView.prototype.initAsync = function(args, done) {
      this.data = {};
      return this.resolveObject(args, (function(_this) {
        return function(product) {
          product.update();
          _.extend(_this.data, {
            url: product.get('url'),
            title: _this.clientValue(product.field('title'), product.displayValue('title')),
            image: _this.clientValue(product.field('image'), product.displayValue('image'))
          });
          return product["interface"](function(siteProduct) {
            var images, widgetsCv;
            if (siteProduct) {
              images = _this.clientValue();
              widgetsCv = _this.clientValue();
              siteProduct.images(function(imgs, currentStyle) {
                if (imgs) {
                  if (!currentStyle) {
                    currentStyle = _.keys(imgs)[0];
                  }
                  return images.set({
                    images: imgs,
                    currentStyle: currentStyle
                  });
                } else {
                  return images.set(null);
                }
              });
              if (siteProduct.widgets) {
                siteProduct.widgets(function(widgets) {
                  return widgetsCv.set(widgets);
                });
              } else {
                widgetsCv.set('none');
              }
              _.extend(_this.data, {
                images: images,
                widgets: widgetsCv
              });
              if (siteProduct.site.hasFeature('rating')) {
                _.extend(_this.data, {
                  rating: _this.clientValue(product.field('rating'), product.displayValue('rating')),
                  ratingCount: _this.clientValue(product.field('ratingCount'), product.displayValue('ratingCount'))
                });
              }
            }
            return done();
          });
        };
      })(this));
    };

    return ProductPreviewView;

  })(View);
});

//# sourceMappingURL=ProductPreviewView.js.map
