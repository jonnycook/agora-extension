// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['./ObservableObject', './ObservableValue', 'underscore'], function(ObservableObject, ObservableValue, _) {
  var Record;
  return Record = (function(superClass) {
    extend(Record, superClass);

    function Record(id1, _values, _mappings, table1) {
      var name, ref, value;
      this.id = id1;
      this._values = _values;
      this._mappings = _mappings;
      this.table = table1;
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
      ref = this._values;
      for (name in ref) {
        value = ref[name];
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
      key = source.storeId + "." + source.object;
      if (this._sources[key] && accumulate) {
        return this._sources[key]++;
      } else {
        return this._sources[key] = 1;
      }
    };

    Record.prototype._removeSource = function(source) {
      var key;
      key = source.storeId + "." + source.object;
      if (this._sources[key]) {
        if (!--this._sources[key]) {
          return delete this._sources[key];
        }
      }
    };

    Record.prototype._updateContentsStoreId = function() {
      var contained, i, len, record, results;
      contained = this.contained();
      results = [];
      for (i = 0, len = contained.length; i < len; i++) {
        record = contained[i];
        results.push(record.storeId = this.storeId);
      }
      return results;
    };

    Record.prototype._updateStoreIdFromOwner = function() {
      var contained, i, len, owner, record, results;
      owner = this.owner();
      if (owner) {
        this.storeId = owner.storeId;
        contained = this.contained();
        results = [];
        for (i = 0, len = contained.length; i < len; i++) {
          record = contained[i];
          results.push(record.storeId = this.storeId);
        }
        return results;
      }
    };

    Record.prototype._createField = function(name) {
      var field, i, len, ref, ref1, ref2, rel, results;
      this._fields[name] = field = new ObservableValue(this._values[name], (ref = this.table.schema.opts) != null ? (ref1 = ref[name]) != null ? ref1.reassignIdentical : void 0 : void 0);
      if (this.table.graphRels) {
        ref2 = this.table.graphRels;
        results = [];
        for (i = 0, len = ref2.length; i < len; i++) {
          rel = ref2[i];
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
            results.push(void 0);
          }
        }
        return results;
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
      var ref;
      switch (key) {
        case 'id':
          return this.id;
        case 'store_id':
          return this.storeId;
        default:
          return (ref = this._fields[key]) != null ? ref.get() : void 0;
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
      var ref, ref1;
      return (ref = (ref1 = this.table.db.localToGlobalMapping[this.table.name]) != null ? ref1[this.id] : void 0) != null ? ref : this.id;
    };

    Record.prototype.hasGlobal = function() {
      var ref;
      return (this.id + '')[0] === 'G' || (((ref = this.table.db.localToGlobalMapping[this.table.name]) != null ? ref[this.id] : void 0) != null);
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
      var contained, i, j, len, len1, record, records, ref, rel, table;
      if (recursive == null) {
        recursive = true;
      }
      contained = [];
      if (this.table.graphRels) {
        ref = this.table.graphRels;
        for (i = 0, len = ref.length; i < len; i++) {
          rel = ref[i];
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
              for (j = 0, len1 = records.length; j < len1; j++) {
                record = records[j];
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
      var i, len, record, records, ref, rel, table;
      if (this.table.graphRels) {
        ref = this.table.graphRels;
        for (i = 0, len = ref.length; i < len; i++) {
          rel = ref[i];
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

//# sourceMappingURL=Record.js.map
