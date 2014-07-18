// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var FashionBugSiteInjector;
      return FashionBugSiteInjector = (function(_super) {
        __extends(FashionBugSiteInjector, _super);

        function FashionBugSiteInjector() {
          return FashionBugSiteInjector.__super__.constructor.apply(this, arguments);
        }

        FashionBugSiteInjector.prototype.productListing = {
          imgSelector: 'a img',
          productSid: function(href, a, img) {}
        };

        FashionBugSiteInjector.prototype.productPage = {
          test: function() {
            return false;
          },
          productSid: function() {
            return 0;
          },
          imgEl: function() {
            return '';
          },
          waitFor: ''
        };

        return FashionBugSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=FashionBugSiteInjector.map