// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['SiteInjector', 'views/ShoppingBarView', 'views/compare/CompareView', 'views/WebAppView'],
    c: function() {
      var WebAppSiteInjector;
      return WebAppSiteInjector = (function(_super) {
        __extends(WebAppSiteInjector, _super);

        function WebAppSiteInjector() {
          return WebAppSiteInjector.__super__.constructor.apply(this, arguments);
        }

        WebAppSiteInjector.prototype.siteName = 'WebApp';

        WebAppSiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var matches, params, shoppingBarView, webAppView;
              if (!env.core) {
                shoppingBarView = new ShoppingBarView(_this.contentScript);
                shoppingBarView.el.appendTo(document.body);
                shoppingBarView.represent();
              }
              params = JSON.parse($('html').attr('agoraparams'));
              matches = document.location.href.match(new RegExp("^" + params.base + "\/(.*)$"));
              webAppView = new WebAppView(_this.contentScript);
              return webAppView.represent(matches != null ? matches[1] : void 0);
            };
          })(this));
        };

        return WebAppSiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=WebappSiteInjector.map