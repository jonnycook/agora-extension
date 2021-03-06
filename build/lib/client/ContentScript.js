// Generated by CoffeeScript 1.10.0
define(function() {
  return function() {
    var ContentScript;
    return ContentScript = (function() {
      function ContentScript() {
        this.listeners = {};
        this.eventMap = {};
        this.onRequest((function(_this) {
          return function(request) {
            var j, l, len, listener, results;
            if (request.eventName) {
              if (_this.eventMap[request.eventName]) {
                Debug.log('ReceivedRequest', request.eventName, _this.eventMap[request.eventName], request.args);
              } else {
                Debug.log('ReceivedRequest', request.eventName, request.args);
              }
              if (l = _this.listeners[request.eventName]) {
                results = [];
                for (j = 0, len = l.length; j < len; j++) {
                  listener = l[j];
                  results.push(listener(request.args));
                }
                return results;
              } else {

              }
            }
          };
        })(this));
      }

      ContentScript.prototype.mapEvent = function(event, obj) {
        return this.eventMap[event] = obj;
      };

      ContentScript.prototype.listen = function(eventName, listener, tag) {
        if (this.eventMap[eventName]) {

        } else {

        }
        if (this.listeners[eventName]) {
          return this.listeners[eventName].push(listener);
        } else {
          this.listeners[eventName] = [listener];
          return this.sendRequest({
            request: 'listen',
            eventName: eventName,
            version: this.version
          }, (function(_this) {
            return function(response) {
              if (response === 'oldVersion') {
                return siteInjector.onOldVersion();
              }
            };
          })(this));
        }
      };

      ContentScript.prototype.stopListening = function(eventName, listener, tag) {
        var i, l;
        if (this.eventMap[eventName]) {

        } else {

        }
        if (l = this.listeners[eventName]) {
          i = l.indexOf(listener);
          if (i !== -1) {
            l.splice(i, 1);
          }
          if (!l.length) {
            this.sendRequest({
              request: 'stopListening',
              eventName: eventName,
              version: this.version
            }, (function(_this) {
              return function(response) {
                if (response === 'oldVersion') {
                  return siteInjector.onOldVersion();
                }
              };
            })(this));
            return delete this.listeners[eventName];
          }
        }
      };

      ContentScript.prototype.reloadExtension = function() {
        return this.triggerBackgroundEvent('reloadExtension');
      };

      ContentScript.prototype.triggerBackgroundEvent = function(eventName, args, cb) {
        return this.sendRequest({
          request: 'BackgroundMessage',
          messageName: eventName,
          args: args,
          version: this.version
        }, (function(_this) {
          return function(response) {
            if (response === 'oldVersion') {
              return siteInjector.onOldVersion();
            } else {
              return typeof cb === "function" ? cb(response) : void 0;
            }
          };
        })(this));
      };

      ContentScript.prototype.querySelector = function(selector) {
        return document.querySelector(selector);
      };

      ContentScript.prototype.querySelectorAll = function(selector) {
        return document.querySelectorAll(selector);
      };

      ContentScript.prototype.createElement = function(tag) {
        return document.createElement(tag);
      };

      ContentScript.prototype.safeQuerySelector = function(selector) {
        var el;
        el = this.querySelector(selector);
        if (el) {
          return el;
        } else {
          throw new Error(selector + " no found");
        }
      };

      ContentScript.prototype.selfQuerySelectorAll = function(selector) {
        var els;
        els = this.querySelectorAll;
        if (els.length) {
          return els;
        } else {
          throw new Error(selector + " not found");
        }
      };

      return ContentScript;

    })();
  };
});

//# sourceMappingURL=ContentScript.js.map
