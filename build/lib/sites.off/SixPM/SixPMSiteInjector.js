// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var SixPMSiteInjector;
      return SixPMSiteInjector = (function(_super) {
        __extends(SixPMSiteInjector, _super);

        function SixPMSiteInjector() {
          return SixPMSiteInjector.__super__.constructor.apply(this, arguments);
        }

        SixPMSiteInjector.prototype.productListing = function() {
          var initProduct, initProducts, selector, that;
          initProduct = (function(_this) {
            return function(el, retrievalId, url, mousedover) {
              return _this.initProductEl(el, {
                productUrl: url,
                retrievalId: retrievalId
              }, {
                hovering: mousedover
              });
            };
          })(this);
          selector = 'a[rel=product] img, a.product img, .productReviews a img';
          that = this;
          window.initProducts = initProducts = function() {
            return $(selector).each(function() {
              var a, m, matches;
              matches = /http:\/\/(:?[^.]*.zassets.com|www\.6pm\.com)\/images\/[a-z]*\/\d\/.*?\/(\d*)-[a-z]-\w*\.jpg/.exec($(this).attr('src'));
              if (matches) {
                a = $(this).parents('a');
                m = /http:\/\/www\.6pm\.com\/product\/(\d*)\/color\/(\d*)/.exec(a.prop('href'));
                if (m) {
                  return that.initProductEl(this, {
                    productSid: "" + m[1] + "-" + m[2]
                  });
                } else {
                  return initProduct(this, matches[1], a.prop('href'), false);
                }
              }
            });
          };
          initProducts();
          return Q.setInterval(initProducts, 2000);
        };

        SixPMSiteInjector.prototype.productPage = {
          productSid: function() {
            var color, sku;
            color = $('#color').val();
            sku = $('#sku').text().match(/^SKU: #(\d*)$/)[1];
            return "" + sku + "-" + color;
          },
          imgEl: '#detailImage img'
        };

        return SixPMSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=SixPMSiteInjector.map
