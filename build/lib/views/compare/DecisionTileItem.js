// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View', 'Site', 'Formatter', 'util', 'underscore', 'views/items/DecisionItem', 'taxonomy'], function(View, Site, Formatter, util, _, DecisionItem, taxonomy) {
  var DecisionTileItem;
  return DecisionTileItem = (function(_super) {
    __extends(DecisionTileItem, _super);

    function DecisionTileItem() {
      return DecisionTileItem.__super__.constructor.apply(this, arguments);
    }

    DecisionTileItem.prototype.selectionObj = function(obj) {
      obj.compareViewId = this.view.compareView.id;
      return obj;
    };

    DecisionTileItem.prototype.onClick = function() {
      return this.view.compareView.pushState({
        dropped: (function(_this) {
          return function(element) {
            return _this.obj.get('list').get('contents').add(util.resolveObject(element));
          };
        })(this),
        ripped: (function(_this) {
          return function(view) {
            return view.element["delete"]();
          };
        })(this),
        contents: (function(_this) {
          return function() {
            return _this.obj.get('considering');
          };
        })(this),
        contentMap: (function(_this) {
          return function(el) {
            return {
              elementType: 'ListElement',
              elementId: el.get('id'),
              decisionId: _this.obj.get('id')
            };
          };
        })(this),
        state: 'Decision',
        args: {
          decisionId: this.obj.get('id')
        },
        breadcrumb: this.obj,
        obj: this.obj
      });
    };

    return DecisionTileItem;

  })(DecisionItem);
});

//# sourceMappingURL=DecisionTileItem.map
