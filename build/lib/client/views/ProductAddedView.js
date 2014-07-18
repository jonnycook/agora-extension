// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['View', 'Frame'],
    c: function() {
      var ProductAddedView;
      return ProductAddedView = (function(_super) {
        __extends(ProductAddedView, _super);

        ProductAddedView.prototype.type = 'ProductAdded';

        function ProductAddedView(contentScript) {
          this.contentScript = contentScript;
          ProductAddedView.__super__.constructor.call(this, this.contentScript);
          this.el = $('<div class="-agora v-productAdded"> <span class="p-picture"></span> <div class="g-info"> <span class="p-title t-field" data-name="title"> <span class="display">Legend of Zelda: A Link to the Past</span> <span class="edit-w"><span class="w"><input type="text" class="edit"></span></span> </span> <span class="p-site">Amazon</span> <span class="p-price t-field" data-name="price"> <span class="display"></span> <span class="edit-w"><span class="w"><input type="text" class="edit"></span></span> </span> </div> <span class="v-button small n-close">Done</span> </div>');
          this.el.find('.n-remove').click((function(_this) {
            return function() {
              return _this.callBackgroundMethod('remove', null, function(returnVal) {
                return console.log(returnVal);
              });
            };
          })(this));
          this.editingCount = 0;
          this.isEditing = {};
          this.el.mouseenter((function(_this) {
            return function() {
              _this.mouseOver = true;
              return _this.updateInUse();
            };
          })(this));
          this.el.mouseleave((function(_this) {
            return function() {
              _this.mouseOver = false;
              return _this.updateInUse();
            };
          })(this));
        }

        ProductAddedView.prototype.updateInUse = function() {
          if (this.mouseOver || this.editingCount) {
            if (!this.inUse) {
              this.inUse = true;
              return typeof this.onStartedUsing === "function" ? this.onStartedUsing() : void 0;
            }
          } else {
            if (this.inUse) {
              this.inUse = false;
              return typeof this.onStoppedUsing === "function" ? this.onStoppedUsing() : void 0;
            }
          }
        };

        ProductAddedView.prototype.onData = function(data) {
          var enableEditModeForField, fields, image, price, site, title, updateField;
          title = this.el.find('.p-title');
          site = this.el.find('.p-site');
          image = this.el.find('.p-picture');
          price = this.el.find('.p-price');
          fields = {
            price: {
              display: 'displayPrice'
            }
          };
          updateField = function(field, edit) {
            var display, name, _ref;
            name = field.attr('data-name');
            if (display = (_ref = fields[name]) != null ? _ref.display : void 0) {
              field.find('.display').html(data[display].get());
              if (edit) {
                return field.find('.edit').val(data[name].get());
              }
            } else {
              if (data[name].get()) {
                field.find('.display').html(data[name].get());
                if (edit) {
                  return field.find('.edit').val(data[name].get());
                }
              }
            }
          };
          enableEditModeForField = {};
          this.el.find('.t-field').each((function(_this) {
            return function(i, el) {
              var closeEdit, display, edit, editModeEnabled, enabledEditMode, field, name, save, _ref;
              field = $(el);
              name = field.attr('data-name');
              updateField(field, true);
              edit = field.find('.edit');
              enabledEditMode = function(startEditing) {
                if (startEditing == null) {
                  startEditing = true;
                }
                field.addClass('s-editing');
                setTimeout((function() {
                  edit.get(0).select();
                  return edit.get(0).focus();
                }), 0);
                if (!_this.isEditing[name] && startEditing) {
                  _this.isEditing[name] = true;
                  ++_this.editingCount;
                  return _this.updateInUse();
                }
              };
              enableEditModeForField[name] = enabledEditMode;
              editModeEnabled = function() {
                return field.hasClass('s-editing');
              };
              closeEdit = function() {
                if (_this.isEditing[name]) {
                  delete _this.isEditing[name];
                  --_this.editingCount;
                  _this.updateInUse();
                }
                field.removeClass('s-editing');
                return edit.get(0).blur();
              };
              if (data[name].get() === '' || name === 'price') {
                enabledEditMode(false);
              }
              field.find('.display').dblclick(enabledEditMode);
              if (display = (_ref = fields[name]) != null ? _ref.display : void 0) {
                _this.observe(data[display], function(mutation) {
                  return updateField(field, !editModeEnabled());
                });
              }
              _this.observe(data[name], function(mutation) {
                return updateField(field, !editModeEnabled());
              });
              save = function() {
                var d;
                d = {};
                d[name] = edit.val();
                _this.callBackgroundMethod('set', [d]);
                return closeEdit();
              };
              return edit.keydown(function(e) {
                var nextField;
                switch (e.which) {
                  case 9:
                    fields = _this.el.find('.t-field');
                    i = $.inArray(field.get(0), fields);
                    nextField = $(fields.get((i + 1) % fields.length));
                    save();
                    enableEditModeForField[nextField.attr('data-name')]();
                    return false;
                  case 13:
                    save();
                    return false;
                  case 27:
                    closeEdit();
                    updateField(field, true);
                    return false;
                }
                if (!_this.isEditing[name]) {
                  ++_this.editingCount;
                  _this.isEditing[name] = true;
                  return _this.updateInUse();
                }
              });
            };
          })(this));
          site.html(data.site.name);
          if (data.image.get()) {
            image.css({
              backgroundImage: "url('" + (data.image.get()) + "')"
            });
          }
          this.observe(data.image, function(mutation) {
            return image.css({
              backgroundImage: "url('" + mutation.value + "')"
            });
          });
          return this.el.find('.n-close').click((function(_this) {
            return function() {
              return _this.onClose();
            };
          })(this));
        };

        return ProductAddedView;

      })(View);
    }
  };
});

//# sourceMappingURL=ProductAddedView.map
