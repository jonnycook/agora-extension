// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['views/ShoppingBarView/BarItem', 'views/ProductPopupView', 'util', 'Frame', 'icons'],
    c: function() {
      var PlaceholderBarItem;
      return PlaceholderBarItem = (function(_super) {
        __extends(PlaceholderBarItem, _super);

        function PlaceholderBarItem() {
          return PlaceholderBarItem.__super__.constructor.apply(this, arguments);
        }

        PlaceholderBarItem.prototype.width = function() {
          return PlaceholderBarItem.__super__.width.apply(this, arguments) + 48;
        };

        PlaceholderBarItem.prototype.onData = function(barItemData, data) {
          util.tooltip(this.el, data.descriptor.descriptor);
          this.widthChanged();
          return icons.setIcon(this.el, data.icon);
        };

        return PlaceholderBarItem;

      })(BarItem);
    }
  };
});

//# sourceMappingURL=PlaceholderBarItem.map