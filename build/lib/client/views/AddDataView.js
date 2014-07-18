// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['View', 'util', 'icons'],
    c: function() {
      var AddDataView;
      return AddDataView = (function(_super) {
        __extends(AddDataView, _super);

        AddDataView.prototype.type = 'AddData';

        function AddDataView(contentScript, opts) {
          var args, formEl, linkEl, selection, selectionText, setType, type, viewType;
          AddDataView.__super__.constructor.apply(this, arguments);
          viewType = opts.type;
          if (viewType === 'drag') {
            this.el = this.viewEl('<div class="v-addData t-dialog"> <h2>Clip</h2> <div class="content"> <form> <div class="field"> <select name="type"> <option>Content Type</option> <option value="image">Image</option> <option value="video">Video</option> <option value="url">Page</option> <option value="plainText">Text</option> <option value="richText">Rich Text</option> </select> </div> <div class="field"><input type="text" name="title" placeholder="Title"></div> <div class="field"><input type="text" name="url" placeholder="URL"></div> <div class="field"><input type="text" name="text" placeholder="Text"></div> <div class="field"><input type="text" name="comment" placeholder="Comment"></div> </form> <span class="t-item -agora-addData-link" /> </div> </div>');
          } else if (viewType === 'connected') {
            this.el = this.viewEl('<div class="v-addData t-dialog"> <div class="content"> <form> <div class="field"> <select name="type"> <option>Content Type</option> <option value="image">Image</option> <option value="video">Video</option> <option value="url">Page</option> <option value="plainText">Text</option> <option value="richText">Rich Text</option> </select> </div> <div class="field"><input type="text" name="title" placeholder="Title"></div> <div class="field"><input type="text" name="url" placeholder="URL"></div> <div class="field"><input type="text" name="text" placeholder="Text"></div> <div class="field"><input type="text" name="comment" placeholder="Comment"></div> <input type="submit"> </form> </div> </div>');
          }
          this.el.addClass(viewType);
          setType = (function(_this) {
            return function(type) {
              _this.el.find("select[name=type] option[value=" + type + "]").prop('selected', true);
              return _this.el.find('[name=type]').trigger('change');
            };
          })(this);
          this.values = {};
          this.set = (function(_this) {
            return function(prop, value) {
              _this.values[prop] = value;
              if (prop === 'type') {
                return setType(value);
              } else {
                return _this.el.find("input[name=" + prop + "]").val(value);
              }
            };
          })(this);
          if (opts.title) {
            this.set('title', opts.title);
          }
          type = null;
          if (opts.url.match(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/)) {
            this.set('url', opts.url);
          } else {
            type = 'plainText';
            this.set('text', opts.url);
          }
          if (viewType === 'drag') {
            if (!rangy.initialized) {
              rangy.init();
            }
            selection = rangy.getSelection();
            selectionText = selection.toString();
            if (selectionText !== '') {
              type = 'plainText';
              this.set('text', selectionText);
            }
          }
          if (!type) {
            if (opts.url.match(/(^https?:\/\/www\.youtube.com\/watch|^http:\/\/vimeo.com\/\d+)/)) {
              type = 'video';
            }
          }
          args = {
            object: opts.args
          };
          if (type) {
            this.set('type', type);
          }
          args.url = opts.url;
          this.represent(args);
          if (viewType === 'drag') {
            linkEl = this.el.find('.-agora-addData-link');
            formEl = this.el.find('form').get(0);
            util.tooltip(linkEl, 'drag to a product', {
              position: 'below'
            });
            util.initDragging(linkEl, {
              context: 'page',
              action: 'addData',
              breaksImmutability: true,
              data: function(cb) {
                return cb({
                  action: 'addData',
                  data: {
                    type: formEl.type.value,
                    title: formEl.title.value,
                    url: formEl.url.value,
                    text: formEl.text.value,
                    comment: formEl.comment.value
                  }
                });
              },
              helper: function(e, el) {
                return el.clone().addClass('-agora dragging');
              },
              onDraggedOver: function(activeEl, helperEl) {
                if (activeEl) {
                  return helperEl.addClass('adding');
                } else {
                  return helperEl.removeClass('adding');
                }
              },
              start: (function(_this) {
                return function() {
                  return linkEl.css({
                    opacity: .5
                  });
                };
              })(this),
              stop: (function(_this) {
                return function(event, ui) {
                  linkEl.animate({
                    opacity: 1
                  });
                  ui.helper.detach();
                  return _this.close();
                };
              })(this)
            });
          } else if (viewType === 'connected') {
            this.el.find('form').submit((function(_this) {
              return function() {
                _this.submit();
                return false;
              };
            })(this));
          }
          util.styleSelect(this.el.find('[name=type]'), {
            autoSize: false
          });
        }

        AddDataView.prototype.submit = function() {
          var formEl;
          formEl = this.el.find('form').get(0);
          this.callBackgroundMethod('add', {
            type: formEl.type.value,
            title: formEl.title.value,
            url: formEl.url.value,
            text: formEl.text.value,
            comment: formEl.comment.value
          });
          this.close();
          return typeof this.onSubmit === "function" ? this.onSubmit() : void 0;
        };

        AddDataView.prototype.onData = function(data) {
          if (data.title && !this.values.title) {
            this.set('title', data.title);
          }
          if (data.type && !this.values.type) {
            return this.set('type', data.type);
          }
        };

        return AddDataView;

      })(View);
    }
  };
});

//# sourceMappingURL=AddDataView.map