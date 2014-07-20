// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./ModelInstance', './ObservableArray', './Event', './auxiliary/maintainOrder2'], function(ModelInstanceBase, ObservableArray, Event, maintainOrder) {
  var Model;
  return Model = (function() {
    function Model(manager, name, background, args) {
      var ModelInstance, method, table, _ref;
      this.manager = manager;
      this.name = name;
      this.background = background;
      this.relationships = args.relationships, this.properties = args.properties;
      this._byId = {};
      this._list = new ObservableArray;
      this._list.name = "Model::" + this.name;
      this._table = table = this.manager.db.table(args.table);
      this._args = args;
      this._fault = args.fault;
      if (!table) {
        throw new Error("NO TABLE");
      }
      if (this._args.orderBy) {
        maintainOrder(this._list, this._args.orderBy);
      }
      table.records.each((function(_this) {
        return function(record) {
          return _this._addFromRecord(record, false);
        };
      })(this));
      table.records.observe((function(_this) {
        return function(mutation) {
          if (!_this._ignoringTableMutations) {
            if (mutation.type === 'insertion') {
              return _this._addFromRecord(mutation.value);
            } else if (mutation.type === 'deletion') {
              return _this._remove(mutation.value);
            }
          }
        };
      })(this));
      this.ModelInstance = ModelInstance = (function(_super) {
        __extends(ModelInstance, _super);

        function ModelInstance() {
          return ModelInstance.__super__.constructor.apply(this, arguments);
        }

        return ModelInstance;

      })(ModelInstanceBase);
      if (args.instanceMethods) {
        _ref = args.instanceMethods;
        for (name in _ref) {
          method = _ref[name];
          this.ModelInstance.prototype[name] = method;
        }
      }
      this.events = {
        onCreate: new Event,
        onRemove: new Event
      };
    }

    Model.prototype._initRelationships = function() {
      return this._list.each(function(instance) {
        return instance._createRelationships();
      });
    };

    Model.prototype._addFromRecord = function(record, createRelationships) {
      var instance, _ref;
      if (createRelationships == null) {
        createRelationships = true;
      }
      if (!this._byId[record.get('id')]) {
        instance = new this.ModelInstance(this, record, false);
        this._byId[instance.get('id')] = instance;
        if (this._args.onBeforeAdd) {
          this._args.onBeforeAdd.call(this, instance);
        }
        instance.createRelationships(createRelationships);
        this._list.push(instance);
        if ((_ref = this._args.onAfterAdd) != null) {
          _ref.call(this, instance);
        }
        setTimeout(((function(_this) {
          return function() {
            if (instance._relationships) {
              return _this.events.onCreate.fire(instance, _this);
            }
          };
        })(this)), 0);
        return instance;
      } else {
        return this._byId[record.get('id')];
      }
    };

    Model.prototype._remove = function(record) {
      var i, instance, name, rel, _i, _ref, _ref1, _ref2, _results;
      this._list.deleteIf((function(_this) {
        return function(model) {
          return model.get('id') == record.get('id');
        };
      })(this));
      instance = this._byId[record.get('id')];
      _ref = instance._relationships;
      for (name in _ref) {
        rel = _ref[name];
        rel.destruct();
      }
      instance._fireMutation('deleted');
      delete this._byId[record.get('id')];
      if (this._args.onRemove) {
        this._args.onRemove.call(this, instance);
      }
      this.events.onRemove.fire(instance, this);
      if (this._args.orderBy) {
        if (this._list.length()) {
          _results = [];
          for (i = _i = _ref1 = Math.min(record.get(this._args.orderBy), this._list.length() - 1), _ref2 = this._list.length(); _ref1 <= _ref2 ? _i < _ref2 : _i > _ref2; i = _ref1 <= _ref2 ? ++_i : --_i) {
            _results.push(this._list.get(i).set(this._args.orderBy, i));
          }
          return _results;
        }
      }
    };

    Model.prototype.withId = function(id, throwError) {
      var instance;
      if (throwError == null) {
        throwError = true;
      }
      if (!this._byId[id]) {
        if (this._fault) {
          this._table._addRecord({}, id);
          instance = this._byId[id];
          this.manager.events.onFault.fire(instance);
          return instance;
        } else if (throwError) {
          throw new Error("Model " + this.name + " does not have instance with id " + id);
        }
      } else {
        return this._byId[id];
      }
    };

    Model.prototype._ignoreTableMutations = function(block) {
      var ret;
      this._ignoringTableMutations = true;
      ret = block();
      this._ignoringTableMutations = false;
      return ret;
    };

    Model.find = function(list, predicate) {
      if (_.isPlainObject(predicate)) {
        return list.find(function(instance) {
          var name, value;
          for (name in predicate) {
            value = predicate[name];
            if (instance.get(name) !== value) {
              return false;
            }
          }
          return true;
        });
      } else {
        return list.find(predicate);
      }
    };

    Model.findAll = function(list, predicate) {
      if (_.isPlainObject(predicate)) {
        return list.findAll(function(instance) {
          var name, value;
          for (name in predicate) {
            value = predicate[name];
            if (instance.get(name) !== value) {
              return false;
            }
          }
          return true;
        });
      } else {
        return list.findAll(predicate);
      }
    };

    Model.prototype.find = function(predicate) {
      return Model.find(this._list, predicate);
    };

    Model.prototype.findAll = function(predicate) {
      return Model.findAll(this._list, predicate);
    };

    Model.prototype.add = function(data) {
      var record;
      if (data == null) {
        data = {};
      }
      record = this._table.addRecord(data);
      return this._byId[record.get('id')];
    };

    Model.prototype.create = function(data) {
      if (data == null) {
        data = {};
      }
      return this.add(data);
    };

    Model.prototype.all = function() {
      return this._list;
    };

    Model.prototype["delete"] = function(instance) {
      var rel, relName, _ref, _results;
      if (instance.model === this) {
        this._table["delete"]((function(_this) {
          return function(record) {
            return record.id == instance.get('id');
          };
        })(this));
        _ref = instance._relationships;
        _results = [];
        for (relName in _ref) {
          rel = _ref[relName];
          if (typeof rel.removeAll === "function") {
            rel.removeAll();
          }
          _results.push(rel.destruct());
        }
        return _results;
      } else {
        throw new Error("incorrect instance model");
      }
    };

    Model.prototype.clear = function() {
      this._byId = {};
      return this._list.clear();
    };

    return Model;

  })();
});

//# sourceMappingURL=Model.map
