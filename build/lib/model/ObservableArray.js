// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./ObservableObject', 'underscore'], function(ObservableObject, _) {
  var ObservableArray;
  return ObservableArray = (function(_super) {
    __extends(ObservableArray, _super);

    function ObservableArray(_array) {
      this._array = _array;
      if (this._array == null) {
        this._array = [];
      }
    }

    ObservableArray.prototype.get = function(index) {
      if (index < 0) {
        return this.get(index + this._array.length);
      } else {
        if (index >= this._array.length) {
          throw new Error("index out of bounds: " + index);
        }
        return this._array[index];
      }
    };

    ObservableArray.prototype.insert = function(position, value) {
      if (!value) {
        throw new Error('false value');
      }
      this._array.splice(position, 0, value);
      return this._fireMutation('insertion', {
        position: position,
        value: value,
        length: this._array.length
      });
    };

    ObservableArray.prototype["delete"] = function(position, tag) {
      var value;
      if (position >= this._array.length) {
        throw new Error("" + position + " out of range");
      }
      value = this._array[position];
      if (!value) {
        console.debug(this._array);
        throw new Error("" + position);
      }
      this._array.splice(position, 1);
      return this._fireMutation('deletion', {
        position: position,
        value: value,
        length: this._array.length,
        tag: tag
      });
    };

    ObservableArray.prototype.remove = function(el, tag) {
      var index;
      index = this.indexOf(el);
      if (index !== -1) {
        return this["delete"](index, tag);
      } else {
        return console.log(el, 'not in array', this);
      }
    };

    ObservableArray.prototype.deleteIf = function(predicate) {
      var deleteQueue, i, _i, _len, _results;
      deleteQueue = [];
      this.each((function(_this) {
        return function(value, i) {
          if (predicate(value)) {
            return deleteQueue.unshift(i);
          }
        };
      })(this));
      _results = [];
      for (_i = 0, _len = deleteQueue.length; _i < _len; _i++) {
        i = deleteQueue[_i];
        _results.push(this["delete"](i));
      }
      return _results;
    };

    ObservableArray.prototype.push = function(value) {
      return this.insert(this._array.length, value);
    };

    ObservableArray.prototype.unshift = function(value) {
      return this.insert(0, value);
    };

    ObservableArray.prototype.append = function(array) {
      var value, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        value = array[_i];
        _results.push(this.push(value));
      }
      return _results;
    };

    ObservableArray.prototype.each = function(iterator) {
      return _.each(this._array, iterator);
    };

    ObservableArray.prototype.indexOf = function(el, start) {
      return this._array.indexOf(el, start);
    };

    ObservableArray.prototype.contains = function(obj) {
      return this._array.indexOf(obj) !== -1;
    };

    ObservableArray.prototype.find = function(predicate) {
      var value, _i, _len, _ref;
      _ref = this._array;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        value = _ref[_i];
        if (predicate(value)) {
          return value;
        }
      }
    };

    ObservableArray.prototype.findAll = function(predicate) {
      var value, values, _i, _len, _ref;
      values = [];
      _ref = this._array;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        value = _ref[_i];
        if (predicate(value)) {
          values.push(value);
        }
      }
      return values;
    };

    ObservableArray.prototype.length = function() {
      return this._array.length;
    };

    ObservableArray.prototype.move = function(from, to) {
      var el;
      if (from !== to) {
        el = this._array.splice(from, 1)[0];
        if (!el) {
          throw new Error('poop');
        }
        this._array.splice(to, 0, el);
        return this._fireMutation('movement', {
          from: from,
          to: to
        });
      }
    };

    ObservableArray.prototype.sort = function(comp) {
      return this._array.sort(comp);
    };

    ObservableArray.prototype.clear = function() {
      ObservableArray.__super__.clear.apply(this, arguments);
      return this._array = [];
    };

    return ObservableArray;

  })(ObservableObject);
});

//# sourceMappingURL=ObservableArray.map
