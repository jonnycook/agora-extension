// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var ColdwaterCreekSiteInjector;
      return ColdwaterCreekSiteInjector = (function(_super) {
        __extends(ColdwaterCreekSiteInjector, _super);

        function ColdwaterCreekSiteInjector() {
          return ColdwaterCreekSiteInjector.__super__.constructor.apply(this, arguments);
        }

        ColdwaterCreekSiteInjector.prototype.productListing = {
          mode: 2,
          imgSelector: 'a img[src^="http://cdn.coldwatercreek.com/fx/"]',
          productSid: function(href, a, img) {
            var color, matches, _ref;
            matches = /(?:http:\/\/www\.coldwatercreek\.com)?\/product-detail\/([^\/]*)\/([^\/]*)/.exec(href);
            if (matches) {
              color = (_ref = /http:\/\/cdn\.coldwatercreek\.com\/fx\/products\/[^\/]*\/[^_]*_([^_]*)_[^.]*\.jpg/i.exec(img.attr('src'))) != null ? _ref[1] : void 0;
              if (color) {
                return "" + matches[1] + "-" + matches[2] + "-" + color;
              }
            }
          }
        };

        ColdwaterCreekSiteInjector.prototype.productPage = {
          test: function() {
            return $('#pdpLargeMainImg').length;
          },
          productSid: function() {
            var color, matches;
            matches = /(?:http:\/\/www\.coldwatercreek\.com)?\/product-detail\/([^\/]*)\/([^\/]*)/.exec(document.location.href);
            color = $('#pdpLargeMainImg').attr('src').match(/http:\/\/cdn\.coldwatercreek\.com\/fx\/products\/[^\/]*\/[^_]*_([^_]*)_[^.]*\.jpg/i)[1];
            return "" + matches[1] + "-" + matches[2] + "-" + color;
          },
          imgEl: '#pdpLargeMainImg',
          overlayEl: '.mousetrap'
        };

        return ColdwaterCreekSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=ColdwaterCreekSiteInjector.map
