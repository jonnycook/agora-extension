// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'Site', 'Formatter', 'util', 'underscore', './ListBarItem'], function(View, Site, Formatter, util, _, ListBarItem) {
  var SessionBarItem;
  return SessionBarItem = (function(superClass) {
    extend(SessionBarItem, superClass);

    function SessionBarItem() {
      return SessionBarItem.__super__.constructor.apply(this, arguments);
    }

    SessionBarItem.prototype.type = 'Session';

    SessionBarItem.prototype.itemData = function() {
      return {
        title: this.itemView.clientValue(this.obj.field('title'))
      };
    };

    SessionBarItem.prototype.methods = {
      setTitle: function(view, title) {
        return this.obj.set('title', title);
      },
      toggle: function(view) {
        if (this.obj.get('collapsed')) {
          return this.obj.set('collapsed', false);
        } else {
          return this.obj.set('collapsed', true);
        }
      }
    };

    return SessionBarItem;

  })(ListBarItem);
});

//# sourceMappingURL=SessionBarItem.js.map
