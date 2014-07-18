// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var SearsSiteInjector;
      return SearsSiteInjector = (function(_super) {
        __extends(SearsSiteInjector, _super);

        function SearsSiteInjector() {
          return SearsSiteInjector.__super__.constructor.apply(this, arguments);
        }

        SearsSiteInjector.prototype.siteName = 'Sears';

        SearsSiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var initProduct, initProducts, parseSid;
              _this.shoppingBarView = new ShoppingBarView(_this.contentScript);
              _this.shoppingBarView.el.appendTo(document.body);
              _this.shoppingBarView.represent();
              initProduct = function(el, sid) {
                return _this.initProductEl(el, {
                  productSid: sid
                });
              };
              parseSid = function(href) {
                var matches;
                matches = /^http:\/\/www\.sears\.com\/[^\/]*\/p-([^?]*)/.exec(href);
                if (matches) {
                  return matches[1];
                } else {
                  matches = /^http:\/\/www\.sears\.com\/shc\/s\/p_.*?_([^_?]*)(?:\?|$)/.exec(href);
                  if (matches) {
                    return matches[1];
                  }
                }
              };
              window.initProducts = initProducts = function() {
                var a, href, img, match, sid, _i, _len, _ref, _ref1, _results;
                _ref = $('a img');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  img = _ref[_i];
                  a = $(img).parents('a');
                  href = a.prop('href');
                  sid = parseSid(href);
                  if (!sid) {
                    href = unescape(href);
                    match = (_ref1 = /(http:\/\/www\.sears\.com\/.*?)(?:&|$)/.exec(href)) != null ? _ref1[1] : void 0;
                    if (match) {
                      sid = parseSid(match);
                    }
                  }
                  if (sid) {
                    _results.push(initProduct(img, sid));
                  } else {
                    _results.push(void 0);
                  }
                }
                return _results;
              };
              $(initProducts);
              $(window).load(initProducts);
              return _this.waitFor('div[data-id="product-image-main"] img', function(el) {
                var sid;
                sid = $('[itemprop="productID"]').html().match(/^Item # (.*)$/)[1];
                return _this.initProductEl(el, {
                  productSid: sid
                });
              });
            };
          })(this));
        };

        return SearsSiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=SearsSiteInjector.map