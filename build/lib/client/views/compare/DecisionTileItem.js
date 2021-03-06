// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['views/compare/TileItem', 'util'],
    c: function() {
      var DecisionTileItem;
      return DecisionTileItem = (function(superClass) {
        extend(DecisionTileItem, superClass);

        function DecisionTileItem() {
          return DecisionTileItem.__super__.constructor.apply(this, arguments);
        }

        DecisionTileItem.prototype.draggingData = function() {
          return {
            immutableContents: true
          };
        };

        DecisionTileItem.prototype.onData = function(data, itemData) {
          var popup, updateIcon, updateTooltip;
          this.el.append('<span class="count"><!--<span class="selection" />/--><span class="list" /></span>');
          this.el.append("<span class='preview'><span class='image' /><span class='icon' /></span>");
          this.el.append('<span class="shareIndicator" />');
          this.view.withData(data.shared, (function(_this) {
            return function(shared) {
              if (shared) {
                return _this.el.addClass('shared');
              } else {
                return _this.el.removeClass('shared');
              }
            };
          })(this));
          updateIcon = (function(_this) {
            return function() {
              var ref;
              return icons.setIcon(_this.el, (ref = data.icon.get()) != null ? ref : 'list', {
                size: 'large'
              });
            };
          })(this);
          this.listItem = new ListTileItem(this.view, true);
          this.listItem.onEmpty = updateIcon;
          this.listItem.onNotEmpty = (function(_this) {
            return function() {
              return icons.clearIcon(_this.el);
            };
          })(this);
          updateIcon();
          data.icon.observe((function(_this) {
            return function() {
              if (_this.listItem.empty) {
                return updateIcon();
              }
            };
          })(this));
          this.listItem.setup({
            state: 'expanded',
            contents: data.selection
          });
          (function(_this) {
            return (function() {
              var classesForLength, contents, prevLength, updateForLength;
              contents = _this.view.listInterface(_this.el.find('.preview'), '.image', function(el, data, pos, onRemove) {
                return el.css('background-image', "url('" + data + "')");
              });
              contents.setDataSource(data.preview);
              prevLength = contents.length();
              classesForLength = {
                0: 'empty',
                1: 'oneItem',
                2: 'twoItems',
                3: 'threeItems',
                4: 'fourItems'
              };
              updateForLength = function() {
                _this.el.find('.preview').removeClass(classesForLength[prevLength]);
                return _this.el.find('.preview').addClass(classesForLength[prevLength = contents.length()]);
              };
              contents.onLengthChanged = updateForLength;
              return updateForLength();
            });
          })(this)();
          (function(_this) {
            return (function() {
              updateIcon = function() {
                var ref;
                return icons.setIcon(_this.el.find('.preview .icon'), (ref = data.icon.get()) != null ? ref : 'list', {
                  itemClass: false
                });
              };
              data.icon.observe(function() {
                return updateIcon();
              });
              return updateIcon();
            });
          })(this)();
          (function(_this) {
            return (function() {
              var updateForListSize;
              updateForListSize = function() {
                if (data.listSize.get() === 0) {
                  _this.el.addClass('emptyList');
                } else {
                  _this.el.removeClass('emptyList');
                }
                return _this.el.find('.count .list').html(data.listSize.get());
              };
              data.listSize.observe(updateForListSize);
              return updateForListSize();
            });
          })(this)();
          this.el.find('.count').click((function(_this) {
            return function(e) {
              tracking.event('Compare', 'openDecision');
              _this.callBackgroundMethod('click');
              return e.stopPropagation();
            };
          })(this));
          if (!this.view.compareView["public"]) {
            updateTooltip = (function(_this) {
              return function() {
                var ref, ref1, text;
                text = ((ref = data.descriptor.get()) != null ? ref.descriptor : void 0) ? (ref1 = data.descriptor.get()) != null ? ref1.descriptor : void 0 : '<i>Edit Decision</i>';
                return util.tooltip(_this.el.find('.count'), "<span class='descriptorTooltip'> <span class='preview'><span class='image' /></span> <div class='descriptorWrapper'><span class='icon' /> <span class='descriptor'>" + text + "</span><a class='edit' href='#' /></div> </span>", {
                  parentView: _this.view,
                  canFocus: true,
                  type: 'html',
                  frameType: 'balloon',
                  init: function(el, close, view) {
                    var classesForLength, contents, edit, prevLength, ref2, updateForLength;
                    icons.setIcon(el.find('.icon'), (ref2 = data.icon.get()) != null ? ref2 : 'list', {
                      size: 'small'
                    });
                    el.find('.icon').removeClass('t-item');
                    edit = function() {
                      var editDescriptorView, frame;
                      editDescriptorView = new EditDescriptorView(_this.view.contentScript);
                      tracking.page((_this.view.path()) + "/" + (editDescriptorView.pathElement()));
                      tracking.event('Compare', 'editDescriptor', 'item');
                      editDescriptorView.close = function() {
                        return frame.close();
                      };
                      editDescriptorView.represent(_this.view.data.get().id);
                      frame = Frame.frameAround(_this.el.find('.count'), editDescriptorView.el, {
                        type: 'balloon',
                        distance: 15,
                        close: function() {
                          return frame.close();
                        }
                      });
                      return false;
                    };
                    el.find('.edit').click(edit);
                    el.find('.preview').click(function() {
                      return _this.callBackgroundMethod('click');
                    });
                    el.find('.descriptor').click(edit);
                    contents = view.listInterface(el.find('.preview'), '.image', function(el, data, pos, onRemove) {
                      return el.css('background-image', "url('" + data + "')");
                    });
                    contents.setDataSource(data.preview);
                    prevLength = contents.length();
                    classesForLength = {
                      0: 'empty',
                      1: 'oneItem',
                      2: 'twoItems',
                      3: 'threeItems',
                      4: 'fourItems'
                    };
                    updateForLength = function() {
                      el.find('.preview').removeClass(classesForLength[prevLength]);
                      return el.find('.preview').addClass(classesForLength[prevLength = contents.length()]);
                    };
                    contents.onLengthChanged = updateForLength;
                    return updateForLength();
                  }
                });
              };
            })(this);
            data.descriptor.observe(updateTooltip);
            updateTooltip();
          }
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
          if (itemData.user) {
            this.el.find('.shareIndicator').css('backgroundColor', itemData.user.color);
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

        DecisionTileItem.prototype.updateTilesLayout = function(params, state) {
          var countEl, lastSegment;
          this.listItem.updateTilesLayout(params, state);
          lastSegment = this.listItem.segments[this.listItem.segments.length - 1];
          countEl = this.el.children('.count');
          return countEl.css({
            left: lastSegment.left + lastSegment.width - countEl.outerWidth(),
            top: lastSegment.top + lastSegment.height - countEl.outerHeight()
          });
        };

        DecisionTileItem.prototype.updateMasonryLayout = function() {
          return this.listItem.updateMasonryLayout();
        };

        DecisionTileItem.prototype.destruct = function() {
          DecisionTileItem.__super__.destruct.apply(this, arguments);
          return this.listItem.destruct();
        };

        return DecisionTileItem;

      })(TileItem);
    }
  };
});

//# sourceMappingURL=DecisionTileItem.js.map
