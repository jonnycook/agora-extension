// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'Site', 'Formatter', 'util', 'underscore', 'taxonomy'], function(View, Site, Formatter, util, _, taxonomy) {
  var BarItemView;
  return BarItemView = (function(superClass) {
    extend(BarItemView, superClass);

    function BarItemView() {
      return BarItemView.__super__.constructor.apply(this, arguments);
    }

    BarItemView.nextId = 1;

    BarItemView.id = function(args) {
      var id;
      if (args.container) {
        return "#c.{args.container.type}." + args.container.id + "." + args.type + "." + args.id;
      } else if (args.type && args.id) {
        return args.type + "." + args.id;
      } else if (args.elementType && args.elementId) {
        id = args.elementType + "." + args.elementId;
        if (args.decisionId) {
          id += "." + args.decisionId;
        }
        return id;
      } else {
        return this.nextId++;
      }
    };

    BarItemView.prototype.dropped = function(obj, dropAction) {
      var bundle, newObj;
      if (this.obj) {
        if (obj.modelName === 'Datum') {
          tracking.event('ShoppingBar', 'addData');
          obj.set('element_type', this.obj.modelName);
          return obj.set('element_id', this.obj.get('id'));
        } else if (obj.modelName === 'Descriptor') {
          if (this.descriptor) {
            this.descriptor.set('descriptor', obj.get('descriptor'));
            return obj["delete"]();
          } else if (this.obj.modelName === 'Decision') {
            this.obj.get('list').set('descriptor', obj.get('descriptor'));
            return obj["delete"]();
          } else {
            obj.set('element_type', this.obj.modelName);
            obj.set('element_id', this.obj.get('id'));
            this.element.set('element_type', obj.modelName);
            return this.element.set('element_id', obj.get('id'));
          }
        } else {
          newObj = null;
          if (dropAction === 'createBundle') {
            tracking.event('ShoppingBar', 'createBundle');
            bundle = this.agora.modelManager.getModel('Bundle').create();
            obj = util.resolveObject(obj);
            bundle.get('contents').add(this.obj);
            bundle.get('contents').add(obj);
            _activity('convert', this.element, this.obj, obj, bundle);
            newObj = bundle;
          } else {
            if (this.descriptor && this.obj.isNull()) {
              this.descriptor.set('element_type', obj.modelName);
              this.descriptor.set('element_id', obj.get('id'));
            } else if (this.barItem.dropped) {
              newObj = this.barItem.dropped(obj, dropAction);
            }
          }
          if (newObj) {
            if (this.descriptor) {
              this.descriptor.set('element_type', newObj.modelName);
              return this.descriptor.set('element_id', newObj.get('id'));
            } else if (this.element) {
              this.element.set('element_type', newObj.modelName);
              return this.element.set('element_id', newObj.get('id'));
            } else if (this.slot) {
              this.slot.set('element_type', newObj.modelName);
              return this.slot.set('element_id', newObj.get('id'));
            }
          }
        }
      } else if (this.barItemType) {
        return this.barItem.dropped(obj, dropAction);
      }
    };

    BarItemView.prototype.onClientDisconnect = function() {
      return this.destruct();
    };

    BarItemView.prototype.initAsync = function(args, done) {
      var creatorId, selected, update, updateSelected, userWrapper;
      this.data = this.clientValueNamed('BarItemView.data');
      this.barItemCtx = this.context();
      this.element = this.agora.modelManager.getModel(this.args.elementType).withId(this.args.elementId);
      this.additionalData = {};
      update = (function(_this) {
        return function(cb) {
          var object;
          if (_this.descriptor) {
            _this.stopObservingObject(_this.descriptor.get('element'));
          }
          delete _this.objectReference;
          delete _this.getObj;
          delete _this.descriptor;
          delete _this.barItemType;
          _this.obj = _this.element.get('element');
          if (_this.obj.modelName === 'Descriptor') {
            _this.descriptor = _this.obj;
            _this.obj = _this.obj.get('element');
            _this.observeObject(_this.descriptor.get('element'), update);
          } else if (_this.obj.modelName === 'ObjectReference') {
            _this.objectReference = _this.obj;
            _this.obj = null;
            _this.getObj = function() {
              return this.objectReference;
            };
            object = _this.objectReference.get('object');
            _this.additionalData.user = {
              color: util.colorForUser(_this.agora.user, _this.objectReference.get('object_user_id'))
            };
            _this.agora.updater.transport.whenObject(_this.objectReference.get('object_user_id'), ['@', object], function() {
              var id, ref, table;
              delete _this.barItemType;
              if (object === '/') {
                _this.barItemType = 'SharedBelt';
                return setTimeout((function() {
                  return _this.updateBarItem();
                }), 200);
              } else {
                ref = object.split('.'), table = ref[0], id = ref[1];
                if (table === 'decisions') {
                  _this.obj = _this.agora.modelManager.getInstance('Decision', "G" + id);
                  return setTimeout((function() {
                    return _this.updateBarItem();
                  }), 200);
                } else if (table === 'belts') {
                  _this.obj = _this.agora.modelManager.getInstance('Belt', "G" + id);
                  return setTimeout((function() {
                    return _this.updateBarItem();
                  }), 200);
                }
              }
            }, function() {
              var id, ref, table;
              _this.obj = null;
              _this.barItemType = 'Unauthorized';
              if (object === '/') {
                _this.additionalData.objectType = 'Belt';
              } else {
                ref = object.split('.'), table = ref[0], id = ref[1];
                if (table === 'decisions') {
                  _this.additionalData.objectType = 'Decision';
                } else if (table === 'belts') {
                  _this.additionalData.objectType = 'Belt';
                }
              }
              return setTimeout((function() {
                return _this.updateBarItem();
              }), 200);
            });
          }
          return _this.updateBarItem(cb);
        };
      })(this);
      if (this.element.get('creator_id') && this.element.get('creator_id') !== this.agora.user.get('id')) {
        creatorId = this.element.get('creator_id').substr(1);
        userWrapper = util.userWrapper(creatorId);
        this.additionalData.creator = {
          color: util.colorForUser(this.agora.user, creatorId),
          name: this.clientValue(userWrapper.field('name'))
        };
      }
      if (this.element.modelName === 'ListElement' && args.decisionId) {
        selected = this.clientValueNamed('selected');
        _.merge(this.additionalData, {
          selected: selected,
          decisionId: args.decisionId
        });
        this.decision = this.agora.modelManager.getInstance('Decision', args.decisionId);
        updateSelected = (function(_this) {
          return function() {
            return selected.set(_this.decision.get('selection').contains(_this.element));
          };
        })(this);
        updateSelected();
        this.decision.get('selection').observe(updateSelected);
      }
      this.observeObject(this.element.get('element'), update);
      return update(done);
    };

    BarItemView.prototype.updateBarItem = function(cb) {
      if (cb == null) {
        cb = null;
      }
      return this.initBarItem((function(_this) {
        return function() {
          var data, ref, ref1;
          if (_this.obj) {
            if (_this.descriptor && _this.obj.isNull()) {
              data = {
                descriptor: _this.descriptor.get('descriptor'),
                icon: taxonomy.icon((ref = _this.descriptor.get('descriptor')) != null ? (ref1 = ref.product) != null ? ref1.type : void 0 : void 0)
              };
              if (_this.additionalData) {
                _.extend(data, _this.additionalData);
              }
              _this.data.set(data);
              return typeof cb === "function" ? cb() : void 0;
            } else {
              return _this.barItem.getData(function(data) {
                if (_this.descriptor) {
                  data.descriptor = _this.descriptor.get('descriptor');
                }
                data.id = _this.obj.get('id');
                if (_this.additionalData) {
                  _.extend(data, _this.additionalData);
                }
                _this.data.set(data);
                return typeof cb === "function" ? cb() : void 0;
              });
            }
          } else if (_this.barItemType) {
            return _this.barItem.getData(function(data) {
              if (_this.additionalData) {
                _.extend(data, _this.additionalData);
              }
              _this.data.set(data);
              return typeof cb === "function" ? cb() : void 0;
            });
          } else {
            _this.data.set(null);
            return typeof cb === "function" ? cb() : void 0;
          }
        };
      })(this));
    };

    BarItemView.prototype.initBarItem = function(cb) {
      var ref, type;
      this.barItemCtx.clear();
      if (this.obj || this.barItemType) {
        if (this.descriptor && (!this.obj || this.obj.isNull())) {
          delete this.barItem;
          return cb();
        } else {
          type = (ref = this.barItemType) != null ? ref : this.obj.model.name === 'ProductVariant' ? 'Product' : this.obj.model.name;
          return this.getBarItem(type, this.obj, (function(_this) {
            return function(barItem) {
              _this.barItem = barItem;
              return cb();
            };
          })(this));
        }
      } else {
        return cb();
      }
    };

    BarItemView.prototype.getBarItem = function(type, obj, cb) {
      return this.agora.background.require(["views/ShoppingBarView/" + type + "BarItem"], (function(_this) {
        return function(klass) {
          var barItem;
          barItem = new klass;
          barItem.barItemView = _this;
          barItem.obj = obj;
          barItem.ctx = _this.barItemCtx;
          if (typeof barItem.init === "function") {
            barItem.init();
          }
          if (barItem.initAsync) {
            return barItem.initAsync(function() {
              return cb(barItem);
            });
          } else {
            return cb(barItem);
          }
        };
      })(this));
    };

    BarItemView.prototype.hasMethod = function(name) {
      var ref, ref1;
      return this.methods[name] || ((ref = this.barItem) != null ? (ref1 = ref.methods) != null ? ref1[name] : void 0 : void 0);
    };

    BarItemView.prototype.method = function(name) {
      if (this.methods[name]) {
        return this.methods[name];
      } else {
        return this.barItem.methods[name];
      }
    };

    BarItemView.prototype["delete"] = function() {
      var obj, ref;
      if (this.slot) {
        this.slot.set('element_type', null);
        return this.slot.set('element_id', null);
      } else {
        _activity('remove', this.element, this.element.get('element'));
        obj = this.element.get('element');
        this.element["delete"]();
        if ((ref = obj.modelName) === 'ObjectReference') {
          return obj["delete"]();
        }
      }
    };

    BarItemView.prototype.methods = {
      "delete": function() {
        return this["delete"]();
      },
      click: function(view) {
        var ref, ref1, ref2;
        return (ref = this.barItem) != null ? (ref1 = ref.methods) != null ? (ref2 = ref1.click) != null ? ref2.call(this.barItem, view) : void 0 : void 0 : void 0;
      },
      reorder: function(view, fromIndex, toIndex) {
        return util.reorder(this.obj.get('contents'), fromIndex, toIndex);
      },
      add: function(view, type) {
        var composite;
        composite = this.agora.modelManager.getModel('Composite').createWithType(type);
        return this.obj.get('contents').add(composite);
      },
      setSelected: function(view, selected) {
        if (this.decision) {
          if (selected) {
            this.decision.get('selection').add(this.element);
            return _activity('decision.select', this.decision, this.element.get('element'));
          } else {
            this.decision.get('selection').remove(this.element);
            return _activity('decision.deselect', this.decision, this.element.get('element'));
          }
        }
      }
    };

    return BarItemView;

  })(View);
});

//# sourceMappingURL=BarItemView1.js.map
