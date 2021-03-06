// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'Site', 'Formatter', 'util', 'underscore'], function(View, Site, Formatter, util, _) {
  var AddDataView;
  return AddDataView = (function(superClass) {
    extend(AddDataView, superClass);

    function AddDataView() {
      return AddDataView.__super__.constructor.apply(this, arguments);
    }

    AddDataView.nextId = 0;

    AddDataView.id = function(args) {
      return ++this.nextId;
    };

    AddDataView.prototype.initAsync = function(args, done) {
      return this.resolveObject(args.object, (function(_this) {
        return function(obj) {
          _this.obj = obj;
          if (args.url) {
            if (args.url.match(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/)) {
              return _this.agora.background.httpRequest(args.url, {
                cb: function(responseText, response) {
                  var contentType, matches, title;
                  contentType = response.header('Content-Type');
                  if (contentType.match(/^text\/html/)) {
                    matches = responseText.match(/<title>([^<]*)<\/title>/i);
                    title = matches ? matches[1].trim() : void 0;
                    _this.data = {
                      type: 'url',
                      title: title
                    };
                  } else if (contentType.match(/^image\//)) {
                    _this.data = {
                      type: 'image'
                    };
                  }
                  return done();
                },
                error: function() {
                  return done();
                }
              });
            } else {
              return _this.data = {};
            }
          } else {
            return done();
          }
        };
      })(this));
    };

    AddDataView.prototype.methods = {
      add: function(view, data) {
        data.element_type = this.obj.modelName;
        data.element_id = this.obj.get('id');
        return this.agora.modelManager.getModel('Datum').create(data);
      }
    };

    return AddDataView;

  })(View);
});

//# sourceMappingURL=AddDataView.js.map
