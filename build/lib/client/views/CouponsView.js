// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['View', 'Frame'],
    c: function() {
      var CouponsView;
      return CouponsView = (function(_super) {
        __extends(CouponsView, _super);

        CouponsView.prototype.type = 'Coupons';

        function CouponsView(contentScript) {
          this.contentScript = contentScript;
          CouponsView.__super__.constructor.call(this, this.contentScript);
          this.el = $('<div class="-agora v-coupons"> <div class="cont"> Loading deals... </div> </div>');
          util.trapScrolling(this.el.find('.cont'));
        }

        CouponsView.prototype.onData = function(data) {
          var update;
          update = (function(_this) {
            return function() {
              var contEl, deal, _i, _len, _ref;
              contEl = _this.el.find('.cont');
              if (data.get()) {
                contEl.html('');
                _ref = data.get();
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  deal = _ref[_i];
                  contEl.append("<div class='deal'><a target='_blank' href='" + deal.href + "'>" + deal.offer_text + "</a></div>");
                }
              }
              return typeof _this.sizeChanged === "function" ? _this.sizeChanged() : void 0;
            };
          })(this);
          data.observe(update);
          return update();
        };

        return CouponsView;

      })(View);
    }
  };
});

//# sourceMappingURL=CouponsView.map
