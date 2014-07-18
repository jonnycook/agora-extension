// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View', 'Site', 'Formatter', 'util', 'underscore', './BarItem'], function(View, Site, Formatter, util, _, BarItem) {
  var ListBarItem;
  return ListBarItem = (function(_super) {
    __extends(ListBarItem, _super);

    function ListBarItem() {
      return ListBarItem.__super__.constructor.apply(this, arguments);
    }

    ListBarItem.prototype.type = 'List';

    ListBarItem.prototype.init = function() {
      var itemData, updateData, _ref;
      this.contentsCtx = this.ctx.context();
      itemData = (_ref = typeof this.itemData === "function" ? this.itemData() : void 0) != null ? _ref : {};
      itemData.state = this.itemView.clientValue();
      updateData = (function(_this) {
        return function() {
          var data;
          data = _this.obj.get('collapsed') ? {
            state: 'collapsed',
            contents: _this.collapsedContents()
          } : {
            state: 'expanded',
            contents: _this.expandedContents()
          };
          return itemData.state.set(data);
        };
      })(this);
      updateData();
      this.data = {
        type: this.type,
        barItemData: itemData
      };
      return this.observe(this.obj.field('collapsed'), (function(_this) {
        return function() {
          _this.contentsCtx.clear();
          return updateData();
        };
      })(this));
    };

    ListBarItem.prototype.dropped = function(obj) {
      util.addElement(this.obj, obj);
      return null;
    };

    ListBarItem.prototype.ripped = function(view) {
      return view.element["delete"]();
    };

    ListBarItem.prototype.expandedContents = function() {
      var contents;
      contents = this.itemView.clientArrayNamed("" + this.obj.modelName + ".contents");
      util.syncArrays(this.contentsCtx, this.obj.get('elements'), contents, (function(_this) {
        return function(element, onRemove, i) {
          return {
            elementType: element.modelName,
            elementId: element.get('id')
          };
        };
      })(this));
      return contents;
    };

    ListBarItem.prototype.collapsedContents = function() {
      var clientContents, getContents, reset;
      getContents = (function(_this) {
        return function() {
          var contents, ctx, obj, sources, stack, state;
          stack = [
            {
              list: _this.obj.get('elements'),
              pos: 0
            }
          ];
          contents = [];
          sources = [_this.obj.get('elements')];
          while (stack.length && contents.length < 4) {
            state = stack[stack.length - 1];
            if (state.list.length() === state.pos) {
              stack.pop();
              continue;
            }
            obj = state.list.get(state.pos++).get('element');
            while (true) {
              if (obj.modelName === 'Product') {
                contents.push(obj.get('image'));
                sources.push(obj.field('image'));
              } else if (obj.modelName === 'Decision') {
                stack.push({
                  list: obj.get('selection'),
                  pos: 0
                });
                sources.push(obj.get('selection'));
              } else if (obj.modelName === 'Bundle') {
                stack.push({
                  list: obj.get('elements'),
                  pos: 0
                });
                sources.push(obj.get('elements'));
              }
              break;
            }
          }
          ctx = _this.itemView.context();
          return [contents, sources];
        };
      })(this);
      clientContents = this.itemView.clientArrayNamed("" + this.obj.modelName + ".contents");
      reset = (function(_this) {
        return function() {
          var contents, source, sources, _i, _len, _ref;
          _this.contentsCtx.clear();
          _ref = getContents(), contents = _ref[0], sources = _ref[1];
          for (_i = 0, _len = sources.length; _i < _len; _i++) {
            source = sources[_i];
            _this.contentsCtx.observe(source, function(mutation) {
              return reset();
            });
          }
          return clientContents.setArray(contents);
        };
      })(this);
      reset();
      return clientContents;
    };

    ListBarItem.prototype.methods = {
      toggle: function(view) {
        if (this.obj.get('collapsed')) {
          return this.obj.set('collapsed', false);
        } else {
          return this.obj.set('collapsed', true);
        }
      },
      click: function() {
        return shoppingBarView.pushState({
          dropped: (function(_this) {
            return function(obj) {
              return util.addElement(_this.obj, obj);
            };
          })(this),
          ripped: (function(_this) {
            return function(view) {
              return view.element["delete"]();
            };
          })(this),
          contents: (function(_this) {
            return function() {
              return _this.obj.get('elements');
            };
          })(this),
          contentMap: (function(_this) {
            return function(el) {
              return {
                elementType: 'ListElement',
                elementId: el.get('id')
              };
            };
          })(this)
        });
      }
    };

    return ListBarItem;

  })(BarItem);
});

//# sourceMappingURL=ListBarItem.map
