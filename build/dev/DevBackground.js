// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['jQuery', 'Background', './DevContentScript'], function($, Background, DevContentScript) {
  var DevBackground;
  return DevBackground = (function(_super) {
    __extends(DevBackground, _super);

    function DevBackground() {
      return DevBackground.__super__.constructor.apply(this, arguments);
    }

    DevBackground.prototype.apiRoot = 'agoraext.dev/api/';

    DevBackground.prototype.getStyles = function(cb) {
      return $.get('/resources/stylesheets/dev.css', cb);
    };

    DevBackground.prototype.clientLibsPath = function() {
      return '/libs/client/merged.js';
    };

    DevBackground.prototype.cs_injectUtilScripts = function(cb) {
      var i, inc, libs, link;
      libs = this.libs;
      i = 0;
      inc = function() {
        var l;
        if (i === libs.length) {
          return cb();
        } else {
          l = libs[i++];
          if (!_.isArray(l)) {
            l = [l];
          }
          return require(l, inc);
        }
      };
      inc();
      link = document.createElement("link");
      link.type = "text/css";
      link.rel = "stylesheet";
      link.href = 'resources/stylesheets/dev.css';
      return document.getElementsByTagName("head")[0].appendChild(link);
    };

    DevBackground.prototype.onRequest = function(handler) {
      return this.requestHandler = handler;
    };

    DevBackground.prototype.sendRequest = function(tabId, request, response) {
      var listener, _i, _len, _ref, _results;
      if (this.csListeners) {
        _ref = this.csListeners;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          listener = _ref[_i];
          _results.push(listener(request, {}, response));
        }
        return _results;
      }
    };

    DevBackground.prototype.addContentScriptListener = function(listener) {
      if (this.csListeners == null) {
        this.csListeners = [];
      }
      return this.csListeners.push(listener);
    };

    DevBackground.prototype.contentScript = function() {
      return DevContentScript;
    };

    DevBackground.prototype.httpRequest = function(url, opts) {
      return $.ajax(url, {
        data: opts.data,
        success: opts.cb,
        dataType: opts.dataType,
        error: function(error) {
          return console.log(arguments);
        }
      });
    };

    DevBackground.prototype.require = function(modules, cb) {
      return require(modules, cb);
    };

    DevBackground.prototype.setTimeout = function(cb, duration) {
      return setTimeout(cb, duration);
    };

    DevBackground.prototype.clearTimeout = function(id) {
      return clearTimeout(id);
    };

    DevBackground.prototype.getValue = function(name) {
      return window[name];
    };

    DevBackground.prototype.setValue = function(name, value) {
      return window[name] = value;
    };

    DevBackground.prototype.defaultValue = function(name, value) {
      return window[name] != null ? window[name] : window[name] = value;
    };

    return DevBackground;

  })(Background);
});

//# sourceMappingURL=DevBackground.map