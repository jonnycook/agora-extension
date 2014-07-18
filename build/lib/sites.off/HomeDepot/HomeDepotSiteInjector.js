// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView'],
    c: function() {
      var HomeDepotSiteInjector;
      return HomeDepotSiteInjector = (function(_super) {
        __extends(HomeDepotSiteInjector, _super);

        function HomeDepotSiteInjector() {
          return HomeDepotSiteInjector.__super__.constructor.apply(this, arguments);
        }

        HomeDepotSiteInjector.prototype.siteName = 'HomeDepot';

        HomeDepotSiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var initProducts;
              _this.shoppingBarView = new ShoppingBarView(_this.contentScript);
              _this.shoppingBarView.el.appendTo(document.body);
              _this.shoppingBarView.represent();
              window.initProducts = initProducts = function() {
                var a, href, img, matches, _i, _len, _ref, _results;
                _ref = $('a img');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  img = _ref[_i];
                  a = $(img).parents('a');
                  if (a.attr('href') && a.attr('href')[0] !== '#') {
                    href = a.prop('href');
                    matches = /^http:\/\/www\.homedepot\.com\/p\/[^\/]*\/(\d+)/.exec(href);
                    if (matches) {
                      _results.push(_this.initProductEl(img, {
                        productSid: matches[1]
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
                var currentSid, hoverSelector;
                if ($('meta[property="og:type"]').attr('content') === 'product') {
                  currentSid = function() {
                    return /^http:\/\/www\.homedepot\.com\/p\/[^\/]*\/(\d+)/.exec($('meta[property="og:url"]').attr('content'))[1];
                  };
                  hoverSelector = '.zoomIt_area';
                  $('body').delegate(hoverSelector, 'mouseover', function() {
                    var down, event;
                    $(hoverSelector).unbind('.agora');
                    down = false;
                    event = null;
                    return $(hoverSelector).bind('mousedown.agora', function(e) {
                      down = true;
                      $('html').disableSelection();
                      e.preventDefault();
                      event = e;
                      return true;
                    }).bind('mouseup.agora', function() {
                      down = false;
                      return true;
                    }).bind('mousemove.agora', function(e) {
                      var selector;
                      if (down) {
                        down = false;
                        selector = '#superPIP__productImage';
                        return setTimeout((function() {
                          $(hoverSelector).hide();
                          $(selector).trigger(event);
                          return $('html').one('mouseup', function() {
                            $('html').enableSelection();
                            return $(hoverSelector).show();
                          });
                        }), 100);
                      }
                    });
                  });
                  return _this.waitFor('#superPIP__productImage', function(el) {
                    return _this.initProductEl(el, {
                      productSid: currentSid()
                    }, {
                      initOverlay: function(overlay) {
                        return overlay.el.css('zIndex', 10000);
                      }
                    });
                  });
                }
              });
            };
          })(this));
        };

        return HomeDepotSiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=HomeDepotSiteInjector.map
