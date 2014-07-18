// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var KmartSiteInjector;
      return KmartSiteInjector = (function(_super) {
        __extends(KmartSiteInjector, _super);

        function KmartSiteInjector() {
          return KmartSiteInjector.__super__.constructor.apply(this, arguments);
        }

        KmartSiteInjector.prototype.siteName = 'Kmart';

        KmartSiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var initProducts, parseSid;
              _this.shoppingBarView = new ShoppingBarView(_this.contentScript);
              _this.shoppingBarView.el.appendTo(document.body);
              _this.shoppingBarView.represent();
              parseSid = function(href) {
                var matches;
                matches = /^http:\/\/www\.kmart\.com\/[^\/]*\/p-([^?]*)/.exec(href);
                if (matches) {
                  return matches[1];
                }
              };
              window.initProducts = initProducts = function() {
                var a, href, img, match, sid, _i, _len, _ref, _ref1, _results;
                _ref = $('a img');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  img = _ref[_i];
                  a = $(img).parents('a');
                  if (a.attr('href') && a.attr('href')[0] !== '#') {
                    href = a.prop('href');
                    sid = parseSid(href);
                    if (!sid) {
                      href = unescape(href);
                      match = (_ref1 = /(http:\/\/www\.kmart.com\/.*?)(?:&|$)/.exec(href)) != null ? _ref1[1] : void 0;
                      if (match) {
                        sid = parseSid(match);
                      }
                    }
                    if (sid) {
                      _results.push(_this.initProductEl(img, {
                        productSid: sid
                      }));
                    } else {
                      _results.push(void 0);
                    }
                  } else {
                    _results.push(void 0);
                  }
                }
                return _results;
              };
              $(initProducts);
              $(window).load(initProducts);
              return setInterval(initProducts, 2000);
            };
          })(this));
        };

        return KmartSiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=KmartSiteInjector.map