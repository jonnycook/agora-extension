// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return function() {
    var ChromeContentScript;
    return ChromeContentScript = (function(superClass) {
      extend(ChromeContentScript, superClass);

      ChromeContentScript.prototype.browser = 'Chrome';

      function ChromeContentScript() {
        ChromeContentScript.__super__.constructor.apply(this, arguments);
        this.port = chrome.runtime.connect();
        this.port.onMessage.addListener((function(_this) {
          return function(message) {
            if (message.type === 'response') {
              if (_this.responseCbs[message.id]) {
                _this.responseCbs[message.id](message.response);
                return delete _this.responseCbs[message.id];
              }
            } else if (message.type === 'request') {
              return _this.listener(message.request);
            }
          };
        })(this));
        this.port.onDisconnect.addListener((function(_this) {
          return function() {
            console.lo;
            return siteInjector.onOldVersion();
          };
        })(this));
        this.requestId = 1;
        this.responseCbs = {};
      }

      ChromeContentScript.prototype.onRequest = function(listener) {
        return this.listener = listener;
      };

      ChromeContentScript.prototype.sendRequest = function(request, cb) {
        var id;
        id = this.requestId++;
        if (cb) {
          this.responseCbs[id] = cb;
        }
        if (!this.requestQueue) {
          this.requestQueue = [];
          this.requestQueue.push({
            request: request,
            id: id
          });
          return setTimeout(((function(_this) {
            return function() {
              _this.port.postMessage({
                requests: _this.requestQueue
              });
              return delete _this.requestQueue;
            };
          })(this)), 0);
        } else {
          return this.requestQueue.push({
            request: request,
            id: id
          });
        }
      };

      ChromeContentScript.prototype.injectUtilScripts = function(cb) {
        return chrome.extension.sendMessage({
          request: 'injectUtilScripts'
        }, cb);
      };

      ChromeContentScript.prototype.resourceUrl = function(resource) {
        return chrome.extension.getURL("resources/" + resource);
      };

      return ChromeContentScript;

    })(ContentScript);
  };
});

//# sourceMappingURL=ChromeContentScript.js.map
