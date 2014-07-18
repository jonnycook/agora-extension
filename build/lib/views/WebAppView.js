// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View'], function(View) {
  var WebAppView;
  return WebAppView = (function(_super) {
    __extends(WebAppView, _super);

    function WebAppView() {
      return WebAppView.__super__.constructor.apply(this, arguments);
    }

    WebAppView.id = function(args) {
      return args;
    };

    WebAppView.prototype.initAsync = function(args, done) {
      var parts, path;
      this.data = {};
      if (args) {
        path = args;
        parts = path.split('/');
        if (parts[0] === 'decisions') {
          return this.agora["public"].get('decisions', parts[1], (function(_this) {
            return function(success, id) {
              if (success) {
                _this.data.decisionId = 'G' + id;
              } else {
                _this.data.accessDenied = true;
              }
              return done();
            };
          })(this));
        } else {
          return done();
        }
      } else {
        return done();
      }
    };

    return WebAppView;

  })(View);
});

//# sourceMappingURL=WebAppView.map
