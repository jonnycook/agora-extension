// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['View', 'util', 'icons'],
    c: function() {
      var SharedWithYouView;
      return SharedWithYouView = (function(superClass) {
        extend(SharedWithYouView, superClass);

        SharedWithYouView.prototype.type = 'SharedWithYou';

        function SharedWithYouView() {
          SharedWithYouView.__super__.constructor.apply(this, arguments);
          this.viewEl('<div class="v-sharedWithYou t-dialog"> <h2>Shared With You</h2> <div class="content"> <ul class="objects"> <li class="object"> <span class="title" /> <span class="user" /> <input type="checkbox" class="inBelt" /> </li> </ul> </div> </div>');
        }

        SharedWithYouView.prototype.onData = function(data) {
          this.listInterface(this.el.find('.objects'), '.object', (function(_this) {
            return function(el, data, pos, onRemove) {
              var view;
              view = _this.createView();
              onRemove(function() {
                return view.destruct();
              });
              el.addClass(data.type);
              el.find('.user').html(data.userName);
              view.valueInterface(el.find('.title')).setDataSource(data.title);
              el.click(function() {
                return _this.callBackgroundMethod('click', [data.id]);
              });
              util.tooltip(el.find('.inBelt'), 'show on belt');
              el.find('.inBelt').click(function(e) {
                return e.stopPropagation();
              }).change(function() {
                return _this.callBackgroundMethod('inBelt', [data.id, el.find('.inBelt').prop('checked')]);
              });
              view.withData(data.inBelt, function(inBelt) {
                return el.find('.inBelt').prop('checked', inBelt);
              });
              if (data.seen.get()) {
                el.addClass('seen');
              }
              return el;
            };
          })(this)).setDataSource(data.entries);
          return this.callBackgroundMethod('seen');
        };

        return SharedWithYouView;

      })(View);
    }
  };
});

//# sourceMappingURL=SharedWithYouView.js.map
