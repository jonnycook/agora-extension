// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var Singer22SiteInjector;
      return Singer22SiteInjector = (function(_super) {
        __extends(Singer22SiteInjector, _super);

        function Singer22SiteInjector() {
          return Singer22SiteInjector.__super__.constructor.apply(this, arguments);
        }

        Singer22SiteInjector.prototype.productListing = function() {
          var initProducts, parseUrl;
          parseUrl = function(url) {
            var id, _ref, _ref1, _ref2;
            id = null;
            if (!id) {
              id = (_ref = url.match(/http:\/\/cdn2\.singer22\.com\/static\/insets\/[^\/]*\/([^_]*)/)) != null ? _ref[1] : void 0;
            }
            if (!id) {
              id = (_ref1 = url.match(/^http:\/\/\d*\.images\.singer22\.com\/static\/(?:products|insets)\/[^\/]*\/([^.]*)/)) != null ? _ref1[1] : void 0;
            }
            if (!id) {
              id = (_ref2 = url.match(/^http:\/\/cdn2\.singer22\.com\/static\/(?:products|insets)\/[^\/]*\/([^.]*)/)) != null ? _ref2[1] : void 0;
            }
            if (id) {
              return id.toLowerCase();
            }
          };
          initProducts = (function(_this) {
            return function() {
              var el, id, _i, _j, _len, _len1, _ref, _ref1, _results;
              _ref = $('[itemprop="itemListElement"]:not([agora])');
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                el = _ref[_i];
                el = $(el);
                id = parseUrl(el.find('img').attr('src'));
                _this.attachOverlay({
                  positionEl: $(el),
                  attachEl: $(el),
                  productData: {
                    productSid: id
                  },
                  overlayZIndex: 9999,
                  position: 'topLeft'
                });
              }
              _ref1 = $('a:not([agora]) img:not([agora])');
              _results = [];
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                el = _ref1[_j];
                el = $(el);
                id = parseUrl(el.attr('src'));
                if (id) {
                  _results.push(_this.initProductEl(el, {
                    productSid: id
                  }));
                } else {
                  _results.push(Q(el).attr('agora', true));
                }
              }
              return _results;
            };
          })(this);
          Q.setInterval(initProducts, 2000);
          if ($('#category-rotator-category-container')) {
            return Q.setInterval(((function(_this) {
              return function() {
                var el, id, _i, _len, _ref, _results;
                _ref = $('#category-rotator-category-container img');
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  el = _ref[_i];
                  el = $(el);
                  id = parseUrl(el.attr('src'));
                  if (id) {
                    if (el.data('agora-productSid') !== id) {
                      el.parent().css('position', 'relative');
                      el.parent().removeAttr('agora');
                      _this.removeOverlay(el.parent());
                      _this.attachOverlay({
                        attachEl: el.parent(),
                        positionEl: el,
                        productData: {
                          productSid: id
                        }
                      });
                      _this.clearProductEl(el);
                      _this.initProductEl(el, {
                        productSid: id
                      }, {
                        overlay: false
                      });
                      _results.push(Q(el).data('agora-productSid', id));
                    } else {
                      _results.push(void 0);
                    }
                  } else {
                    _results.push(void 0);
                  }
                }
                return _results;
              };
            })(this)), 500);
          }
        };

        Singer22SiteInjector.prototype.productPage = {
          test: function() {
            return false;
          },
          productSid: function() {
            return 0;
          },
          imgEl: '',
          waitFor: ''
        };

        return Singer22SiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=Singer22SiteInjector.map