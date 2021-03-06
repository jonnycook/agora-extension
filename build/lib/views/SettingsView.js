// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'Site', 'Formatter', 'util', 'underscore'], function(View, Site, Formatter, util, _) {
  var SettingsView;
  return SettingsView = (function(superClass) {
    extend(SettingsView, superClass);

    function SettingsView() {
      return SettingsView.__super__.constructor.apply(this, arguments);
    }

    SettingsView.nextId = 0;

    SettingsView.id = function(args) {
      return ++this.nextId;
    };

    SettingsView.prototype.initAsync = function(args, done) {
      return this.background.getStorage(['options'], (function(_this) {
        return function(data) {
          var ref, ref1, ref2, ref3, ref4, ref5;
          _this.data = {
            hideBelt: (ref = (ref1 = data.options) != null ? ref1.hideBelt : void 0) != null ? ref : false,
            autoFeelings: (ref2 = (ref3 = data.options) != null ? ref3.autoFeelings : void 0) != null ? ref2 : false,
            showPreview: (ref4 = (ref5 = data.options) != null ? ref5.showPreview : void 0) != null ? ref4 : false
          };
          return done();
        };
      })(this));
    };

    SettingsView.client = function() {
      return SettingsView = (function(superClass1) {
        extend(SettingsView, superClass1);

        function SettingsView() {
          return SettingsView.__super__.constructor.apply(this, arguments);
        }

        SettingsView.prototype.type = 'Settings';

        SettingsView.prototype.booleanSettings = ['hideBelt', 'autoFeelings', 'showPreview'];

        SettingsView.prototype.init = function() {
          var i, len, name, ref, results;
          this.viewEl('<div class="v-settings t-dialog"> <h2>Settings</h2> <div class="content"> <form> <div class="field"><input type="checkbox" name="hideBelt"> <label>Hide Belt</label></div> <div class="field"><input type="checkbox" name="autoFeelings"> <label>Auto Feelings</label></div> <div class="field"><input type="checkbox" name="showPreview"> <label>Show Preview</label></div> <!--<input type="Submit">--> </form> </div> </div>');
          ref = this.booleanSettings;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            name = ref[i];
            results.push((function(_this) {
              return function(name) {
                return _this.el.find("[name=" + name + "]").change(function() {
                  return _this.callBackgroundMethod('update', [name, _this.el.find("[name=" + name + "]").prop('checked')]);
                });
              };
            })(this)(name));
          }
          return results;
        };

        SettingsView.prototype.onData = function(data) {
          var i, len, name, ref, results;
          ref = this.booleanSettings;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            name = ref[i];
            if (data[name]) {
              results.push(this.el.find("[name=" + name + "]").prop('checked', true));
            } else {
              results.push(void 0);
            }
          }
          return results;
        };

        return SettingsView;

      })(View);
    };

    SettingsView.prototype.methods = {
      submit: function(view, subject, message) {
        return this.agora.background.httpRequest(this.agora.background.apiRoot + "contact.php", {
          method: 'post',
          data: {
            subject: subject,
            message: message
          }
        });
      },
      update: function(view, prop, value) {
        var options;
        options = {};
        options[prop] = value;
        return this.agora.setOptions(options);
      }
    };

    return SettingsView;

  })(View);
});

//# sourceMappingURL=SettingsView.js.map
