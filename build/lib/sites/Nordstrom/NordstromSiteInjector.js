// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var NordstromSiteInjector, parseUrl;
      parseUrl = function(url) {
        var _ref;
        return (_ref = url.match(/^http:\/\/shop\.nordstrom\.com\/s\/(?:[^\/]*\/)?(\d*)/i)) != null ? _ref[1] : void 0;
      };
      return NordstromSiteInjector = (function(_super) {
        __extends(NordstromSiteInjector, _super);

        function NordstromSiteInjector() {
          return NordstromSiteInjector.__super__.constructor.apply(this, arguments);
        }

        NordstromSiteInjector.prototype.productListing = {
          mode: 2,
          image: 'a img[src^="http://g.nordstromimage.com/imagegallery/store/product/"]',
          productSid: function(href, a, img) {
            var match, sid, _ref;
            sid = parseUrl(href);
            if (!sid) {
              href = unescape(href);
              match = (_ref = /(http:\/\/shop\.nordstrom\.com\/.*?)(?:&|$)/.exec(href)) != null ? _ref[1] : void 0;
              if (match) {
                sid = parseUrl(match);
              }
            }
            return sid;
          }
        };

        NordstromSiteInjector.prototype.productPage = {
          test: function() {
            return document.location.href.match(/^http:\/\/shop\.nordstrom\.com\/s\/(?:[^\/]*\/)?(\d*)/i);
          },
          productSid: function() {
            var color, id;
            id = document.location.href.match(/^http:\/\/shop\.nordstrom\.com\/s\/(?:[^\/]*\/)?(\d*)/i)[1];
            if ($('.selector.color.narrow select').prop('selectedIndex')) {
              color = $('.selector.color.narrow select option:selected').text().trim();
              return "" + id + "-" + color;
            } else {
              return id;
            }
          },
          imgEl: '#advancedImageViewer .fashion-photo-wrapper img',
          overlayEl: '#advancedImageViewer .dragImage'
        };

        return NordstromSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=NordstromSiteInjector.map