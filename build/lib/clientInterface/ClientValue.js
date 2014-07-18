// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['./ClientObject'], function(ClientObject) {
  var ClientValue;
  return ClientValue = (function(_super) {
    __extends(ClientValue, _super);

    function ClientValue(agora, owner, _value) {
      this._value = _value;
      ClientValue.__super__.constructor.apply(this, arguments);
    }

    ClientValue.prototype.get = function() {
      return this._value;
    };

    ClientValue.prototype.set = function(value, timestamp) {
      if (timestamp == null) {
        timestamp = false;
      }
      if (typeof value === 'object' || value !== this._value || timestamp) {
        this._triggerMutationEvent('assignment', {
          oldValue: ClientObject.serialize(this._value),
          value: ClientObject.serialize(value),
          timestamp: timestamp
        });
        return this._value = value;
      }
    };

    ClientValue.prototype.trigger = function() {
      return this._triggerMutationEvent('assignment', {
        oldValue: ClientObject.serialize(this._value),
        value: ClientObject.serialize(this._value)
      });
    };

    ClientValue.prototype.serialize = function() {
      var obj;
      obj = ClientValue.__super__.serialize.apply(this, arguments);
      return _.extend(obj, {
        __class__: 'ClientValue',
        _scalar: ClientObject.serialize(this._value)
      });
    };

    return ClientValue;

  })(ClientObject);
});

//# sourceMappingURL=ClientValue.map