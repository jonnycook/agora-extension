// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./ObservableArray', './auxiliary/maintainOrder2', './Relationship', 'util'], function(ObservableArray, maintainOrder, Relationship, util) {
  var HasManyRelationship, ModelInstanceWrapper;
  ModelInstanceWrapper = (function() {
    function ModelInstanceWrapper(_rel, _joint) {
      var getModel;
      this._rel = _rel;
      this._joint = _joint;
      getModel = (function(_this) {
        return function(record) {
          if (typeof _this._rel._model === 'function') {
            return _this._rel._instance.model.manager.getModel(_this._rel._model(record));
          } else {
            return _this._rel._model;
          }
        };
      })(this);
      this._update = (function(_this) {
        return function() {
          var method, _fn, _i, _j, _len, _len1, _ref, _ref1;
          if (_this._instance) {
            _this._instance.stopObservingWithTag(_this);
            if (_this._instance.instanceMethods) {
              _ref = _this._instance.instanceMethods;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                method = _ref[_i];
                delete _this[method];
              }
            }
          }
          _this._instance = getModel(_this._joint).withId(_this._joint.get(_this._rel._relKey));
          _this._instance.observeWithTag(_this, function(mutation) {
            return _this._rel._remove(_this);
          });
          if (_this._instance.instanceMethods) {
            _ref1 = _this._instance.instanceMethods;
            _fn = function(method) {
              return _this[method] = function() {
                return _this._instance[method].apply(_this._instance, arguments);
              };
            };
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              method = _ref1[_j];
              _fn(method);
            }
          }
          _this.model = _this._instance.model;
          _this.modelName = _this.model.name;
          return _this.record = _this._instance.record;
        };
      })(this);
      this._rel.observeObject(this._joint.field(this._rel._relKey), this._update);
      this._update();
    }

    ModelInstanceWrapper.prototype.get = function(propertyName) {
      if (this._joint.field(propertyName)) {
        return this._joint.get(propertyName);
      } else {
        return this._instance.get(propertyName);
      }
    };

    ModelInstanceWrapper.prototype._get = function(propertyName) {
      return this._instance._get(propertyName);
    };

    ModelInstanceWrapper.prototype.set = function(propertyName, value) {
      if (this._joint.field(propertyName)) {
        return this._joint.set(propertyName, value);
      } else {
        return this._instance.set(propertyName, value);
      }
    };

    ModelInstanceWrapper.prototype.field = function(propertyName) {
      if (this._joint.field(propertyName)) {
        return this._joint.field(propertyName);
      } else {
        return this._instance.field(propertyName);
      }
    };

    ModelInstanceWrapper.prototype["delete"] = function() {
      return this._instance["delete"]();
    };

    ModelInstanceWrapper.prototype.tableName = function() {
      return this._instance.tableName();
    };

    ModelInstanceWrapper.prototype.saneId = function() {
      return this._instance.saneId();
    };

    ModelInstanceWrapper.prototype.equals = function(instance) {
      return this._instance.equals(instance);
    };

    ModelInstanceWrapper.prototype.isA = function(modelName) {
      return this._instance.isA(modelName);
    };

    ModelInstanceWrapper.prototype["with"] = function() {
      var _ref;
      return (_ref = this._instance)["with"].apply(_ref, arguments);
    };

    ModelInstanceWrapper.prototype.retrieve = function() {
      var _ref;
      return (_ref = this._instance).retrieve.apply(_ref, arguments);
    };

    ModelInstanceWrapper.prototype.saneId = function() {
      return this._instance.saneId();
    };

    return ModelInstanceWrapper;

  })();
  return HasManyRelationship = (function(_super) {
    __extends(HasManyRelationship, _super);

    HasManyRelationship.prototype._recordDataKey = function(record) {
      return "" + record.table.name + "." + (record.get('id'));
    };

    HasManyRelationship.prototype._getRecordData = function(record, required) {
      var data, key;
      if (required == null) {
        required = false;
      }
      key = this._recordDataKey(record);
      data = this._recordData[key];
      if (!data && required) {
        Debug.error("no record data for " + key);
        throw new Error("no record data for " + key);
      }
      return data;
    };

    HasManyRelationship.prototype._setRecordData = function(record, data) {
      var key;
      key = this._recordDataKey(record);
      return this._recordData[key] = data;
    };

    HasManyRelationship.prototype._deleteRecordData = function(record) {
      return delete this._recordData[this._recordDataKey(record)];
    };

    function HasManyRelationship(_instance, _args, _relName) {
      var foreignKey, getModel, initRecord, onRecord, relKey, remove, testRelation, through;
      this._instance = _instance;
      this._args = _args;
      this._relName = _relName;
      if (Relationship.nextId == null) {
        Relationship.nextId = 1;
      }
      this.id = Relationship.nextId++;
      foreignKey = _args.foreignKey, relKey = _args.relKey, through = _args.through;
      this._model = _args.model;
      getModel = (function(_this) {
        return function(record) {
          if (typeof _this._model === 'function') {
            return _this._instance.model.manager.getModel(_this._model(record));
          } else {
            return _this._model;
          }
        };
      })(this);
      if (through) {
        this._table = this._instance.model.manager.db.table(through);
        if (!this._table) {
          throw new Error("NO TABLE");
        }
      } else {
        this._table = this._model._table;
        relKey = 'id';
        if (!this._table) {
          console.log(this._model);
          throw new Error("NO TABLE");
        }
      }
      this._relKey = relKey;
      if (!this._table) {
        console.log(this._relName);
      }
      this._list = new ObservableArray;
      if (this._args.orderBy) {
        maintainOrder(this._list, this._args.orderBy);
      }
      this._list.name = "HasManyRelationship::" + this._model.name + "." + _relName;
      this._list.observe((function(_this) {
        return function(mutation) {
          return _this._callObservers(mutation);
        };
      })(this));
      this._recordData = {};
      testRelation = (function(_this) {
        return function(record, filter) {
          var l, r, t;
          if (filter == null) {
            filter = true;
          }
          l = _this._instance.get('id');
          r = record.get(foreignKey);
          t = l == r;
          if (!t) {
            return false;
          }
          if (filter) {
            if (through && _this._args.throughFilter) {
              if (!_this._args.throughFilter(record)) {
                return false;
              }
            }
            if (_this._args.filter) {
              if (!_this._args.filter(record)) {
                return false;
              }
            }
          }
          return true;
        };
      })(this);
      remove = (function(_this) {
        return function(record) {
          var i, modelName, recordData, relId, _i, _ref, _ref1;
          relId = record.get(relKey);
          modelName = getModel(record).name;
          _this._list.deleteIf(function(relInstance) {
            return relInstance.get('id') == relId && relInstance.modelName == modelName;
          });
          recordData = _this._getRecordData(record, true);
          if (_this._args.onRemove) {
            _this._args.onRemove.call(_this, recordData.instance);
          }
          if (_this._args.orderBy) {
            if (_this.length()) {
              for (i = _i = _ref = Math.min(record.get(_this._args.orderBy), _this.length() - 1), _ref1 = _this.length(); _ref <= _ref1 ? _i < _ref1 : _i > _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
                _this.get(i).set(_this._args.orderBy, i);
              }
            }
          }
          if (typeof recordData.onRemove === "function") {
            recordData.onRemove();
          }
          return _this._deleteRecordData(record);
        };
      })(this);
      initRecord = (function(_this) {
        return function(record) {
          var field, _i, _len, _ref;
          _ref = record.fields();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            field = _ref[_i];
            field.observe(function() {
              if (_this._getRecordData(record)) {
                if (!testRelation(record)) {
                  return remove(record);
                }
              } else {
                return onRecord(record);
              }
            });
          }
          return onRecord(record);
        };
      })(this);
      onRecord = (function(_this) {
        return function(record) {
          var instance, relId;
          if (testRelation(record)) {
            relId = record.get(relKey);
            instance = null;
            if (through) {
              instance = new ModelInstanceWrapper(_this, record);
            } else {
              instance = _this._model.withId(relId);
            }
            if (!instance) {
              throw new Error('null instance');
            }
            _this._setRecordData(record, {
              instance: instance
            });
            if (_this._args.onBeforeAdd) {
              _this._args.onBeforeAdd.call(_this, instance);
            }
            _this._list.push(instance);
            if (_this._args.onAfterAdd) {
              return _this._args.onAfterAdd.call(_this, instance);
            }
          }
        };
      })(this);
      this._table.records.each(initRecord);
      this.observeObject(this._table.records, (function(_this) {
        return function(mutation) {
          if (mutation.type === 'insertion') {
            return initRecord(mutation.value);
          } else if (mutation.type === 'deletion') {
            if (_this._getRecordData(mutation.value)) {
              return remove(mutation.value);
            }
          }
        };
      })(this));
      if (_args["for"]) {
        this.init = (function(_this) {
          return function() {
            var onRelInst, path, rel;
            path = _args["for"].path.split('.');
            rel = _this._instance.get(path[0]).get(path[1]);
            _this["for"] = onRelInst = function(relInst) {
              var args, inst;
              inst = _this.find(function(inst) {
                return inst.get(_args["for"].key) === relInst.get('id');
              });
              if (!inst) {
                args = {};
                args[_args["for"].key] = relInst.get('id');
                inst = _this._model.create(args);
                _this._add(inst);
              }
              return inst;
            };
            rel.each(onRelInst);
            return _this.observeObject(rel, function(mutation) {
              var inst;
              if (mutation.type === 'insertion') {
                return onRelInst(mutation.value);
              } else if (mutation.type === 'deletion') {
                inst = _this.find(function(inst) {
                  return inst.get(_args["for"].key) === mutation.value.get('id');
                });
                if (inst) {
                  return _this.remove(inst);
                }
              }
            });
          };
        })(this);
      }
    }

    HasManyRelationship.prototype.get = function(position) {
      return this._list.get(position);
    };

    HasManyRelationship.prototype._add = function(instance, fields) {
      var defaults, name, record, value;
      if (!this.contains(instance)) {
        if (this._args.through) {
          record = {};
          record[this._args.foreignKey] = this._instance.get('id');
          record[this._args.relKey] = instance.get('id');
          defaults = {};
          if (this._args.defaultValues) {
            if (typeof this._args.defaultValues === 'function') {
              defaults = this._args.defaultValues(instance);
            } else {
              defaults = this._args.defaultValues;
            }
          }
          for (name in defaults) {
            value = defaults[name];
            record[name] = value;
          }
          if (fields) {
            for (name in fields) {
              value = fields[name];
              record[name] = value;
            }
          }
          return this._table.addRecord(record);
        } else {
          return instance.set(this._args.foreignKey, this._instance.get('id'));
        }
      }
    };

    HasManyRelationship.prototype._remove = function(instance) {
      if (this._args.through) {
        return this._table["delete"]((function(_this) {
          return function(record) {
            return record.get(_this._args.foreignKey) === _this._instance.get('id') && record.get(_this._args.relKey) === instance.get('id');
          };
        })(this));
      } else {
        return instance.set(this._args.foreignKey, null);
      }
    };

    HasManyRelationship.prototype.add = function(instance, fields) {
      if (this._args.add) {
        return this._args.add.call(this, instance, fields);
      } else {
        return this._add(instance, fields);
      }
    };

    HasManyRelationship.prototype.remove = function(instance) {
      if (this._args.remove) {
        return this._args.remove.call(this, instance);
      } else {
        return this._remove(instance);
      }
    };

    HasManyRelationship.prototype.removeAt = function(index) {
      return this.remove(this.get(index));
    };

    HasManyRelationship.prototype.removeAll = function() {
      if (this._args.through) {
        return this._table["delete"]((function(_this) {
          return function(record) {
            return record.get(_this._args.foreignKey) === _this._instance.get('id');
          };
        })(this));
      }
    };

    HasManyRelationship.prototype.each = function() {
      return this._list.each.apply(this._list, arguments);
    };

    HasManyRelationship.prototype.forEach = function() {
      return this.each.apply(this, arguments);
    };

    HasManyRelationship.prototype.contains = function(instance) {
      return !!this.find(function(inst) {
        return inst.modelName === instance.modelName && inst.get('id') === instance.get('id');
      });
    };

    HasManyRelationship.prototype.length = function() {
      return this._list.length();
    };

    HasManyRelationship.prototype.move = function(from, to) {
      return this._list.move(from, to);
    };

    HasManyRelationship.prototype.find = function(predicate) {
      return util.find(this._list, predicate);
    };

    HasManyRelationship.prototype.findAll = function(predicate) {
      return util.findAll(this._list, predicate);
    };

    HasManyRelationship.prototype.instanceForInstance = function(instance) {
      if (this._args.through) {
        return this._list.find(function(inst) {
          return inst.equals(instance);
        });
      } else {
        return this._getRecordData(instance.record, true).instance;
      }
    };

    return HasManyRelationship;

  })(Relationship);
});

//# sourceMappingURL=HasManyRelationship.map