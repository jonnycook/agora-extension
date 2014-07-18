(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  define(['../ChromeBrowser'], function(ChromeBrowser) {
    var TestBrowser;
    return TestBrowser = (function(_super) {

      __extends(TestBrowser, _super);

      function TestBrowser() {}

      TestBrowser.prototype.listen = function(request, cb) {
        if (this.listeners == null) this.listeners = {};
        return this.listeners[request] = cb;
      };

      TestBrowser.prototype.triggerRequest = function(source, request, sendResponse) {
        var _ref;
        return (_ref = this.listeners) != null ? typeof _ref[request] === "function" ? _ref[request](source, sendResponse) : void 0 : void 0;
      };

      TestBrowser.prototype.httpGet = function(opts) {
        var data, _ref;
        if (data = (_ref = this.urlData) != null ? _ref[opts.url] : void 0) {
          return opts.cb(data);
        } else {
          return TestBrowser.__super__.httpGet.apply(this, arguments);
        }
      };

      return TestBrowser;

    })(ChromeBrowser);
  });

}).call(this);
