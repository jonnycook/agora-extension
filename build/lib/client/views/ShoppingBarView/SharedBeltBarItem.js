// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['views/ShoppingBarView/BarItem', 'views/ProductPopupView', 'util', 'Frame'],
    c: function() {
      var SharedBeltBarItem;
      return SharedBeltBarItem = (function(superClass) {
        extend(SharedBeltBarItem, superClass);

        function SharedBeltBarItem() {
          return SharedBeltBarItem.__super__.constructor.apply(this, arguments);
        }

        SharedBeltBarItem.prototype.html = '<span class="preview mosaic"><span class="image" /></span><span class="shareIndicator" />';

        SharedBeltBarItem.prototype.width = function() {
          return 48;
        };

        SharedBeltBarItem.prototype.init = function() {
          SharedBeltBarItem.__super__.init.apply(this, arguments);
          this.el.click((function(_this) {
            return function() {
              return _this.callBackgroundMethod('click');
            };
          })(this));
          return this.el.addClass('shared');
        };

        SharedBeltBarItem.prototype.destruct = function() {
          SharedBeltBarItem.__super__.destruct.apply(this, arguments);
          return this.el.removeClass('shared');
        };

        SharedBeltBarItem.prototype.onData = function(data1, barItemData) {
          var popup;
          this.data = data1;
          util.initMosaic(this.view, this.el.find('.preview'), '.image', data.preview);
          if (barItemData.user) {
            this.el.find('.shareIndicator').css({
              'backgroundColor': barItemData.user.color
            });
          }
          return popup = util.popupTrigger2(this.el.find('.shareIndicator'), {
            delay: 300,
            createPopup: (function(_this) {
              return function(cb, close, addEl) {
                var collaborateView, frame;
                if (window.suppressPopups) {
                  return false;
                }
                collaborateView = _this.view.createView('Collaborate');
                _this.view.shoppingBarView.propOpen(collaborateView);
                collaborateView.addExtension = function(el) {
                  return addEl(el);
                };
                collaborateView.removeExtension = function(el) {};
                frame = Frame.frameAbove(_this.el.find('.shareIndicator'), collaborateView.el, {
                  type: 'balloon',
                  distance: 20,
                  onClose: function() {
                    collaborateView.destruct();
                    return collaborateView = null;
                  }
                });
                collaborateView.close = close;
                collaborateView.sizeChanged = function() {
                  return frame.update();
                };
                collaborateView.addEl = addEl;
                collaborateView.shown();
                collaborateView.represent(_this.view.args);
                return cb(frame.el, null);
              };
            })(this),
            onClose: function(el) {
              var ref;
              return (ref = el.data('frame')) != null ? typeof ref.close === "function" ? ref.close() : void 0 : void 0;
            }
          });
        };

        return SharedBeltBarItem;

      })(BarItem);
    }
  };
});

//# sourceMappingURL=SharedBeltBarItem.js.map
