// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return function() {
    var WebAppView;
    return WebAppView = (function(_super) {
      __extends(WebAppView, _super);

      function WebAppView() {
        return WebAppView.__super__.constructor.apply(this, arguments);
      }

      WebAppView.prototype.type = 'WebApp';

      WebAppView.prototype.onData = function(data) {
        var compareView, resize, resizeTimerId;
        $('<div id="agoraCont" class="-agora" />').appendTo(document.body);
        resizeTimerId = null;
        resize = (function(_this) {
          return function() {
            clearTimeout(resizeTimerId);
            resizeTimerId = setTimeout((function() {
              var width;
              width = $(window).width();
              $('#agoraCont').width(width);
              return $('#agoraCont').triggerHandler('resize');
            }), 10);
            return true;
          };
        })(this);
        $(window).resize(resize);
        resize();
        if (data.accessDenied) {
          return $('#agoraCont').addClass('accessDenied');
        } else if (data.decisionId) {
          compareView = new CompareView(this.contentScript, $('#agoraCont'), $(document.body), true);
          compareView.el.appendTo('#agoraCont');
          return compareView.represent({
            "public": true,
            decision: {
              id: data.decisionId
            }
          });
        }
      };

      return WebAppView;

    })(View);
  };
});

//# sourceMappingURL=WebAppView.map