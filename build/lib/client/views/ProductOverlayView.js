// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['View', 'views/ProductPreviewView'],
    c: function() {
      var ProductOverlayView;
      return ProductOverlayView = (function(_super) {
        __extends(ProductOverlayView, _super);

        ProductOverlayView.prototype.type = 'ProductOverlay';

        ProductOverlayView.clear = function(el) {
          return el.parent().find('bdo.-agora.-agora-productBadge').remove();
        };

        function ProductOverlayView(contentScript, productData, imgEl, opts) {
          var attachEl, badgeEl, cancelHide, count, down, el, extraOverlayElements, frameEl, hide, hideTimer, hovering, i, initiateHide, offsetParentEl, parent, parents, popup, position, positionEl, positionStyle, productPreviewView, show, up, updatePosition, _i, _len;
          if (opts == null) {
            opts = {};
          }
          ProductOverlayView.__super__.constructor.apply(this, arguments);
          imgEl = $(imgEl);
          positionEl = attachEl = null;
          if (opts.positionEl && opts.attachEl) {
            positionEl = opts.positionEl;
            attachEl = opts.attachEl;
          } else {
            positionEl = imgEl;
            attachEl = imgEl.parent();
          }
          this.showPreview = true;
          hovering = opts.hovering, extraOverlayElements = opts.extra, position = opts.position;
          positionStyle = null;
          badgeEl = null;
          productPreviewView = null;
          frameEl = null;
          offsetParentEl = null;
          if (attachEl.css("position") !== "static" || attachEl.get(0) === document.body) {
            offsetParentEl = attachEl;
          } else {
            parents = attachEl.parents();
            i = 0;
            while (i < parents.length) {
              parent = $(parents.get(i));
              if (parent.css("position") !== "static" || parent.get(0) === document.body) {
                offsetParentEl = parent;
                break;
              }
              ++i;
            }
          }
          this.el = badgeEl = $('<bdo class="-agora -agora-productBadge" />');
          badgeEl.click((function(_this) {
            return function() {
              popup.close();
              popup.cancelOpen();
              frameEl = util.openProductPreview(productData, _this);
              tracking.page('/ProductOveray/ProductPortal');
              tracking.event('ProductOverlay', 'click');
              return false;
            };
          })(this));
          Q(attachEl).data('overlay', this);
          Q(attachEl).append(badgeEl);
          badgeEl.css({
            position: 'absolute'
          });
          this.updatePosition = updatePosition = (function(_this) {
            return function() {
              var left, margin, top;
              margin = positionEl.width() * .05;
              left = positionEl.offset().left - offsetParentEl.offset().left;
              top = positionEl.offset().top - offsetParentEl.offset().top;
              if (position === 'topRight') {
                badgeEl.css({
                  left: (left + positionEl.width()) - badgeEl.width() - margin,
                  top: top + margin
                });
              }
              if (position === 'topLeft') {
                return badgeEl.css({
                  left: left + margin,
                  top: top + margin
                });
              }
            };
          })(this);
          badgeEl.css({
            opacity: 0
          });
          updatePosition();
          this.test = (function(_this) {
            return function() {
              if (!badgeEl.parents('body').length) {
                _this.destruct();
                false;
              }
              return true;
            };
          })(this);
          this.showBadge = (function(_this) {
            return function() {
              if (!_this.test()) {
                return;
              }
              if (!_this.showing) {
                updatePosition();
                badgeEl.stop().css({
                  opacity: 0
                }).animate({
                  opacity: 1
                }, 200);
                return _this.showing = true;
              }
            };
          })(this);
          this.hideBadge = (function(_this) {
            return function() {
              if (!_this.test()) {
                return;
              }
              _this.showing = false;
              return badgeEl.stop().animate({
                opacity: 0
              }, 200, function() {});
            };
          })(this);
          count = 0;
          up = (function(_this) {
            return function() {
              if (!count) {
                show();
              }
              return ++count;
            };
          })(this);
          down = (function(_this) {
            return function() {
              if (count > 0) {
                --count;
                if (!count) {
                  return hide();
                }
              }
            };
          })(this);
          if (hovering) {
            count++;
          }
          if (hovering) {
            this.showBadge();
            this.active = true;
          }
          hideTimer = null;
          initiateHide = (function(_this) {
            return function() {
              clearTimeout(hideTimer);
              return hideTimer = setTimeout(hide, 10);
            };
          })(this);
          cancelHide = (function(_this) {
            return function() {
              return clearTimeout(hideTimer);
            };
          })(this);
          hide = (function(_this) {
            return function() {
              _this.active = false;
              if (!_this._alwaysShow) {
                return _this.hideBadge();
              }
            };
          })(this);
          show = (function(_this) {
            return function() {
              _this.showBadge();
              return _this.active = true;
            };
          })(this);
          Q(attachEl).mouseenter(up);
          Q(attachEl).mouseleave(down);
          this.onDestruct = function() {
            attachEl.unbind('mouseenter', up).unbind('mouseleave', down);
            this.el.remove();
            return attachEl.removeData('overlay');
          };
          if (extraOverlayElements) {
            for (_i = 0, _len = extraOverlayElements.length; _i < _len; _i++) {
              el = extraOverlayElements[_i];
              Q(el).mouseenter(up).mouseleave(down);
            }
          }
          popup = util.popupTrigger2(this.el, {
            delay: 500,
            createPopup: (function(_this) {
              return function(cb, close, addEl) {
                var productPopupView;
                if (!Agora.settings.showPreview.get() || !_this.showPreview) {
                  return false;
                }
                productPopupView = _this.createView('ProductPopupView', {
                  unconstrainedPictureHeight: true
                });
                productPopupView.represent(_this.args, function() {
                  var frame;
                  frame = Frame.frameAbove(_this.el, productPopupView.el, {
                    type: 'balloon',
                    position: (_this.el.offset().top - $(window).scrollTop() < ($(window).height()) / 3 ? 'below' : 'above'),
                    onClose: function() {
                      productPopupView.destruct();
                      return productPopupView = null;
                    }
                  });
                  productPopupView.close = close;
                  productPopupView.sizeChanged = function() {
                    return frame.update();
                  };
                  productPopupView.addEl = addEl;
                  frame.el.mouseenter(cancelHide);
                  up();
                  tracking.event('popup', 'appear', 'ProductPopup');
                  tracking.page("" + (_this.path()) + "/" + (productPopupView.pathElement()));
                  return cb(frame.el);
                });
                return null;
              };
            })(this),
            onClose: (function(_this) {
              return function(el, animate) {
                var _ref;
                if ((_ref = el.data('frame')) != null) {
                  if (typeof _ref.close === "function") {
                    _ref.close(animate);
                  }
                }
                return down();
              };
            })(this)
          });
        }

        ProductOverlayView.prototype.autoFixPosition = function() {
          return setInterval(((function(_this) {
            return function() {
              return _this.updatePosition();
            };
          })(this)), 1000);
        };

        ProductOverlayView.prototype.alwaysShow = function(alwaysShow) {
          if (alwaysShow !== this._alwaysShow) {
            this._alwaysShow = alwaysShow;
            if (alwaysShow) {
              if (!this.showing) {
                return this.showBadge();
              }
            } else {
              if (!this.active) {
                return this.hideBadge();
              }
            }
          }
        };

        ProductOverlayView.prototype.addAlwaysShow = function(reason) {
          if (this.alwaysShowReasons == null) {
            this.alwaysShowReasons = {};
          }
          this.alwaysShowReasons[reason] = true;
          if (_.keys(this.alwaysShowReasons).length) {
            return this.alwaysShow(true);
          }
        };

        ProductOverlayView.prototype.removeAlwaysShow = function(reason) {
          if (this.alwaysShowReasons == null) {
            this.alwaysShowReasons = {};
          }
          delete this.alwaysShowReasons[reason];
          if (!_.keys(this.alwaysShowReasons).length) {
            return this.alwaysShow(false);
          }
        };

        ProductOverlayView.prototype.onData = function(data) {
          var lastArgument, lastEmotion, onProp, updateForLastArgument, updateForLastFeeling;
          onProp = function(prop, func) {
            func(prop.get());
            return prop.observe(function(mutation) {
              return func(prop.get(), mutation);
            });
          };
          onProp(data.bagged, (function(_this) {
            return function(bagged) {
              if (bagged) {
                _this.el.addClass('added');
                return _this.addAlwaysShow('added');
              } else {
                _this.el.removeClass('added');
                return _this.removeAlwaysShow('added');
              }
            };
          })(this));
          onProp(data.status, (function(_this) {
            return function(status) {
              if (status === 2) {
                return _this.el.addClass('error');
              } else {
                return _this.el.removeClass('error');
              }
            };
          })(this));
          lastEmotion = null;
          updateForLastFeeling = (function(_this) {
            return function() {
              var emotionClass;
              if (lastEmotion) {
                _this.el.removeClass(lastEmotion);
              }
              if (data.lastFeeling.get()) {
                emotionClass = util.emotionClass(data.lastFeeling.get().positive, data.lastFeeling.get().negative);
                _this.el.addClass(emotionClass);
                lastEmotion = emotionClass;
                return _this.addAlwaysShow('emotion');
              } else {
                lastEmotion = null;
                return _this.removeAlwaysShow('emotion');
              }
            };
          })(this);
          data.lastFeeling.observe(updateForLastFeeling);
          updateForLastFeeling();
          lastArgument = null;
          updateForLastArgument = (function(_this) {
            return function() {
              var positionClass;
              if (lastArgument) {
                _this.el.removeClass(lastArgument);
              }
              if (data.lastArgument.get()) {
                positionClass = util.positionClass(data.lastArgument.get()["for"], data.lastArgument.get().against);
                _this.el.addClass(positionClass);
                lastArgument = positionClass;
                return _this.addAlwaysShow('argument');
              } else {
                lastArgument = null;
                return _this.removeAlwaysShow('argument');
              }
            };
          })(this);
          data.lastArgument.observe(updateForLastArgument);
          return updateForLastArgument();
        };

        ProductOverlayView.prototype.destruct = function() {
          ProductOverlayView.__super__.destruct.apply(this, arguments);
          return this.onDestruct();
        };

        return ProductOverlayView;

      })(View);
    }
  };
});

//# sourceMappingURL=ProductOverlayView.map
