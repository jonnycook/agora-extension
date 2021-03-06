// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

define(function() {
  return function() {
    var ClientArray, ClientObject, ClientValue, Event, ListInterface, ValueInterface, View, deserialize;
    ClientObject = (function() {
      function ClientObject(args1) {
        var ref;
        this.args = args1;
        ref = this.args, this._id = ref._id, this.contentScript = ref.contentScript, this._name = ref._name, this.view = ref.view;
        this.listener = (function(_this) {
          return function(data) {
            var eventType, j, len, observer, ref1, results;
            data = _.clone(data);
            eventType = data.event;
            delete data.event;
            switch (eventType) {
              case 'mutation':
                if (typeof _this.onMutation === "function") {
                  _this.onMutation(data);
                }
                if (_this.observers) {
                  ref1 = _this.observers;
                  results = [];
                  for (j = 0, len = ref1.length; j < len; j++) {
                    observer = ref1[j];
                    results.push(observer(data));
                  }
                  return results;
                }
                break;
              case 'disconnection':
                return _this.clearObservers();
            }
          };
        })(this);
        this.contentScript.mapEvent("ClientObjectEvent:" + this._id, this._name);
        this.contentScript.listen("ClientObjectEvent:" + this._id, this.listener, this.args.view);
      }

      ClientObject.prototype.observe = function(cb, tag) {
        if (!cb) {
          throw new Error('Null observer');
        }
        if (this.observers == null) {
          this.observers = [];
        }
        this.observers.push(cb);
        if (this.tags == null) {
          this.tags = [];
        }
        return this.tags.push(tag);
      };

      ClientObject.prototype.stopObserving = function(observer) {
        var index;
        if (this.observers) {
          index = this.observers.indexOf(observer);
          if (index !== -1) {
            return this.observers.splice(index, 1);
          }
        }
      };

      ClientObject.prototype.clearObservers = function() {
        this.observers = null;
        return this.tags = null;
      };

      ClientObject.prototype.clearObjs = function(removeFromView) {
        var j, len, obj, ref;
        if (removeFromView == null) {
          removeFromView = true;
        }
        if (this.objs) {
          ref = this.objs;
          for (j = 0, len = ref.length; j < len; j++) {
            obj = ref[j];
            obj.destruct(removeFromView);
          }
          return delete this.objs;
        }
      };

      ClientObject.prototype.destruct = function(removeFromView) {
        if (removeFromView == null) {
          removeFromView = true;
        }
        this.clearObservers();
        if (removeFromView && this.view) {
          this.view.clientObjects.splice(this.view.clientObjects.indexOf(this), 1);
        }
        this.clearObjs(removeFromView);
        return this.contentScript.stopListening("ClientObjectEvent:" + this._id, this.listener, this);
      };

      ClientObject.prototype.setObjs = function(objs) {
        return this.objs = objs;
      };

      ClientObject.prototype.deserialize = function(data, objs) {
        if (this.view) {
          return this.view.deserialize(data, objs);
        } else {
          return deserialize(data, {
            ClientArray: ClientArray,
            ClientValue: ClientValue
          }, {
            contentScript: this.contentScript
          }, null, objs);
        }
      };

      return ClientObject;

    })();
    ClientArray = (function(superClass) {
      extend(ClientArray, superClass);

      ClientArray.prototype.__type = 'ClientArray';

      function ClientArray(args) {
        ClientArray.__super__.constructor.apply(this, arguments);
        this._array = args._array;
      }

      ClientArray.prototype.each = function(cb) {
        return _.each(this._array, cb);
      };

      ClientArray.prototype.forEach = function(cb) {
        return this.each(cb);
      };

      ClientArray.prototype.setArray = function(array) {
        return this._array = array;
      };

      ClientArray.prototype["delete"] = function(pos) {
        return this._array.splice(pos, 1);
      };

      ClientArray.prototype.insert = function(el, pos) {
        if (pos === 0) {
          return this._array.unshift(el);
        } else if (pos === this._array.length) {
          return this._array.push(el);
        } else {
          return this._array.splice(pos, 0, el);
        }
      };

      ClientArray.prototype.move = function(from, to) {
        var el;
        if (from !== to) {
          el = this._array.splice(from, 1)[0];
          return this._array.splice(to, 0, el);
        }
      };

      ClientArray.prototype._sync = function(obj) {
        return this.setArray(this.view.deserialize(obj._array));
      };

      ClientArray.prototype.onMutation = function(mutation) {
        switch (mutation.type) {
          case 'insertion':
            return this.insert(this.view.deserialize(mutation.value), mutation.position);
          case 'deletion':
            return this["delete"](mutation.position);
          case 'movement':
            return this.move(mutation.from, mutation.to);
          case 'setArray':
            return this.setArray(this.view.deserialize(mutation.array));
        }
      };

      ClientArray.prototype.get = function(i) {
        return this._array[i];
      };

      ClientArray.prototype.length = function() {
        return this._array.length;
      };

      return ClientArray;

    })(ClientObject);
    window.ClientValue = ClientValue = (function(superClass) {
      extend(ClientValue, superClass);

      ClientValue.prototype.__type = 'ClientValue';

      function ClientValue(args) {
        ClientValue.__super__.constructor.apply(this, arguments);
        this._scalar = args._scalar;
      }

      ClientValue.prototype._set = function(value) {
        this.clearObjs();
        this.objs = [];
        return this._scalar = this.deserialize(value, this.objs);
      };

      ClientValue.prototype._sync = function(obj) {
        return this._set(obj._scalar);
      };

      ClientValue.prototype.onMutation = function(mutation) {
        return this._set(mutation.value);
      };

      ClientValue.prototype.get = function() {
        return this._scalar;
      };

      return ClientValue;

    })(ClientObject);
    deserialize = function(obj, classMap, extraArgs, passThru, objs) {
      var className, classObj, i, item, j, len, name, theseObjs, value;
      if (_.isObject(obj)) {
        obj = _.clone(obj);
        if (_.isArray(obj)) {
          for (i = j = 0, len = obj.length; j < len; i = ++j) {
            item = obj[i];
            obj[i] = deserialize(item, classMap, extraArgs, passThru, objs);
          }
        } else {
          if (className = obj.__class__) {
            delete obj.__class__;
            if (classObj = classMap[className]) {
              theseObjs = [];
              obj = new classObj(_.extend(deserialize(obj, classMap, extraArgs, passThru, theseObjs), extraArgs));
              if (typeof obj.setObjs === "function") {
                obj.setObjs(theseObjs);
              }
              if (typeof passThru === "function") {
                passThru(obj);
              }
              if (objs != null) {
                objs.push(obj);
              }
            } else {
              throw new Error("no class " + className);
            }
          } else if (obj.constructor === Object) {
            for (name in obj) {
              value = obj[name];
              obj[name] = deserialize(value, classMap, extraArgs, passThru, objs);
            }
          }
        }
      }
      return obj;
    };
    ValueInterface = (function() {
      function ValueInterface(view1, el1, attr1) {
        this.view = view1;
        this.el = el1;
        this.attr = attr1 != null ? attr1 : null;
      }

      ValueInterface.prototype.setMapping = function(mapping1) {
        this.mapping = mapping1;
        return this;
      };

      ValueInterface.prototype.set = function(value1) {
        var v;
        this.value = value1;
        v = this.mapping ? this.mapping(this.value) : this.value;
        if (this.attr) {
          return this.el.attr(this.attr, v);
        } else {
          return this.el.html(v);
        }
      };

      ValueInterface.prototype.get = function() {
        return this.value;
      };

      ValueInterface.prototype.setDataSource = function(dataSource1, trigger) {
        this.dataSource = dataSource1;
        this.trigger = trigger;
        if (this._observer) {
          this.dataSource.stopObserving(this._observer);
        }
        this.set(this.dataSource.get());
        if (typeof this.trigger === "function") {
          this.trigger(this.dataSource.get(), this.el);
        }
        return this.dataSource.observe(this._observer = (function(_this) {
          return function(mutation) {
            _this.set(mutation.value);
            return typeof _this.trigger === "function" ? _this.trigger(mutation.value, _this.el) : void 0;
          };
        })(this));
      };

      ValueInterface.prototype.destruct = function() {
        if (this._observer) {
          return this.dataSource.stopObserving(this._observer);
        }
      };

      return ValueInterface;

    })();
    ListInterface = (function() {
      ListInterface.id = 1;

      ListInterface.prototype.setDataSource = function(dataSource) {
        var ref;
        if ((ref = this.dataSource) != null) {
          ref.stopObserving(this._observer);
        }
        this.dataSource = dataSource;
        this.set(dataSource);
        return dataSource.observe(this._observer = (function(_this) {
          return function(mutation) {
            switch (mutation.type) {
              case 'insertion':
                return _this.insert(_this.view.deserialize(mutation.value), mutation.position);
              case 'deletion':
                return _this["delete"](mutation.position);
              case 'movement':
                return _this.move(mutation.from, mutation.to);
              case 'setArray':
                return _this.set(_this.view.deserialize(mutation.array));
            }
          };
        })(this));
      };

      ListInterface.prototype.destruct = function() {
        var ref;
        return (ref = this.dataSource) != null ? ref.stopObserving(this._observer) : void 0;
      };

      function ListInterface(view1, el1, selector1, mapping1) {
        this.view = view1;
        this.el = el1;
        this.selector = selector1;
        this.mapping = mapping1;
        this.id = ListInterface.id++;
        this.template = $(this.el.find(this.selector).get(0));
        if (this.template.length === 0) {
          throw new Error('Failed to find template');
        }
        this.prevSibling = this.template.prev();
        this.nextSibling = this.template.next();
        this.parent = this.template.parent();
        if (this.parent.length === 0) {
          throw new Error("BAD");
        }
        this.els = [];
        this.deleteCbs = [];
      }

      ListInterface.prototype.get = function(position) {
        return this.els[position];
      };

      ListInterface.prototype.clear = function() {
        var cb, j, len, ref;
        this.el.find(this.selector).remove();
        this.els = [];
        ref = this.deleteCbs;
        for (j = 0, len = ref.length; j < len; j++) {
          cb = ref[j];
          if (typeof cb === "function") {
            cb();
          }
        }
        this.deleteCbs = [];
        return typeof this.onLengthChanged === "function" ? this.onLengthChanged() : void 0;
      };

      ListInterface.prototype.set = function(data) {
        this.clear();
        data.forEach((function(_this) {
          return function(item, i) {
            return _this.insert(item, i, false);
          };
        })(this));
        return typeof this.onMutation === "function" ? this.onMutation() : void 0;
      };

      ListInterface.prototype["delete"] = function(i) {
        var base, el;
        el = this.els[i];
        this.els.splice(i, 1);
        if (this.onDelete) {
          this.onDelete(el, function() {
            return el.remove();
          });
        } else {
          el.remove();
        }
        if (typeof (base = this.deleteCbs)[i] === "function") {
          base[i]();
        }
        this.deleteCbs.splice(i, 1);
        if (typeof this.onLengthChanged === "function") {
          this.onLengthChanged();
        }
        return typeof this.onMutation === "function" ? this.onMutation() : void 0;
      };

      ListInterface.prototype.insert = function(data, pos, signalMutation) {
        var el, next, setDeleteCb;
        if (signalMutation == null) {
          signalMutation = true;
        }
        setDeleteCb = (function(_this) {
          return function(cb) {
            return _this.deleteCbs.splice(pos, 0, cb);
          };
        })(this);
        el = this.mapping(this.template.clone(), data, pos, setDeleteCb);
        next = this.els[pos];
        if (next) {
          this.parent.get(0).insertBefore(el.get(0), next.get(0));
        } else {
          this.parent.get(0).insertBefore(el.get(0), this.nextSibling.get(0));
        }
        if (pos === 0) {
          this.els.unshift(el);
        } else if (pos === this.els.length) {
          this.els.push(el);
        } else {
          this.els.splice(pos, 0, el);
        }
        if (typeof this.onInsert === "function") {
          this.onInsert(el);
        }
        if (typeof this.onLengthChanged === "function") {
          this.onLengthChanged();
        }
        if (signalMutation) {
          return typeof this.onMutation === "function" ? this.onMutation() : void 0;
        }
      };

      ListInterface.prototype.push = function(data) {
        return this.insert(data, this.els.length);
      };

      ListInterface.prototype.move = function(from, to) {
        var el;
        el = this.els[from];
        if (from > to) {
          el.detach().insertBefore(this.els[to]);
        } else {
          el.detach().insertAfter(this.els[to]);
        }
        el = this.els.splice(from, 1)[0];
        this.els.splice(to, 0, el);
        el = this.deleteCbs.splice(from, 1)[0];
        this.deleteCbs.splice(to, 0, el);
        if (typeof this.onMove === "function") {
          this.onMove(from, to);
        }
        return typeof this.onMutation === "function" ? this.onMutation() : void 0;
      };

      ListInterface.prototype.length = function() {
        return this.els.length;
      };

      return ListInterface;

    })();
    Event = (function() {
      function Event() {
        this.subscribers = [];
      }

      Event.prototype.subscribe = function(subscriber) {
        return this.subscribers.push(subscriber);
      };

      Event.prototype.fire = function() {
        var args, j, len, ref, results, subscriber;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        ref = this.subscribers;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          subscriber = ref[j];
          results.push(subscriber.apply(null, args));
        }
        return results;
      };

      return Event;

    })();
    window.View_views = {};
    window.View_nextClientId = 1;
    return View = (function() {
      View.flexibleViews = {};

      View.clear = function() {
        var View_nextClientId, View_views, id, view;
        for (id in View_views) {
          view = View_views[id];
          view.destruct();
        }
        View_views = {};
        View_nextClientId = 1;
        return this.flexibleViews = {};
      };

      View.windowResized = function() {
        clearTimeout(this.resizeTimerId);
        return this.resizeTimerId = setTimeout(((function(_this) {
          return function() {
            var ref, results, view, viewId;
            ref = _this.flexibleViews;
            results = [];
            for (viewId in ref) {
              view = ref[viewId];
              results.push(typeof view.updateLayout === "function" ? view.updateLayout() : void 0);
            }
            return results;
          };
        })(this)), 50);
      };

      View.isClientValue = function(obj) {
        return obj.__type === 'ClientValue';
      };

      View.isClientArray = function(obj) {
        return obj.__type === 'ClientArray';
      };

      View.createView = function() {
        var args, className, view;
        className = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        view = null;
        if (className) {
          if (!className.match(/View$/)) {
            className += 'View';
          }
          eval("klass = " + className);
          if (args && args.length) {
            view = (function(func, args, ctor) {
              ctor.prototype = func.prototype;
              var child = new ctor, result = func.apply(child, args);
              return Object(result) === result ? result : child;
            })(klass, [contentScript].concat(slice.call(args)), function(){});
          } else {
            view = new klass(contentScript);
          }
        } else {
          view = new View(contentScript);
        }
        return view;
      };

      View.prototype.withData = function(data, cb) {
        if (data.get() != null) {
          cb(data.get());
        }
        return data.observe(function(mutation) {
          return cb(data.get(), mutation);
        });
      };

      function View() {
        var args, contentScript1;
        contentScript1 = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        this.contentScript = contentScript1;
        this.clientId = View_nextClientId++;
        this.clientObjects = [];
        this.observedObjects = [];
        this.views = [];
        this.interfaces = [];
        this.trackingViews = [];
        this.mouseEnteredCount = 0;
        this.prevMouseEnteredCount = 0;
        if (typeof this.init === "function") {
          this.init.apply(this, args);
        }
        if (this.flexibleLayout) {
          View.flexibleViews[this.clientId] = this;
        }
        if (!View.inited) {
          View.inited = true;
          $(window).resize(function() {
            return View.windowResized();
          });
        }
        this.events = {
          onDestruct: new Event,
          onAttached: new Event,
          onRepresent: new Event
        };
      }

      View.prototype.alsoRepresent = function(view) {
        if (this.representList == null) {
          this.representList = [];
        }
        return this.representList.push(view);
      };

      View.prototype.useEl = function(el) {
        this.el = el;
        el.data('view', this);
        el.mouseenter((function(_this) {
          return function() {
            return _this._mouseenter(true);
          };
        })(this));
        el.mouseleave((function(_this) {
          return function() {
            return _this._mouseleave(true);
          };
        })(this));
        return el;
      };

      View.prototype.viewEl = function(html) {
        var el;
        el = $(html);
        this.useEl(el);
        return el;
      };

      View.prototype.createView = function() {
        var args, className, view;
        className = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        view = View.createView.apply(View, [className].concat(slice.call(args)));
        this.views.push(view);
        view.parent = this;
        return view;
      };

      View.prototype.view = function() {
        return this.createView.apply(this, arguments);
      };

      View.prototype.syncWithValue = function(value, cb) {
        cb(value.get());
        return this.observe(value, function() {
          return cb(value.get());
        });
      };

      View.prototype.isAttached = function() {
        return typeof this.id !== 'undefined';
      };

      View.prototype.attach = function(cb) {
        if (!this.type) {
          throw new Error('No type!');
        }
        return this.contentScript.triggerBackgroundEvent('CreateView', {
          type: this.type
        }, (function(_this) {
          return function(response) {
            _this.id = response.id;
            _this.el.data('view', _this);
            if (_this.el) {
              _this.el.attr('agora:id', _this.id);
            }
            View_views[_this.id] = _this;
            _this.contentScript.listen("ViewMethod:" + _this.id, function(args) {
              return _this.callMethod(args.name, args.params);
            });
            if (cb) {
              cb();
            }
            return _this.events.onAttached.fire();
          };
        })(this));
      };

      View.prototype.detach = function() {
        this.clearClientObjects();
        this.contentScript.stopListening("ViewMethod:" + this.id);
        if (this.id != null) {
          return this.contentScript.triggerBackgroundEvent('DeleteView', {
            id: this.id
          });
        }
      };

      View.prototype.represent = function(args1, cb) {
        var j, len, ref, view;
        this.args = args1;
        if (this.isAttached()) {
          if (typeof this.onRepresent === "function") {
            this.onRepresent(this.args);
          }
          if (this.representList) {
            ref = this.representList;
            for (j = 0, len = ref.length; j < len; j++) {
              view = ref[j];
              view.represent(this.args);
            }
          }
          return this.contentScript.triggerBackgroundEvent('ConnectView', {
            id: this.id,
            args: this.args
          }, (function(_this) {
            return function(response) {
              var clientObject, ids, k, len1, map, ref1;
              if (response === false) {

              } else {
                _this.data = _this.deserialize(response.data);
                map = {};
                ids = [];
                ref1 = _this.clientObjects;
                for (k = 0, len1 = ref1.length; k < len1; k++) {
                  clientObject = ref1[k];
                  ids.push(clientObject._id);
                  map[clientObject._id] = clientObject;
                }
                return _this.contentScript.triggerBackgroundEvent('GetClientObjects', ids, function(response) {
                  var id, value;
                  for (id in response) {
                    value = response[id];
                    map[id]._sync(value);
                  }
                  if (typeof _this.onData === "function") {
                    _this.onData(_this.data);
                  }
                  if (typeof cb === "function") {
                    cb();
                  }
                  return _this.events.onRepresent.fire();
                });
              }
            };
          })(this));
        } else {
          return this.attach((function(_this) {
            return function() {
              return _this.represent(_this.args, cb);
            };
          })(this));
        }
      };

      View.prototype.deserialize = function(data, objs) {
        return deserialize(data, {
          ClientArray: ClientArray,
          ClientValue: ClientValue
        }, {
          contentScript: this.contentScript,
          view: this
        }, ((function(_this) {
          return function(obj) {
            return _this.clientObjects.push(obj);
          };
        })(this)), objs);
      };

      View.prototype.callBackgroundMethod = function(methodName, args, returnValueCb) {
        if (this.id) {
          return this.contentScript.triggerBackgroundEvent('CallViewBackgroundMethod', {
            view: this.type,
            id: this.id,
            methodName: methodName,
            args: args,
            timestamp: new Date().getTime()
          }, function(response) {
            return returnValueCb(response);
          });
        } else {
          throw new Error("not connected");
        }
      };

      View.prototype._addInterface = function(iface) {
        this.interfaces.push(iface);
        return iface;
      };

      View.prototype.listInterface = function(el, selector, mapping) {
        return this._addInterface(new ListInterface(this, el, selector, mapping));
      };

      View.prototype.valueInterface = function(el, attr) {
        if (attr == null) {
          attr = null;
        }
        return this._addInterface(new ValueInterface(this, el, attr));
      };

      View.prototype.callMethod = function(name, params) {
        var method;
        if (this.methods && (method = this.methods[name])) {
          return method.apply(this, params);
        }
      };

      View.prototype.observe = function(observable, observer) {
        this.observedObjects.push({
          object: observable,
          observer: observer
        });
        return observable.observe(observer, this);
      };

      View.prototype.observeObject = function(observable, observer) {
        return this.observe(observable, observer);
      };

      View.prototype.clearClientObjects = function() {
        var clientObject, j, len, ref;
        ref = this.clientObjects;
        for (j = 0, len = ref.length; j < len; j++) {
          clientObject = ref[j];
          clientObject.destruct(false);
        }
        return this.clientObjects = [];
      };

      View.prototype.clearInterfaces = function() {
        var iface, j, len, ref;
        ref = this.interfaces;
        for (j = 0, len = ref.length; j < len; j++) {
          iface = ref[j];
          iface.destruct();
        }
        return this.interfaces = [];
      };

      View.prototype.trackView = function(view) {
        if (view.trackingViews == null) {
          view.trackingViews = [];
        }
        view.trackingViews.push(this);
        if (this.trackedViews == null) {
          this.trackedViews = [];
        }
        return this.trackedViews.push(view);
      };

      View.prototype.clearViews = function() {
        var j, len, ref, view;
        ref = _.clone(this.views);
        for (j = 0, len = ref.length; j < len; j++) {
          view = ref[j];
          if (!view) {
            console.error('null view!', this);
          }
          if (view != null) {
            view.destruct(true, this);
          }
        }
        return this.views = [];
      };

      View.prototype.stopObservingObjects = function() {
        var j, len, object, observer, ref, ref1;
        ref = this.observedObjects;
        for (j = 0, len = ref.length; j < len; j++) {
          ref1 = ref[j], object = ref1.object, observer = ref1.observer;
          object.stopObserving(observer);
        }
        return this.observedObjects = [];
      };

      View.prototype.clear = function() {
        var j, len, ref, view;
        this.clearClientObjects();
        this.stopObservingObjects();
        this.clearViews();
        this.clearInterfaces();
        if (this.trackedViews) {
          ref = this.trackedViews;
          for (j = 0, len = ref.length; j < len; j++) {
            view = ref[j];
            view.destruct(true, this);
          }
        }
        return delete this.trackedViews;
      };

      View.prototype.pathElement = function() {
        var parts;
        parts = this.type.split('/');
        return parts[parts.length - 1];
      };

      View.prototype.path = function() {
        if (this.type) {
          if (this.basePath) {
            return this.basePath + "/" + (this.pathElement());
          } else if (this.parent) {
            return (this.parent.path()) + "/" + (this.pathElement());
          } else {
            return "/" + (this.pathElement());
          }
        } else if (this.parent) {
          return this.parent.path();
        } else {
          return '/';
        }
      };

      View.prototype.event = function(action, label) {
        var parts;
        if (label == null) {
          label = null;
        }
        parts = this.type.split('/');
        return tracking.event(parts[parts.length - 1], action, label);
      };

      View.prototype.separate = function() {
        var j, len, ref, view;
        _.pull(this.parent.views, this);
        if (this.trackingViews) {
          ref = this.trackingViews;
          for (j = 0, len = ref.length; j < len; j++) {
            view = ref[j];
            _.pull(view.trackedViews, this);
          }
        }
        return delete this.trackingViews;
      };

      View.prototype.destruct = function(removeFromParent, destructor) {
        if (removeFromParent == null) {
          removeFromParent = true;
        }
        if (destructor == null) {
          destructor = null;
        }
        if (this.noDestruct) {
          return;
        }
        if (this.mouseEntered) {
          this._mouseleave(true);
        }
        if (!this.destructed) {
          if (this.flexibleLayout) {
            delete View.flexibleViews[this.clientId];
          }
          this.detach();
          this.clear();
          if (this.parent && removeFromParent) {
            _.pull(this.parent.views, this);
          }
          this.destructed = true;
          return this.events.onDestruct.fire();
        }
      };

      View.prototype.shown = function() {};

      View.prototype._testMouseEntered = function() {
        clearTimeout(this._testMouseEnteredTimerId);
        return this._testMouseEnteredTimerId = setTimeout(((function(_this) {
          return function() {
            if (_this.mouseEnteredCount !== _this.prevMouseEnteredCount) {
              if (_this.mouseEnteredCount && !_this.prevMouseEnteredCount) {
                if (typeof _this.onMouseenter === "function") {
                  _this.onMouseenter();
                }
              } else if (!_this.mouseEnteredCount && _this.prevMouseEnteredCount) {
                if (typeof _this.onMouseleave === "function") {
                  _this.onMouseleave();
                }
              }
              return _this.prevMouseEnteredCount = _this.mouseEnteredCount;
            }
          };
        })(this)), 100);
      };

      View.prototype._mouseenter = function(self) {
        var ref;
        if (self == null) {
          self = false;
        }
        if (self) {
          if (this.mouseEntered) {
            return;
          }
          this.mouseEntered = true;
        }
        this.mouseEnteredCount++;
        if ((ref = this.parent) != null) {
          ref._mouseenter();
        }
        return this._testMouseEntered();
      };

      View.prototype._mouseleave = function(self) {
        var ref;
        if (self == null) {
          self = false;
        }
        if (self) {
          if (!this.mouseEntered) {
            return;
          }
          this.mouseEntered = false;
        }
        this.mouseEnteredCount--;
        if ((ref = this.parent) != null) {
          ref._mouseleave();
        }
        return this._testMouseEntered();
      };

      return View;

    })();
  };
});

//# sourceMappingURL=View.js.map
