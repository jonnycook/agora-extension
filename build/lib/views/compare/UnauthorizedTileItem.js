// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View', 'Site', 'Formatter', 'util', 'underscore', './TileItem'], function(View, Site, Formatter, util, _, TileItem) {
  var UnauthorizedTileItem;
  return UnauthorizedTileItem = (function(_super) {
    __extends(UnauthorizedTileItem, _super);

    function UnauthorizedTileItem() {
      return UnauthorizedTileItem.__super__.constructor.apply(this, arguments);
    }

    UnauthorizedTileItem.prototype.init = function() {
      return this.data = {
        type: 'Unauthorized',
        barItemData: {}
      };
    };

    return UnauthorizedTileItem;

  })(TileItem);
});

//# sourceMappingURL=UnauthorizedTileItem.map