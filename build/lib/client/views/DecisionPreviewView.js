// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['View', 'Frame', 'views/OffersView', 'views/DataView', 'views/AddFeelingView', 'views/AddArgumentView'],
    c: function() {
      var DecisionPreviewView;
      return DecisionPreviewView = (function(superClass) {
        extend(DecisionPreviewView, superClass);

        function DecisionPreviewView() {
          return DecisionPreviewView.__super__.constructor.apply(this, arguments);
        }

        DecisionPreviewView.prototype.type = 'DecisionPreview';

        DecisionPreviewView.prototype.init = function() {
          return this.viewEl('<span class="descriptorTooltip"> <span class="preview"><span class="image" /></span> <div class="descriptorWrapper"><span class="icon" /> <span class="descriptor" /><a class="edit" href="#" /></div> </span>');
        };

        DecisionPreviewView.prototype.onData = function(data) {
          var classesForLength, contents, edit, openCompareView, prevLength, ref, ref1, ref2, text, updateForLength;
          text = ((ref = data.descriptor.get()) != null ? ref.descriptor : void 0) ? (ref1 = data.descriptor.get()) != null ? ref1.descriptor : void 0 : '<i>Edit Decision</i>';
          this.el.find('.descriptorWrapper .descriptor').html(text);
          icons.setIcon(this.el.find('.icon'), (ref2 = data.icon.get()) != null ? ref2 : 'list', {
            size: 'small'
          });
          this.el.find('.icon').removeClass('t-item');
          util.tooltip(this.el.find('.edit'), 'edit');
          edit = (function(_this) {
            return function() {
              if (_this.editInModalDialog) {
                tracking.page((_this.path()) + "/EditDescriptor");
                return util.presentViewAsModalDialog('EditDescriptor', _this.args);
              } else {
                return _this.editEnv(function(el) {
                  var editDescriptorView, frame;
                  editDescriptorView = _this.createView('EditDescriptor');
                  editDescriptorView._mouseenter(true);
                  editDescriptorView.close = function() {
                    return frame.close();
                  };
                  editDescriptorView.represent({
                    decision: _this.args
                  });
                  frame = Frame.frameAround(el, editDescriptorView.el, {
                    type: 'balloon',
                    distance: 20,
                    close: function() {
                      frame.close();
                      return editDescriptorView.destruct();
                    }
                  });
                  return tracking.page((_this.path()) + "/" + (editDescriptorView.pathElement()));
                });
              }
            };
          })(this);
          this.el.find('.edit').click(function() {
            edit();
            return false;
          });
          this.el.find('.descriptor').click(function() {
            edit();
            return false;
          });
          openCompareView = (function(_this) {
            return function() {
              var compareTileView, frameEl;
              tracking.page((_this.path()) + "/Compare");
              compareTileView = new CompareView(_this.contentScript);
              compareTileView.shoppingBarView = shoppingBarView;
              frameEl = Frame.wrapInFrame(compareTileView.el, {
                type: 'fullscreen',
                scroll: true,
                resize: function(width, height) {
                  return [width - 100, height - 100];
                },
                close: function() {
                  return compareTileView.destruct();
                }
              });
              compareTileView.close = function() {
                return Frame.close(frameEl);
              };
              frameEl.appendTo(document.body);
              Frame.show(frameEl);
              compareTileView.setContEl(frameEl.data('client'));
              compareTileView.backEl = compareTileView.contEl;
              compareTileView.el.css({
                margin: '20px auto 0'
              });
              return compareTileView.represent(_this.args);
            };
          })(this);
          this.el.find('.preview').click(openCompareView);
          contents = this.listInterface(this.el.find('.preview'), '.image', (function(_this) {
            return function(el, data, pos, onRemove) {
              return el.css('background-image', "url('" + data + "')");
            };
          })(this));
          contents.setDataSource(data.preview);
          prevLength = contents.length();
          classesForLength = {
            0: 'empty',
            1: 'oneItem',
            2: 'twoItems',
            3: 'threeItems',
            4: 'fourItems'
          };
          updateForLength = (function(_this) {
            return function() {
              _this.el.find('.preview').removeClass(classesForLength[prevLength]);
              return _this.el.find('.preview').addClass(classesForLength[prevLength = contents.length()]);
            };
          })(this);
          contents.onLengthChanged = updateForLength;
          updateForLength();
          return typeof this.sizeChanged === "function" ? this.sizeChanged() : void 0;
        };

        return DecisionPreviewView;

      })(View);
    }
  };
});

//# sourceMappingURL=DecisionPreviewView.js.map
