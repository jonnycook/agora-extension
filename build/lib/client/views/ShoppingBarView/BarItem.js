// Generated by CoffeeScript 1.10.0
define(function() {
  return {
    d: ['util'],
    c: function() {
      var BarItem;
      return BarItem = (function() {
        function BarItem(view, args1) {
          this.view = view;
          this.args = args1 != null ? args1 : {};
          this.el = this.view.el;
          this.elementType = this.view.elementType;
        }

        BarItem.prototype.supportsCreateBundle = function() {
          return true;
        };

        BarItem.prototype.callBackgroundMethod = function(name, args) {
          return this.view.callBackgroundMethod(name, args);
        };

        BarItem.prototype.observeObject = function(obj, observer) {
          return this.view.view.observeObject(obj, observer);
        };

        BarItem.prototype.widthChanged = function() {
          var base;
          return typeof (base = this.view.parent).childWidthChanged === "function" ? base.childWidthChanged(this.view) : void 0;
        };

        BarItem.prototype.width = function() {
          var width;
          width = 0;
          if (this.creatingBundle) {
            width += 58;
          }
          return width;
        };

        BarItem.prototype.init = function(data) {
          var draggingData, orgDraggingData, ref, ref1;
          this.el.html(this.html);
          this.el.addClass(this.elementType.toLowerCase());
          this.onData(data.barItemData, data);
          draggingData = null;
          if ('draggingData' in this.args) {
            if (this.args.draggingData) {
              draggingData = (ref = typeof this.draggingData === "function" ? this.draggingData() : void 0) != null ? ref : {};
              _.extend(draggingData, this.args.draggingData);
              util.initDragging(this.el, draggingData);
            }
          } else {
            draggingData = (ref1 = typeof this.draggingData === "function" ? this.draggingData() : void 0) != null ? ref1 : {};
          }
          orgDraggingData = _.clone(draggingData);
          _.extend(draggingData, {
            context: 'shoppingBar',
            type: this.elementType,
            start: (function(_this) {
              return function(e, opts) {
                _this.el.addClass('dragging');
                _this.view.shoppingBarView.startDrag();
                if (orgDraggingData.start) {
                  return orgDraggingData.start.apply(_this, arguments);
                }
              };
            })(this),
            stop: (function(_this) {
              return function() {
                _this.el.removeClass('dragging');
                _this.view.shoppingBarView.stopDrag();
                if (orgDraggingData.stop) {
                  return orgDraggingData.stop.apply(_this, arguments);
                }
              };
            })(this),
            onDroppedOn: (function(_this) {
              return function(el, fromEl, dropAction) {
                _this.view.shoppingBarView.onDroppedOn(el, fromEl, _this.el, dropAction);
                el.remove();
                if (orgDraggingData.onDroppedOn) {
                  return orgDraggingData.onDroppedOn.apply(_this, arguments);
                } else {
                  return false;
                }
              };
            })(this),
            onGlobal: (function(_this) {
              return function() {
                _this.view.noDestruct = true;
                return _this.view.separate();
              };
            })(this),
            onDropped: (function(_this) {
              return function(receivingEl) {
                delete _this.view.noDestruct;
                if (!receivingEl) {
                  _this.callBackgroundMethod('delete');
                  return _this.view.destruct();
                }
              };
            })(this),
            onDraggedOver: (function(_this) {
              return function(el) {
                if (el) {
                  _this.el.addClass('adding');
                  _this.el.removeClass('removing');
                } else {
                  _this.el.removeClass('adding');
                  _this.el.addClass('removing');
                }
                if (orgDraggingData.onDraggedOver) {
                  return orgDraggingData.onDraggedOver.apply(_this, arguments);
                }
              };
            })(this),
            onHoldOver: (function(_this) {
              return function(el) {
                if (el.data('dragging').action === 'addData') {
                  return;
                }
                if (_this.supportsCreateBundle()) {
                  if (!_this.creatingBundle) {
                    _this.el.addClass('createBundle');
                    _this.creatingBundle = true;
                    _this.el.append('<span class="bundleDrop addDrop" breaksimmutability="true" />');
                    _this.el.append('<span class="fakeGrip" />');
                    util.initDragging(_this.el.children('.bundleDrop'), {
                      enabled: false,
                      onDroppedOn: function(el, fromEl) {
                        _this.view.shoppingBarView.onDroppedOn(el, fromEl, _this.el, 'createBundle');
                        el.remove();
                        return false;
                      }
                    });
                    _this.widthChanged();
                  }
                }
                if (orgDraggingData.onHoldOver) {
                  return orgDraggingData.onHoldOver.apply(_this, arguments);
                }
              };
            })(this),
            onDragOut: (function(_this) {
              return function() {
                if (_this.creatingBundle) {
                  _this.el.removeClass('createBundle');
                  _this.el.children('.bundleDrop').remove();
                  _this.el.children('.fakeGrip').remove();
                  _this.creatingBundle = false;
                  _this.widthChanged();
                }
                if (orgDraggingData.onDragOut) {
                  return orgDraggingData.onDragOut.apply(_this, arguments);
                }
              };
            })(this)
          });
          return util.initDragging(this.el, draggingData);
        };

        BarItem.prototype.destruct = function() {
          this.el.unbind();
          this.el.removeClass(this.elementType.toLowerCase());
          this.el.html('');
          return util.terminateDragging(this.el);
        };

        BarItem.prototype.path = function() {
          return this.view.path();
        };

        return BarItem;

      })();
    }
  };
});

//# sourceMappingURL=BarItem.js.map
