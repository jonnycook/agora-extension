// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var SamsClubSiteInjector;
      return SamsClubSiteInjector = (function(superClass) {
        extend(SamsClubSiteInjector, superClass);

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
                var a, href, i, img, len, match, ref, ref1, results, sid;
                ref = $('a:not(.BVRRSocialBookmarkingSharingLink) img');
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  img = ref[i];
                  a = $(img).parents('a');
                  if (a.attr('href') && a.attr('href')[0] !== '#') {
                    href = a.prop('href');
                    sid = parseSid(href);
                    if (!sid) {
                      href = unescape(href);
                      match = (ref1 = /(http:\/\/www\.samsclub.com\/.*?)(?:&|$)/.exec(href)) != null ? ref1[1] : void 0;
                      if (match) {
                        sid = parseSid(match);
                      }
                    }
                    if (sid) {
                      console.log(sid, href);
                      results.push(_this.initProductEl(img, {
                        productSid: sid
                      }));
                    } else {
                      results.push(void 0);
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

//# sourceMappingURL=SamsClubSiteInjector.js.map
