// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./ObservableObject', './ObservableValue', 'underscore'], function(ObservableObject, ObservableValue, _) {
  var Record;
  return Record = (function(_super) {
    __extends(Record, _super);

    function Record(id, _values, _mappings, table) {
      var name, value;
      this.id = id;
      this._values = _values;
      this._mappings = _mappings;
      this.table = table;
      if (typeof this.id === 'string') {
        if (this.id[0] !== 'G') {
          this.id = parseInt(this.id);
        }
      }
      if (this.table.canBeExternal && this.table.db.externalStoreId) {
        this.storeId = this.table.db.externalStoreId;
      } else {
        this.storeId = this.table.db.storeId;
      }
      this._fields = {};
      this._tableName = this.table.name;
      this._sources = {};
      for (name in _values) {
        value = _values[name];
        this._values[name] = this._mappings[name] && value !== null ? this._mappings[name](value) : value;
        this._createField(name);
      }
      this._updateStoreIdFromOwner();
    }

    Record.prototype._addSource = function(source, accumulate) {
      var key;
      if (accumulate == null) {
        accumulate = true;
      }
      key = "" + source.storeId + "." + source.object;
      if (this._sources[key] && accumulate) {
        return this._sources[key]++;
      } else {
        return this._sources[key] = 1;
      }
    };

    Record.prototype._removeSource = function(source) {
      var key;
      key = "" + source.storeId + "." + source.object;
      if (this._sources[key]) {
        if (!--this._sources[key]) {
          return delete this._sources[key];
        }
      }
    };

    Record.prototype._updateContentsStoreId = function() {
      var contained, record, _i, _len, _results;
      contained = this.contained();
      _results = [];
      for (_i = 0, _len = contained.length; _i < _len; _i++) {
        record = contained[_i];
        _results.push(record.storeId = this.storeId);
      }
      return _results;
    };

    Record.prototype._updateStoreIdFromOwner = function() {
      var contained, owner, record, _i, _len, _results;
      owner = this.owner();
      if (owner) {
        this.storeId = owner.storeId;
        contained = this.contained();
        _results = [];
        for (_i = 0, _len = contained.length; _i < _len; _i++) {
          record = contained[_i];
          _results.push(record.storeId = this.storeId);
        }
        return _results;
      }
    };

    Record.prototype._createField = function(name) {
      var field, rel, _i, _len, _ref, _ref1, _ref2, _results;
      this._fields[name] = field = new ObservableValue(this._values[name], (_ref = this.table.schema.opts) != null ? (_ref1 = _ref[name]) != null ? _ref1.reassignIdentical : void 0 : void 0);
      if (this.table.graphRels) {
        _ref2 = this.table.graphRels;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          rel = _ref2[_i];
          if (rel.owns && rel.field === name) {
            field.observe((function(_this) {
              return function() {
                return _this._updateContentsStoreId();
              };
            })(this));
            break;
          } else if (rel.owner && rel.field === name) {
            field.observe((function(_this) {
              return function() {
                return _this._updateStoreIdFromOwner();
              };
            })(this));
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    Record.prototype.set = function(key, value, timestamp) {
      if (key === 'store_id') {
        return this.storeId = value;
      } else {
        this._values[key] = this._mappings[key] && value !== null ? this._mappings[key](value) : value;
        if (this._fields[key]) {
          return this._fields[key].set(this._values[key], timestamp);
        } else {
          return this._createField(key);
        }
      }
    };

    Record.prototype.get = function(key) {
      var _ref;
      switch (key) {
        case 'id':
          return this.id;
        case 'store_id':
          return this.storeId;
        default:
          return (_ref = this._fields[key]) != null ? _ref.get() : void 0;
      }
    };

    Record.prototype.field = function(key) {
      return this._fields[key];
    };

    Record.prototype.fields = function() {
      return _.values(this._fields);
    };

    Record.prototype.serialize = function() {
      return this._values;
    };

    Record.prototype.globalId = function() {
      var _ref, _ref1;
      return (_ref = (_ref1 = this.table.db.localToGlobalMapping[this.table.name]) != null ? _ref1[this.id] : void 0) != null ? _ref : this.id;
    };

    Record.prototype.hasGlobal = function() {
      var _ref;
      return (this.id + '')[0] === 'G' || (((_ref = this.table.db.localToGlobalMapping[this.table.name]) != null ? _ref[this.id] : void 0) != null);
    };

    Record.prototype.tableName = function() {
      return this.table.name;
    };

    Record.prototype.saneId = function() {
      var id;
      id = this.globalId() + '';
      if (id[0] === 'G') {
        return parseInt(id.substr(1));
      } else if (env.localTest) {
        return this.get('id');
      } else {
        console.log(this);
        throw new Error(id);
      }
    };

    Record.prototype["delete"] = function() {
      return this.table["delete"]((function(_this) {
        return function(record) {
          return record.get('id') === _this.get('id');
        };
      })(this));
    };

    Record.prototype.contained = function(recursive) {
      var contained, record, records, rel, table, _i, _j, _len, _len1, _ref;
      if (recursive == null) {
        recursive = true;
      }
      contained = [];
      if (this.table.graphRels) {
        _ref = this.table.graphRels;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rel = _ref[_i];
          if (rel.owns) {
            if (!rel.foreignKey) {
              table = _.isFunction(rel.table) ? rel.table(this) : rel.table;
              record = this.table.db.table(table).byId(this.get(rel.field));
              if (record) {
                if (_.isFunction(rel.owns)) {
                  if (rel.owns(record)) {
                    contained.push(record);
                    if (recursive) {
                      contained = contained.concat(record.contained());
                    }
                  }
                } else {
                  contained.push(record);
                  contained = contained.concat(record.contained());
                }
              }
            } else {
              records = this.table.db.table(rel.table).select((function(_this) {
                return function(record) {
                  return record.get(rel.field) === _this.get('id');
                };
              })(this));
              for (_j = 0, _len1 = records.length; _j < _len1; _j++) {
                record = records[_j];
                contained.push(record);
                if (recursive) {
                  contained = contained.concat(record.contained());
                }
              }
            }
          }
        }
      }
      return contained;
    };

    Record.prototype.owner = function() {
      var record, records, rel, table, _i, _len, _ref;
      if (this.table.graphRels) {
        _ref = this.table.graphRels;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rel = _ref[_i];
          if (rel.owner) {
            if (!rel.foreignKey) {
              table = _.isFunction(rel.table) ? rel.table(this) : rel.table;
              record = this.table.db.table(table).byId(this.get(rel.field));
              if (record) {
                return record;
              }
            } else {
              if (rel.filter) {
                records = this.table.db.table(rel.table).select((function(_this) {
                  return function(record) {
                    return record.get(rel.field) === _this.get('id') && rel.filter(_this, record);
                  };
                })(this));
              } else {
                records = this.table.db.table(rel.table).select((function(_this) {
                  return function(record) {
                    return record.get(rel.field) === _this.get('id');
                  };
                })(this));
              }
              if (records[0]) {
                return records[0];
              }
            }
          }
        }
      }
    };

    return Record;

  })(ObservableObject);
});

//# sourceMappingURL=Record.map