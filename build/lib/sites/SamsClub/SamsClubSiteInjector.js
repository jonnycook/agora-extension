// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var SamsClubSiteInjector;
      return SamsClubSiteInjector = (function(_super) {
        __extends(SamsClubSiteInjector, _super);

        function SamsClubSiteInjector() {
          return SamsClubSiteInjector.__super__.constructor.apply(this, arguments);
        }

        SamsClubSiteInjector.prototype.siteName = 'SamsClub';

        SamsClubSiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var initProducts, parseSid;
              _this.shoppingBarView = new ShoppingBarView(_this.contentScript);
              _this.shoppingBarView.el.appendTo(document.body);
              _this.shoppingBarView.represent();
              parseSid = function(href) {
                var matches;
                matches = /^http:\/\/www\.samsclub\.com\/sams\/[^\/]*?\/prod([^\.]+)/.exec(href);
                if (matches) {
                  return matches[1];
                }
              };
              window.initProducts = initProducts = function() {
                var a, href, img, match, sid, _i, _len, _ref, _ref1, _results;
                _ref = $('a:not(.BVRRSocialBookmarkingSharingLink) img');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  img = _ref[_i];
                  a = $(img).parents('a');
                  if (a.attr('href') && a.attr('href')[0] !== '#') {
                    href = a.prop('href');
                    sid = parseSid(href);
                    if (!sid) {
                      href = unescape(href);
                      match = (_ref1 = /(http:\/\/www\.samsclub.com\/.*?)(?:&|$)/.exec(href)) != null ? _ref1[1] : void 0;
                      if (match) {
                        sid = parseSid(match);
                      }
                    }
                    if (sid) {
                      console.log(sid, href);
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
              setInterval(initProducts, 2000);
              return $(function() {
                var currentSid;
                if ($('#plImageHolder').length) {
                  currentSid = function() {
                    return /^http:\/\/www\.samsclub\.com\/sams\/.*?\/prod([^\.]+)/.exec(document.location.href)[1];
                  };
                  return _this.initProductEl($('#plImageHolder img'), {
                    productSid: currentSid()
                  });
                }
              });
            };
          })(this));
        };

        return SamsClubSiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=SamsClubSiteInjector.map
