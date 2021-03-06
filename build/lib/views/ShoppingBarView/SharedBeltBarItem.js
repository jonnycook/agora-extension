// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], function(View, Site, Formatter, util, _, BarItem) {
  var SharedBeltBarItem;
  return SharedBeltBarItem = (function(superClass) {
    extend(SharedBeltBarItem, superClass);

    function SharedBeltBarItem() {
      return SharedBeltBarItem.__super__.constructor.apply(this, arguments);
    }

    SharedBeltBarItem.prototype.init = function() {
      var userId;
      userId = this.itemView.objectReference.get('object_user_id');
      this.user = this.itemView.agora.modelManager.getInstance('User', "G" + userId);
      return this.data = {
        type: 'SharedBelt',
        barItemData: {
          preview: util.listPreview(this.ctx, this.user.get('rootElements'))
        }
      };
    };

    SharedBeltBarItem.prototype.dropped = function(obj) {
      var rootEl;
      obj = util.resolveObject(obj);
      rootEl = this.itemView.agora.modelManager.getModel('RootElement').create({
        user_id: this.user.get('id'),
        element_type: obj.modelName,
        element_id: obj.get('id')
      });
      return _activity('add', this.user, obj);
    };

    SharedBeltBarItem.prototype.methods = {
      click: function() {
        return util.shoppingBar.pushRootState(this.user);
      }
    };

    return SharedBeltBarItem;

  })(BarItem);
});

//# sourceMappingURL=SharedBeltBarItem.js.map
