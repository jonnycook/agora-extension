// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View', 'Site', 'Formatter', 'util', 'underscore'], function(View, Site, Formatter, util, _) {
  var CompetitiveProcessView;
  return CompetitiveProcessView = (function(_super) {
    __extends(CompetitiveProcessView, _super);

    function CompetitiveProcessView() {
      return CompetitiveProcessView.__super__.constructor.apply(this, arguments);
    }

    CompetitiveProcessView.id = function(args) {
      return args.decisionId;
    };

    CompetitiveProcessView.prototype.init = function() {
      var clientContents;
      this.obj = this.agora.modelManager.getInstance('Decision', this.args.decisionId);
      clientContents = this.ctx.clientArray(this.obj.get('competitiveList').get('elements'), (function(_this) {
        return function(el) {
          var element;
          element = _this.obj.get('elements').get(el);
          return {
            row: _this.clientValue(element.field('row')),
            barItem: {
              elementType: 'CompetitiveListElement',
              elementId: el.get('id'),
              decisionId: _this.obj.get('id')
            }
          };
        };
      })(this));
      return this.data = clientContents;
    };

    CompetitiveProcessView.prototype.methods = {
      setRow: function(view, itemViewId, row) {
        var element;
        element = this.agora.View.clientViews[itemViewId].view.element;
        return this.obj.get('elements')["for"](element).set('row', row);
      }
    };

    return CompetitiveProcessView;

  })(View);
});

//# sourceMappingURL=CompetitiveProcessView.map