// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['views/ShoppingBarView/BarItem', 'util'],
    c: function() {
      var DecisionBarItem;
      return DecisionBarItem = (function(superClass) {
        extend(DecisionBarItem, superClass);

        function DecisionBarItem() {
          return DecisionBarItem.__super__.constructor.apply(this, arguments);
        }

        DecisionBarItem.prototype.html = '<span class="preview"><span class="image" /><span class="icon" /></span> <span class="count" /> <span class="popupTrigger" /> <span class="shareIndicator" />';

        DecisionBarItem.prototype.draggingData = function() {
          return {
            immutableContents: true,
            enabled: true
          };
        };

        DecisionBarItem.prototype.onData = function(data, barItemData) {
          var popup, updateForListSize;
          this.listItem = new ListBarItem(this.view, true);
          this.listItem.setup({
            state: 'expanded',
            contents: data.selection
          });
          this.view.withData(data.shared, (function(_this) {
            return function(shared) {
              if (shared) {
                return _this.el.addClass('shared');
              } else {
                return _this.el.removeClass('shared');
              }
            };
          })(this));
          util.initMosaic(this.view, this.el.find('.preview'), '.image', data.preview);
          (function(_this) {
            return (function() {
              var updateIcon;
              updateIcon = function() {
                var ref;
                return icons.setIcon(_this.el.find('.preview .icon'), (ref = data.icon.get()) != null ? ref : 'list', {
                  size: 'small',
                  itemClass: false
                });
              };
              data.icon.observe(function() {
                return updateIcon();
              });
              return updateIcon();
            });
          })(this)();
          updateForListSize = (function(_this) {
            return function() {
              if (data.listSize.get() === 0) {
                _this.el.addClass('emptyList');
              } else {
                _this.el.removeClass('emptyList');
              }
              return _this.el.find('.count').html(data.listSize.get());
            };
          })(this);
          data.listSize.observe(updateForListSize);
          updateForListSize();
          this.el.find('.count').click((function(_this) {
            return function(e) {
              _this.callBackgroundMethod('click');
              return e.stopPropagation();
            };
          })(this));
          util.decisionPreview({
            anchorEl: (function(_this) {
              return function() {
                if (data.selection.length()) {
                  return _this.el.find('.count');
                } else {
                  return _this.el.find('.popupTrigger');
                }
              };
            })(this),
            view: this.view,
            selection: data.selection,
            descriptor: data.descriptor,
            icon: data.icon,
            preview: data.preview,
            el: this.el
          });
          this.el.click((function(_this) {
            return function() {
              if (_this.el.hasClass('empty')) {
                return _this.callBackgroundMethod('click');
              }
            };
          })(this));
          this.el.find('.count .selection').html(data.selectionSize.get());
          data.selectionSize.observe((function(_this) {
            return function() {
              return _this.el.find('.count .selection').html(data.selectionSize.get());
            };
          })(this));
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
                tracking.page((_this.path()) + "/" + (collaborateView.pathElement()));
                collaborateView.addExtension = function(el) {
                  console.debug('addExtension', el);
                  return addEl(el);
                };
                collaborateView.removeExtension = function(el) {
                  return console.debug('removeExtension', el);
                };
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

        DecisionBarItem.prototype.updateLayout = function() {
          return this.listItem.updateLayout();
        };

        DecisionBarItem.prototype.width = function() {
          return DecisionBarItem.__super__.width.apply(this, arguments) + this.listItem.width();
        };

        DecisionBarItem.prototype.destruct = function() {
          DecisionBarItem.__super__.destruct.apply(this, arguments);
          return this.listItem.destruct();
        };

        return DecisionBarItem;

      })(BarItem);
    }
  };
});

//# sourceMappingURL=DecisionBarItem.js.map
