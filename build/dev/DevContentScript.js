// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return function() {
    var DevContentScript;
    return DevContentScript = (function(_super) {
      __extends(DevContentScript, _super);

      function DevContentScript() {
        return DevContentScript.__super__.constructor.apply(this, arguments);
      }

      DevContentScript.prototype.browser = 'Dev';

      DevContentScript.prototype.onRequest = function(listener) {
        return devBackground.addContentScriptListener(listener);
      };

      DevContentScript.prototype.sendRequest = function(request, cb) {
        return devBackground.requestHandler(request, {}, cb);
      };

      DevContentScript.prototype.injectUtilScripts = function(cb) {
        return devBackground.cs_injectUtilScripts(cb);
      };

      DevContentScript.prototype.resourceUrl = function(resource) {
        return "resources/" + resource;
      };

      return DevContentScript;

    })(ContentScript);
  };
});

//# sourceMappingURL=DevContentScript.map