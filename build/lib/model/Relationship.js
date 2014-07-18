// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./ObservableObject'], function(ObservableObject) {
  var Relationship;
  return Relationship = (function(_super) {
    __extends(Relationship, _super);

    function Relationship() {
      return Relationship.__super__.constructor.apply(this, arguments);
    }

    Relationship.prototype.observeObject = function(object, observer) {
      var _observer;
      object.observe((_observer = (function(_this) {
        return function(mutation) {
          if (_this._instance.model.manager.relationshipsPaused) {
            return _this._instance.model.manager.mutations.push({
              observer: observer,
              mutation: mutation
            });
          } else {
            return observer(mutation);
          }
        };
      })(this)), this);
      if (this.observedObjects == null) {
        this.observedObjects = [];
      }
      return this.observedObjects.push({
        object: object,
        observer: _observer
      });
    };

    Relationship.prototype.stopObservingObjects = function() {
      var object, observer, _i, _len, _ref, _ref1;
      if (this.observedObjects) {
        _ref = this.observedObjects;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          _ref1 = _ref[_i], observer = _ref1.observer, object = _ref1.object;
          object.stopObserving(observer);
        }
        return delete this.observedObjects;
      }
    };

    Relationship.prototype.destruct = function() {
      this.stopObservingObjects();
      return typeof this.onDestruct === "function" ? this.onDestruct() : void 0;
    };

    return Relationship;

  })(ObservableObject);
});

//# sourceMappingURL=Relationship.map