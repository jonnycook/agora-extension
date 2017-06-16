// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  slice = [].slice;

define(['underscore', 'model/ModelInstance', 'CommandExecuter', 'model/ObservableValue', 'model/Event'], function(_, ModelInstance, CommandExecuter, ObservableValue, Event) {
  var HttpTransport, Updater, UpdaterTransport, WebSocketTransport;
  UpdaterTransport = (function() {
    function UpdaterTransport(updater) {
      this.updater = updater;
    }

    return UpdaterTransport;

  })();
  WebSocketTransport = (function(superClass) {
    extend(WebSocketTransport, superClass);

    WebSocketTransport.prototype.polling = false;

    function WebSocketTransport() {
      WebSocketTransport.__super__.constructor.apply(this, arguments);
      this.updateQueue = [];
    }

    WebSocketTransport.prototype.changesSent = function(changes) {
      return this.sentChanges = changes;
    };

    WebSocketTransport.prototype.changesConfirmed = function() {
      return delete this.sentChanges;
    };

    WebSocketTransport.prototype.executeUpdate = function(message) {
      var changes, i, len, ref;
      if ('userId' in message) {
        this.updater.setUser(parseInt(message.userId));
      }
      this.updater.disabled = true;
      if (_.isArray(message.changes)) {
        ref = message.changes;
        for (i = 0, len = ref.length; i < len; i++) {
          changes = ref[i];
          this.updater.db.executeChanges(changes);
        }
      } else {
        this.updater.db.executeChanges(message.changes);
      }
      return this.updater.disabled = false;
    };

    WebSocketTransport.prototype.userChanged = function() {
      if (this.ws) {
        this.clientId = this.updater.clientId = null;
        this.ws.close();
        delete this.ws;
        console.debug('registering client');
        return this.registerClient((function(_this) {
          return function(response) {
            if (response) {
              return _this.createWebSocket();
            } else {
              return _this.updater.setUser(0);
            }
          };
        })(this));
      } else {
        return this.init();
      }
    };

    WebSocketTransport.prototype.doInit = function(messageType) {
      var changes, data;
      console.debug('sending client id %s', this.clientId);
      this.updating = true;
      data = {
        type: messageType,
        clientId: this.clientId
      };
      if (this.sentChanges) {
        data.changes = JSON.stringify(this.sentChanges);
        data.updateToken = this.updateToken;
      } else if (this._hasChanges) {
        delete this._hasChanges;
        changes = this.updater.compileChanges();
        this.updater.clearChanges();
        if (changes) {
          this.changesSent(changes);
          data.changes = JSON.stringify(changes);
          data.updateToken = this.updateToken;
        }
      }
      return this.ws.send(JSON.stringify(data));
    };

    WebSocketTransport.prototype.createWebSocket = function(onInit) {
      console.debug('creating websocket...');
      this.ws = new WebSocket("ws://" + this.server + ":8080");
      this.ws.onclose = (function(_this) {
        return function() {
          console.debug('socket close');
          _this.open = false;
          _this.close = true;
          if (_this.clientId) {
            return setTimeout((function() {
              return _this.createWebSocket(onInit);
            }), 1000);
          }
        };
      })(this);
      this.ws.onmessage = (function(_this) {
        return function(message) {
          var i, j, len, len1, ref, ref1, update;
          if (message.data === 'invalid client id') {
            _this.registerClient(function() {
              return _this.doInit('changeClient');
            });
            console.debug('invalid client id');
            return;
          }
          message = JSON.parse(message.data);
          console.debug(message);
          switch (message.type) {
            case 'update':
              if (_this.updating) {
                return _this.updateQueue.push(message);
              } else {
                return _this.executeUpdate(message);
              }
              break;
            case 'init':
              _this.updating = false;
              if (_this.sentChanges) {
                _this.changesConfirmed();
                _this.updateToken = message.newUpdateToken;
                if (_this._hasChanges || _this.moreChanges) {
                  delete _this._hasChanges;
                  delete _this.moreChanges;
                  _this.hasChanges();
                }
              }
              if (_this.started) {
                _this.updater.reset();
              }
              _this.started = true;
              _this.executeUpdate(message);
              if (typeof onInit === "function") {
                onInit();
              }
              if (_this.updateQueue.length) {
                ref = _this.updateQueue;
                for (i = 0, len = ref.length; i < len; i++) {
                  update = ref[i];
                  _this.executeUpdate(update);
                }
                return _this.updateQueue = [];
              }
              break;
            case 'response':
              _this.changesConfirmed();
              _this.updateToken = message.newUpdateToken;
              if (message.mapping != null) {
                _this.updater.db.addMapping(message.mapping);
              }
              _this.updating = false;
              if (_this.moreChanges) {
                delete _this.moreChanges;
                return _this.hasChanges();
              } else {
                if (_this.updateQueue.length) {
                  ref1 = _this.updateQueue;
                  for (j = 0, len1 = ref1.length; j < len1; j++) {
                    update = ref1[j];
                    _this.executeUpdate(update);
                  }
                  return _this.updateQueue = [];
                }
              }
          }
        };
      })(this);
      this.ws.onopen = (function(_this) {
        return function() {
          _this.open = true;
          return _this.doInit('init');
        };
      })(this);
      return this.ws;
    };

    WebSocketTransport.prototype.registerClient = function(cb) {
      return this.updater.background.httpRequest(this.updater.background.apiRoot + 'ws/registerClient.php', {
        data: {
          extVersion: this.updater.background.extVersion
        },
        dataType: 'json',
        cb: (function(_this) {
          return function(response) {
            if (response === 'not signed in') {
              _this.server = _this.updater.clientId = _this.clientId = null;
              return cb(null);
            } else if (response.status === 'success') {
              _this.updater.clientId = _this.clientId = response.clientId;
              _this.server = response.updaterServer;
              return typeof cb === "function" ? cb(response) : void 0;
            }
          };
        })(this)
      });
    };

    WebSocketTransport.prototype.init = function(onInit) {
      return this.registerClient((function(_this) {
        return function(response) {
          if (response === null) {
            return typeof onInit === "function" ? onInit() : void 0;
          } else {
            _this.updateToken = response.updateToken;
            return _this.createWebSocket(onInit);
          }
        };
      })(this));
    };

    WebSocketTransport.prototype.hasChanges = function() {
      if (this.open) {
        if (this.updating) {
          return this.moreChanges = true;
        } else if (!this.startedUpdating) {
          this.startedUpdating = true;
          return setTimeout(((function(_this) {
            return function() {
              var changes;
              delete _this.startedUpdating;
              _this.updating = true;
              changes = _this.updater.compileChanges();
              _this.updater.clearChanges();
              if (changes) {
                _this.changesSent(changes);
                console.debug('sending', changes);
                return _this.ws.send(JSON.stringify({
                  type: 'update',
                  changes: JSON.stringify(changes),
                  updateToken: _this.updateToken
                }));
              }
            };
          })(this)), 200);
        }
      } else {
        return this._hasChanges = true;
      }
    };

    return WebSocketTransport;

  })(UpdaterTransport);
  HttpTransport = (function(superClass) {
    extend(HttpTransport, superClass);

    function HttpTransport() {
      return HttpTransport.__super__.constructor.apply(this, arguments);
    }

    HttpTransport.prototype.polling = true;

    HttpTransport.prototype.init = function(onInit) {
      return this.updater.update(onInit);
    };

    HttpTransport.prototype.sendUpdate = function(args) {
      return this.updater.background.httpRequest(this.updater.background.apiRoot + 'update.php', {
        method: 'post',
        dataType: 'json',
        data: args.data,
        cb: (function(_this) {
          return function(response) {
            var e, error, userId;
            if (response === 'not signed in') {
              console.debug('not signed in');
              _this.updater.mergePrevTablesWithTables();
              _this.updater.resetUpdateTimer(3000);
            } else if (!response || response === 'error') {
              _this.updater.mergePrevTablesWithTables();
              _this.updater.resetUpdateTimer(10000);
              console.debug('done with error', response);
              _this.updater.errorState.set(true);
            } else {
              if ('status' in response) {
                _this.updater.status.set(response.status);
              }
              _this.updater.message.set(response.message);
              if ('updateInterval' in response) {
                _this.updater.updateInterval = response.updateInterval;
              }
              if ('clientId' in response) {
                _this.updater.background.clientId = _this.updater.clientId = response.clientId;
              }
              if ('track' in response) {
                tracking.enabled = response.track;
              }
              if ('domain' in response) {
                _this.updater.background.setDomain(response.domain);
              }
              userId = parseInt(response.userId);
              _this.updater.setUser(userId);
              if (_this.updater.userId) {
                _this.updater.db.addMapping(response.mapping);
                _this.updater.disabled = true;
                _this.updater.db.executeChanges(response.changes);
                _this.updater.disabled = false;
              }
              _this.updater.lastUpdated = response.time;
              if (response.commands) {
                try {
                  _this.updater.commandExecuter.executeCommands(response.commands);
                } catch (error) {
                  e = error;
                }
              }
              console.debug('done');
              _this.updater.errorState.set(false);
            }
            if (args != null) {
              args.success(response);
            }
            return _this.updater.resetUpdateTimer();
          };
        })(this),
        error: (function(_this) {
          return function(response) {
            if (args != null) {
              args.fail(response);
            }
            return _this.updater.resetUpdateTimer(10000);
          };
        })(this)
      });
    };

    HttpTransport.prototype.hasChanges = function() {
      return this.updater.resetUpdateTimer();
    };

    return HttpTransport;

  })(UpdaterTransport);
  return Updater = (function() {
    Updater.prototype.test = function(data) {
      var fieldName, globalId, id, localId, localRecord, record, records, ref, ref1, ref2, ref3, ref4, remoteValue, results, table, tableName, value, values;
      for (tableName in data) {
        records = data[tableName];
        for (id in records) {
          record = records[id];
          localId = (ref = (ref1 = this.db.globalToLocalMapping) != null ? (ref2 = ref1[tableName]) != null ? ref2[id] : void 0 : void 0) != null ? ref : id;
          values = this.db.tables[tableName]._recordsByRid[localId]._values;
          if (values) {
            localRecord = this.prepare(tableName, values);
            for (fieldName in localRecord) {
              value = localRecord[fieldName];
              if (fieldName === 'more' || fieldName === 'offers' || fieldName === 'timestamp') {
                continue;
              }
              if (indexOf.call((ref3 = this.db.tables[tableName].schema.local) != null ? ref3 : [], fieldName) >= 0) {
                continue;
              }
              if (value != record[fieldName]) {
                console.debug(tableName + " " + localId + "|" + id + " " + fieldName + " `" + value + "` `" + record[fieldName] + "`");
              }
            }
          } else {
            console.debug(tableName + " " + localId + "|" + id + " " + fieldName);
          }
        }
      }
      ref4 = this.db.tables;
      results = [];
      for (tableName in ref4) {
        table = ref4[tableName];
        results.push((function() {
          var ref5, results1;
          ref5 = table._recordsByRid;
          results1 = [];
          for (id in ref5) {
            record = ref5[id]._values;
            globalId = this.convertId(tableName, id);
            localRecord = this.prepare(tableName, record);
            results1.push((function() {
              var results2;
              results2 = [];
              for (fieldName in localRecord) {
                value = localRecord[fieldName];
                if (!data[tableName][globalId]) {

                } else {
                  remoteValue = response.allData[tableName][globalId][fieldName];
                  if (remoteValue != value) {
                    results2.push(console.debug(tableName + " " + globalId + "|" + id + " " + fieldName + " " + value + " " + remoteValue));
                  } else {
                    results2.push(void 0);
                  }
                }
              }
              return results2;
            })());
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    function Updater(background, db, userIdValue, errorState) {
      var ref;
      this.background = background;
      this.db = db;
      this.userIdValue = userIdValue;
      this.errorState = errorState;
      this.tables = {};
      this.userId = (ref = this.userIdValue.get()) != null ? ref : 0;
      this.updateInterval = 2000;
      this.autoUpdate = true;
      this.history = {};
      this.changes = false;
      this.userIdCookieValue = null;
      this.status = new ObservableValue;
      this.message = new ObservableValue;
      this.transport = new WebSocketTransport(this);
      this.commandExecuter = new CommandExecuter(this.background);
    }

    Updater.prototype.cookiePolling = function() {
      var cookieUrl;
      cookieUrl = env.cookieDomain ? "http://" + env.cookieDomain : this.background.apiRoot;
      return this.background.getCookie(cookieUrl, 'userId', (function(_this) {
        return function(cookie) {
          _this.userIdCookieValue = cookie != null ? cookie.value : void 0;
          return _this.background.setInterval((function() {
            return _this.background.getCookie(cookieUrl, 'userId', function(cookie) {
              if ((cookie != null ? cookie.value : void 0) !== _this.userIdCookieValue) {
                _this.userIdCookieValue = cookie != null ? cookie.value : void 0;
                return _this.transport.userChanged();
              }
            });
          }), 1000);
        };
      })(this));
    };

    Updater.prototype.init = function(cb) {
      return this.transport.init((function(_this) {
        return function() {
          var args;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          _this.cookiePolling();
          return cb.apply(null, args);
        };
      })(this));
    };

    Updater.prototype.isDisabled = function() {
      return this.disabled || !this.userId;
    };

    Updater.prototype.setUser = function(userId) {
      if (userId !== this.userId) {
        console.debug('new user', this.userId, userId);
        this.db.localToGlobalMapping = {};
        this.db.globalToLocalMapping = {};
        this.disabled = true;
        this.db.clear();
        this.disabled = false;
        this.background.userId = this.userId = userId;
        return this.userIdValue.set(this.userId);
      }
    };

    Updater.prototype.isLocalId = function(id) {
      return (id + '')[0] !== 'G';
    };

    Updater.prototype.hasGlobalId = function(table, id) {
      var ref, ref1;
      if (this.isLocalId(id)) {
        return ((ref = this.db.localToGlobalMapping) != null ? (ref1 = ref[table]) != null ? ref1[id] : void 0 : void 0) != null;
      } else {
        return true;
      }
    };

    Updater.prototype.convertId = function(table, id) {
      var ref, ref1, ref2;
      if (this.isLocalId(id)) {
        return (ref = (ref1 = this.db.localToGlobalMapping) != null ? (ref2 = ref1[table]) != null ? ref2[id] : void 0 : void 0) != null ? ref : id;
      } else {
        return id;
      }
    };

    Updater.prototype.prepare = function(table, record) {
      var field, ref, ref1, referentTable, value, values;
      values = {};
      for (field in record) {
        value = record[field];
        if (referentTable = (ref = this.db.tables[table].schema) != null ? (ref1 = ref.referents) != null ? ref1[field] : void 0 : void 0) {
          if (_.isFunction(referentTable)) {
            referentTable = referentTable(record);
          }
          value = this.convertId(referentTable, value);
        }
        if (value instanceof Date) {
          value = '0000-00-00 00:00:00';
        } else if (_.isPlainObject(value)) {
          value = JSON.stringify(value);
        }
        values[field] = value;
      }
      return values;
    };

    Updater.prototype.forceUpdate = function() {
      this.background.clearTimeout(this.timerId);
      return this.update();
    };

    Updater.prototype.compileChanges = function() {
      var count, data, hasData, id, record, records, ref, table, values;
      data = {};
      count = 0;
      hasData = false;
      ref = this.tables;
      for (table in ref) {
        records = ref[table];
        for (id in records) {
          record = records[id];
          if (data[table] == null) {
            data[table] = {};
          }
          values = {};
          if (record !== 'deleted') {
            values = this.prepare(table, record);
          } else {
            values = 'deleted';
          }
          hasData = true;
          if (table === 'products' && !(values.siteName || values.productSid) && !this.hasGlobalId(table, id)) {
            throw new Error("BAD");
          }
          ++count;
          data[table][this.convertId(table, id)] = values;
        }
      }
      return data;
    };

    Updater.prototype.update = function(cb) {
      var data, ref;
      data = this.compileChanges();
      console.debug('updating...');
      this.updating = true;
      this.transport.sendUpdate({
        data: {
          lastTime: (ref = this.lastUpdated) != null ? ref : '',
          userId: this.userId,
          clientId: this.clientId,
          changes: JSON.stringify(data),
          extVersion: this.background.version,
          apiVersion: this.background.apiVersion,
          instanceId: this.background.instanceId,
          debug: env.dev,
          schema: this.db.schema
        },
        success: (function(_this) {
          return function(response) {
            _this.updating = false;
            return typeof cb === "function" ? cb(response) : void 0;
          };
        })(this),
        fail: (function(_this) {
          return function() {
            _this.updating = false;
            _this.mergePrevTablesWithTables();
            console.debug('done with error');
            return _this.errorState.set(true);
          };
        })(this)
      });
      this.changes = false;
      return this.clearStorage();
    };

    Updater.prototype.clearChanges = function() {
      this.prevTables = this.tables;
      this.tables = {};
      return this.changes = false;
    };

    Updater.prototype.clearStorage = function() {
      return this.background.removeStorage(['updaterChanges', 'localToGlobalMapping', 'globalToLocalMapping']);
    };

    Updater.prototype.mergePrevTablesWithTables = function() {
      var base, base1, field, id, name, record, records, ref, value;
      ref = this.prevTables;
      for (name in ref) {
        records = ref[name];
        if ((base = this.tables)[name] == null) {
          base[name] = {};
        }
        for (id in records) {
          record = records[id];
          if (record === 'deleted') {
            this.tables[name][id] = 'deleted';
          } else if (this.tables[name][id] !== 'deleted') {
            if ((base1 = this.tables[name])[id] == null) {
              base1[id] = {};
            }
            for (field in record) {
              value = record[field];
              if (!(field in this.tables[name][id])) {
                this.tables[name][id][field] = value;
              }
            }
          }
        }
      }
      this.prevTables = {};
      return this.saveTables();
    };

    Updater.prototype.resetUpdateTimer = function(duration) {
      if (duration == null) {
        duration = this.updateInterval;
      }
      if (this.autoUpdate && !this.updating) {
        this.background.clearTimeout(this.timerId);
        return this.timerId = this.background.setTimeout(((function(_this) {
          return function() {
            return _this.update();
          };
        })(this)), duration);
      }
    };

    Updater.prototype.saveTables = function() {};

    Updater.prototype.addUpdate = function(record, field) {
      var base, base1, base2, base3, name1, name2, name3, name4;
      if (this.isDisabled() || record.table.schema.local && indexOf.call(record.table.schema.local, field) >= 0) {
        return;
      }
      if ((base = this.history)[name1 = record.table.name] == null) {
        base[name1] = {};
      }
      if ((base1 = this.history[record.table.name])[name2 = record.id] == null) {
        base1[name2] = [];
      }
      this.history[record.table.name][record.id].push({
        type: 'update',
        field: field
      });
      if ((base2 = this.tables)[name3 = record.table.name] == null) {
        base2[name3] = {};
      }
      if ((base3 = this.tables[record.table.name])[name4 = record.id] == null) {
        base3[name4] = {};
      }
      this.tables[record.table.name][record.id][field] = record.get(field);
      this.changes = true;
      this.transport.hasChanges();
      return this.saveTables();
    };

    Updater.prototype.addInsertion = function(record) {
      var base, base1, base2, name, name1, name2, name3, ref, value, values;
      if (this.isDisabled()) {
        return;
      }
      if ((base = this.history)[name1 = record.table.name] == null) {
        base[name1] = {};
      }
      if ((base1 = this.history[record.table.name])[name2 = record.id] == null) {
        base1[name2] = [];
      }
      this.history[record.table.name][record.id].push({
        type: 'insert'
      });
      if ((base2 = this.tables)[name3 = record.table.name] == null) {
        base2[name3] = {};
      }
      values = null;
      if (record.table.schema.local) {
        values = {};
        ref = record._values;
        for (name in ref) {
          value = ref[name];
          if (indexOf.call(record.table.schema.local, name) < 0) {
            values[name] = value;
          }
        }
      } else {
        values = _.clone(record._values);
      }
      this.tables[record.table.name][record.id] = values;
      this.changes = true;
      this.transport.hasChanges();
      return this.saveTables();
    };

    Updater.prototype.addDeletion = function(record) {
      var base, base1, base2, name1, name2, name3;
      if (this.isDisabled()) {
        return;
      }
      if ((base = this.history)[name1 = record.table.name] == null) {
        base[name1] = {};
      }
      if ((base1 = this.history[record.table.name])[name2 = record.id] == null) {
        base1[name2] = [];
      }
      this.history[record.table.name][record.id].push({
        type: 'delete'
      });
      if (record.hasGlobal()) {
        if ((base2 = this.tables)[name3 = record.table.name] == null) {
          base2[name3] = {};
        }
        this.tables[record.table.name][record.id] = 'deleted';
      } else {
        if (this.tables[record.table.name]) {
          delete this.tables[record.table.name][record.id];
        }
      }
      this.changes = true;
      this.transport.hasChanges();
      return this.saveTables();
    };

    Updater.prototype.reset = function() {
      agora.reset();
      this.disabled = true;
      this.db.clear();
      return this.disabled = false;
    };

    return Updater;

  })();
});

//# sourceMappingURL=Updater.js.map
