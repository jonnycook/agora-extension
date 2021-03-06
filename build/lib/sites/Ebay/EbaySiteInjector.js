// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var EbaySiteInjector;
      return EbaySiteInjector = (function(superClass) {
        extend(EbaySiteInjector, superClass);

        function EbaySiteInjector() {
          return EbaySiteInjector.__super__.constructor.apply(this, arguments);
        }

        EbaySiteInjector.prototype.siteName = 'Ebay';

        EbaySiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var initProducts;
              _this.shoppingBarView = new ShoppingBarView(_this.contentScript);
              _this.shoppingBarView.el.appendTo(document.body);
              _this.shoppingBarView.represent();
              window.initProducts = initProducts = function() {
                var a, href, i, img, len, matches, ref, results, src;
                ref = $('a img');
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  img = ref[i];
                  src = $(img).attr('src');
                  if (/^http:\/\/thumbs\d*.ebaystatic\.com/.exec(src) || /^http:\/\/i\.ebayimg\.com/.exec(src)) {
                    a = $(img).parents('a');
                    href = a.prop('href');
                    matches = /http:\/\/www\.ebay\.com\/itm\/[^\/]+\/(\d+)/.exec(href);
                    if (matches) {
                      results.push(_this.initProductEl(img, {
                        productSid: matches[1]
                      }));
                    } else {
                      matches = /http:\/\/www\.ebay\.com\/itm\/ws\/eBayISAPI\.dll\?ViewItem&item=(\d+)/.exec(href);
                      if (matches) {
                        results.push(_this.initProductEl(img, {
                          productSid: matches[1]
                        }));
                      } else {
                        results.push(void 0);
                      }
                    }
                  } else {
                    results.push(void 0);
                  }
                }
                return results;
              };
              $(initProducts);
              $(window).load(initProducts);
              setInterval(initProducts, 2000);
              if ($('#Body').attr('itemtype') === 'http://schema.org/Product') {
                return _this.waitFor('#icImg', function(el) {
                  return _this.initProductEl(el, {
                    productSid: $('#vi-accrd-itm-det-hldr').text().match(/Item number:(\d+)/)[1]
                  });
                });
              }
            };
          })(this));
        };

        return EbaySiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=EbaySiteInjector.js.map
