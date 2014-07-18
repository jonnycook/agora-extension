// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View', 'Site', 'Formatter', 'util', 'underscore', 'views/items/DecisionItem', 'taxonomy'], function(View, Site, Formatter, util, _, DecisionItem, taxonomy) {
  var DecisionBarItem;
  return DecisionBarItem = (function(_super) {
    __extends(DecisionBarItem, _super);

    function DecisionBarItem() {
      return DecisionBarItem.__super__.constructor.apply(this, arguments);
    }

    DecisionBarItem.prototype.onClick = function() {
      return util.shoppingBar.pushDecisionState(this.obj);
    };

    return DecisionBarItem;

  })(DecisionItem);
});

//# sourceMappingURL=DecisionBarItem.map
