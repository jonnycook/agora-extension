// Generated by CoffeeScript 1.10.0
define(['underscore', 'Debug'], function(_, Debug) {
  var ObservableObject;
  return ObservableObject = (function() {
    function ObservableObject() {}

    ObservableObject.prototype.clearObservers = function() {
      this.observers = [];
      return this.tags = [];
    };

    ObservableObject.prototype.observeWithTag = function(tag, observer) {
      return this.observe(observer, tag);
    };

    ObservableObject.prototype.observe = function(observer, tag) {
      var observers;
      if (tag == null) {
        tag = null;
      }
      if (!observer) {
        throw new Error('bad!');
      }
      observers = this.observers;
      if (!observers) {
        this.observers = observers = [];
        this.tags = [];
      }
      observers.push(observer);
      return this.tags.push({
        tag: tag
      });
    };

    ObservableObject.radioSilence = function(block) {
      this._radioSilence = true;
      block();
      return this._radioSilence = false;
    };

    ObservableObject.pause = function() {
      this.paused = true;
      return this.queue = [];
    };

    ObservableObject.resume = function() {
      var i, len, obj, observable, observers, ref, ref1;
      this.paused = false;
      ref = this.queue;
      for (i = 0, len = ref.length; i < len; i++) {
        ref1 = ref[i], observable = ref1.observable, observers = ref1.observers, obj = ref1.obj;
        this._call(observable, observers, obj);
      }
      return delete this.queue;
    };

    ObservableObject._call = function(observable, observers, obj) {
      var i, len, observer, results;
      results = [];
      for (i = 0, len = observers.length; i < len; i++) {
        observer = observers[i];
        results.push(observer(obj));
      }
      return results;
    };

    ObservableObject.prototype.stopObservingWithTag = function(tag) {
      var index;
      if (this.observers) {
        index = this.tags.indexOf(tag);
        if (index !== -1) {
          this.observers.splice(index, 1);
          return this.tags.splice(index, 1);
        }
      }
    };

    ObservableObject.prototype.stopObserving = function(observer) {
      var index;
      if (this.observers) {
        index = this.observers.indexOf(observer);
        if (index !== -1) {
          this.observers.splice(index, 1);
          return this.tags.splice(index, 1);
        }
      }
    };

    ObservableObject.prototype._callObservers = function(obj) {
      if (this.observers) {
        if (ObservableObject.paused) {
          return ObservableObject.queue.push({
            observable: this,
            observers: _.clone(this.observers),
            obj: obj
          });
        } else {
          return ObservableObject._call(this, _.clone(this.observers), obj);
        }
      }
    };

    ObservableObject.prototype._fireMutation = function(type, mutationInfo) {
      if (!ObservableObject._radioSilence) {
        return this._callObservers(_.extend({
          type: type
        }, mutationInfo));
      }
    };

    ObservableObject.prototype.clear = function() {
      return this.clearObservers();
    };

    return ObservableObject;

  })();
});

//# sourceMappingURL=ObservableObject.js.map
