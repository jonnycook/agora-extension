// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var EbaySiteInjector;
      return EbaySiteInjector = (function(_super) {
        __extends(EbaySiteInjector, _super);

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
                var a, href, img, matches, src, _i, _len, _ref, _results;
                _ref = $('a img');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  img = _ref[_i];
                  src = $(img).attr('src');
                  if (/^http:\/\/thumbs\d*.ebaystatic\.com/.exec(src) || /^http:\/\/i\.ebayimg\.com/.exec(src)) {
                    a = $(img).parents('a');
                    href = a.prop('href');
                    matches = /http:\/\/www\.ebay\.com\/itm\/[^\/]+\/(\d+)/.exec(href);
                    if (matches) {
                      _results.push(_this.initProductEl(img, {
                        productSid: matches[1]
                      }));
                    } else {
                      matches = /http:\/\/www\.ebay\.com\/itm\/ws\/eBayISAPI\.dll\?ViewItem&item=(\d+)/.exec(href);
                      if (matches) {
                        _results.push(_this.initProductEl(img, {
                          productSid: matches[1]
                        }));
                      } else {
                        _results.push(void 0);
                      }
                    }
                  } else {
                    _results.push(void 0);
                  }
                }
                return _results;
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

//# sourceMappingURL=EbaySiteInjector.map
