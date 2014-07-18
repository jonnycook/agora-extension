// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['View', 'util', 'icons'],
    c: function() {
      var AddItemView;
      return AddItemView = (function(_super) {
        __extends(AddItemView, _super);

        AddItemView.prototype.type = 'AddItem';

        function AddItemView() {
          var type, _fn, _i, _len, _ref;
          AddItemView.__super__.constructor.apply(this, arguments);
          this.el = this.viewEl('<div class="v-addItem t-dialog"> <h2>Add something</h2> <div class="content"> <input type="text" class="filter" placeholder="Describe what you are looking for"> <div class="itemList"> <!--<span class="item" />--> </div> </div> </div>');
          _ref = ['decision', 'bundle', 'computer', 'session', 'list', 'descriptor'];
          _fn = (function(_this) {
            return function(type) {
              var el;
              el = $("<span class='-agora-newItem' />");
              icons.setIcon(el, type);
              util.tooltip(el, type, {
                position: 'below'
              });
              util.initDragging(el, {
                data: function(cb) {
                  return cb(type === 'descriptor' ? {
                    action: 'new',
                    type: type,
                    descriptor: _this.el.find('.filter').val()
                  } : {
                    action: 'new',
                    type: type
                  });
                },
                context: 'page',
                onDraggedOver: function(activeEl, helperEl) {
                  if (activeEl) {
                    return helperEl.addClass('adding');
                  } else {
                    return helperEl.removeClass('adding');
                  }
                },
                helper: function() {
                  return el.clone().addClass('-agora dragging');
                },
                start: function() {
                  return el.css({
                    opacity: .5
                  });
                },
                stop: function(event, ui) {
                  el.animate({
                    opacity: 1
                  });
                  ui.helper.detach();
                  return _this.close();
                }
              });
              return _this.el.find('.itemList').append(el);
            };
          })(this);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            type = _ref[_i];
            _fn(type);
          }
        }

        AddItemView.prototype.onData = function(data) {
          this.data = data;
        };

        return AddItemView;

      })(View);
    }
  };
});

//# sourceMappingURL=AddItemView.map