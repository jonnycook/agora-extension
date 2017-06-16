// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['View', 'util', 'icons'],
    c: function() {
      var EditDescriptorView;
      return EditDescriptorView = (function(superClass) {
        extend(EditDescriptorView, superClass);

        EditDescriptorView.prototype.type = 'EditDescriptor';

        function EditDescriptorView() {
          var descriptorEl, el, parseTimerId, parsing;
          EditDescriptorView.__super__.constructor.apply(this, arguments);
          this.el = this.viewEl('<div class="v-editDescriptor t-dialog"> <h2>Edit Decision</h2> <div class="content"> <form> <div class="fields dark"> <div class="group descriptor"> <div class="field"><input type="text" class="descriptor" name="descriptor" placeholder="Describe what you are looking for"></div> </div> <div class="group"> <div class="field"><label>Product</label> <input type="text" name="product" placeholder="Product"></div> <div class="field"><label>Purpose</label> <input type="text" name="purpose" placeholder="Purpose"></div> <div class="field"><label>Context</label> <input type="text" name="context" placeholder="Context"></div> </div> <div class="group properties"> <div class="field"><label>Properties</label> <input type="text" name="properties" placeholder="Properties"></div> </div> <div class="group recipient"> <div class="field"><label>Recipient</label> <input type="text" name="recipient" placeholder="Recipient"></div> <div class="field"><label>Relationship</label> <input type="text" name="recipient.relationship" placeholder="Relationship"></div> <div class="field"><label>Age</label> <input type="text" name="recipient.age" placeholder="Age"></div> <div class="field"> <label>Sex</label> <select name="recipient.sex"> <option>Sex</option> <option value="male">Male</option> <option value="female">Female</option> </select> </div> </div> <div class="group gift"> <div class="field"><label>Gift</label> <input type="checkbox" name="gift"> </div> <div class="field gift"><label>Occasion</label> <input type="text" name="gift.occasion" placeholder="Occasion"></div> </div> <div class="buttons"> <!--<input type="button" class="button cancel" value="cancel">--> <input type="submit" class="button" value="confirm"> </div> </div> </form> </div> </div>');
          parseTimerId = null;
          descriptorEl = this.el.find('input.descriptor');
          parsing = 0;
          descriptorEl.keydown((function(_this) {
            return function() {
              clearTimeout(parseTimerId);
              return parseTimerId = setTimeout((function() {
                if (_this.lastDescriptor !== descriptorEl.val()) {
                  parsing++;
                  _this.lastDescriptor = descriptorEl.val();
                  return _this.callBackgroundMethod('parse', [descriptorEl.val()]);
                }
              }), 500);
            };
          })(this));
          util.styleSelect(this.el.find('[name="recipient.sex"]'), {
            autoSize: false
          });
          el = this.el.find('.-agora-newItem');
          util.tooltip(this.el.find('.-agora-newItem'), ((function(_this) {
            return function() {
              return descriptorEl.val();
            };
          })(this)), {
            position: 'below'
          });
          this.el.find('form').submit((function(_this) {
            return function() {
              var descriptor, person, product;
              clearTimeout(parseTimerId);
              if (_this.lastDescriptor !== descriptorEl.val()) {
                _this.callBackgroundMethod('parse', [descriptorEl.val(), true]);
                _this.close();
                return false;
              }
              descriptor = {};
              descriptor.descriptor = descriptorEl.val();
              product = null;
              if (_this.el.find('[name="product"]').val() !== '') {
                if (product == null) {
                  product = {};
                }
                product.type = _this.el.find('[name="product"]').val();
              }
              if (_this.el.find('[name="properties"]').val() !== '') {
                if (product == null) {
                  product = {};
                }
                product.properties = _.map(_this.el.find('[name="properties"]').val().split(','), function(p) {
                  return p.trim();
                });
              }
              if (product) {
                descriptor.product = product;
              }
              if (_this.el.find('[name="purpose"]').val() !== '') {
                descriptor.purpose = _this.el.find('[name="purpose"]').val();
              }
              if (_this.el.find('[name="context"]').val() !== '') {
                descriptor.context = _this.el.find('[name="context"]').val();
              }
              person = null;
              if (_this.el.find('[name="recipient"]').val() !== '') {
                if (person == null) {
                  person = {};
                }
                person.name = _this.el.find('[name="recipient"]').val();
              }
              if (_this.el.find('[name="recipient.relationship"]').val() !== '') {
                if (person == null) {
                  person = {};
                }
                person.relationship = _this.el.find('[name="recipient.relationship"]').val();
              }
              if (_this.el.find('[name="recipient.age"]').val() !== '') {
                if (person == null) {
                  person = {};
                }
                person.age = _this.el.find('[name="recipient.age"]').val();
              }
              if (_this.el.find('[name="recipient.sex"] ').val() !== '') {
                if (person == null) {
                  person = {};
                }
                person.sex = _this.el.find('[name="recipient.sex"]').val();
              }
              if (person) {
                descriptor.person = person;
              }
              if (_this.el.find('[name="gift.occasion"]').val() !== '') {
                descriptor.occasion = _this.el.find('[name="gift.occasion"]').val();
              }
              descriptor.version = _this.version;
              _this.callBackgroundMethod('updateDescriptor', descriptor);
              _this.close();
              return false;
            };
          })(this));
          setTimeout(((function(_this) {
            return function() {
              return descriptorEl.get(0).focus();
            };
          })(this)), 50);
        }

        EditDescriptorView.prototype.onData = function(data) {
          var update;
          this.data = data;
          _tutorial('EditDescriptor', {
            positionEl: this.el.find('[name="descriptor"]'),
            attachEl: this.el
          });
          update = (function(_this) {
            return function() {
              var descriptor, ref, ref1, ref10, ref11, ref12, ref13, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
              descriptor = _this.descriptor = (ref = _this.data.get()) != null ? ref : {};
              _this.version = descriptor.version;
              if (descriptor.descriptor) {
                _this.el.find('[name="descriptor"]').val(descriptor.descriptor);
              }
              _this.lastDescriptor = _this.el.find('[name="descriptor"]').val();
              _this.el.find('[name="product"]').val((ref1 = (ref2 = descriptor.product) != null ? ref2.type : void 0) != null ? ref1 : '');
              _this.el.find('[name="purpose"]').val((ref3 = descriptor.purpose) != null ? ref3 : '');
              _this.el.find('[name="context"]').val((ref4 = descriptor.context) != null ? ref4 : '');
              if ((ref5 = descriptor.product) != null ? ref5.properties : void 0) {
                _this.el.find('[name="properties"]').val(descriptor.product.properties.join(', '));
              } else {
                _this.el.find('[name="properties"]').val('');
              }
              _this.el.find('[name="recipient"]').val((ref6 = (ref7 = descriptor.person) != null ? ref7.name : void 0) != null ? ref6 : '');
              _this.el.find('[name="recipient.relationship"]').val((ref8 = (ref9 = descriptor.person) != null ? ref9.relationship : void 0) != null ? ref8 : '');
              _this.el.find('[name="recipient.age"]').val((ref10 = (ref11 = descriptor.person) != null ? ref11.age : void 0) != null ? ref10 : '');
              if ((ref12 = descriptor.person) != null ? ref12.sex : void 0) {
                _this.el.find('[name="recipient.sex"]').children("[value=" + ((ref13 = descriptor.person) != null ? ref13.sex : void 0) + "]").prop('selected', true);
              } else {
                _this.el.find('[name="recipient.sex"]').children(':first').prop('selected', true);
              }
              _this.el.find('[name="recipient.sex"]').trigger('change');
              if ('occasion' in descriptor) {
                _this.el.find('[name="gift"]').prop('checked', true);
                return _this.el.find('[name="gift.occasion"]').val(descriptor.occasion);
              } else {
                _this.el.find('[name="gift"]').prop('checked', false);
                return _this.el.find('[name="gift.occasion"]').val('');
              }
            };
          })(this);
          update();
          return this.data.observe((function(_this) {
            return function() {
              --_this.parsing;
              return update();
            };
          })(this));
        };

        return EditDescriptorView;

      })(View);
    }
  };
});

//# sourceMappingURL=EditDescriptorView.js.map
