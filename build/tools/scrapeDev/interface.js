// Generated by CoffeeScript 1.7.1
define(function() {
  var ArrayElementInterface, DataBinding, DataInterface, ObjectElementInterface, createInput, createInterface, inputs, interfaces, onModified, resolveInput, stripUIData;
  interfaces = {};
  inputs = {};
  onModified = null;
  resolveInput = function(data) {
    var input;
    return input = typeof data === 'string' ? {
      type: data
    } : data;
  };
  createInput = function(input, binding, element) {
    var el;
    el = inputs[input.type](input, binding, element);
    return el;
  };
  DataInterface = (function() {
    function DataInterface(data) {
      this.data = data;
    }

    DataInterface.prototype.binding = function(field) {
      return new DataBinding(this.data, field);
    };

    DataInterface.prototype.setUIData = function(data) {
      return this.data['.ui'] = data;
    };

    DataInterface.prototype.get = function() {
      return this.data;
    };

    return DataInterface;

  })();
  ArrayElementInterface = (function() {
    function ArrayElementInterface(arrayInterface, index) {
      var _base;
      this.arrayInterface = arrayInterface;
      this.index = index;
      this.array = this.arrayInterface.get();
      if ((_base = this.array).observers == null) {
        _base.observers = [];
      }
      this.array.observers.push(this);
      this.dataInterface = new DataInterface(this.array[this.index]);
    }

    ArrayElementInterface.prototype["delete"] = function() {
      var observer, _i, _len, _ref;
      _ref = this.array.observers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        observer = _ref[_i];
        if (observer !== this) {
          observer.deleted(this.index);
        }
      }
      this.array.splice(this.index, 1);
      _.pull(this.array.observers, this);
      return typeof onModified === "function" ? onModified() : void 0;
    };

    ArrayElementInterface.prototype.deleted = function(index) {
      if (this.index > index) {
        return --this.index;
      }
    };

    ArrayElementInterface.prototype.binding = function(field) {
      return this.dataInterface.binding(field);
    };

    ArrayElementInterface.prototype.setUIData = function(data) {
      return this.dataInterface.setUIData(data);
    };

    ArrayElementInterface.prototype.get = function() {
      return this.dataInterface.get();
    };

    ArrayElementInterface.prototype.set = function(value) {
      this.array[this.index] = value;
      return typeof onModified === "function" ? onModified() : void 0;
    };

    return ArrayElementInterface;

  })();
  ObjectElementInterface = (function() {
    function ObjectElementInterface(object, key) {
      this.object = object;
      this.key = key;
      this.dataInterface = new DataInterface(this.object[this.key]);
    }

    ObjectElementInterface.prototype.binding = function(field) {
      return this.dataInterface.binding(field);
    };

    ObjectElementInterface.prototype["delete"] = function() {
      delete this.object[this.key];
      return typeof onModified === "function" ? onModified() : void 0;
    };

    ObjectElementInterface.prototype.changeKey = function(key) {
      console.debug(key);
      this.object[key] = this.object[this.key];
      delete this.object[this.key];
      this.key = key;
      return typeof onModified === "function" ? onModified() : void 0;
    };

    ObjectElementInterface.prototype.setUIData = function(data) {
      return this.dataInterface.setUIData(data);
    };

    ObjectElementInterface.prototype.get = function() {
      return this.dataInterface.get();
    };

    ObjectElementInterface.prototype.set = function(value) {
      this.object[this.key] = value;
      return typeof onModified === "function" ? onModified() : void 0;
    };

    return ObjectElementInterface;

  })();
  DataBinding = (function() {
    function DataBinding(data, field) {
      this.data = data;
      this.field = field;
      if (!this.data) {
        throw new Error('bad');
      }
      if (this.field && this.data && !this.field in this.data) {
        throw new Error('error');
      }
    }

    DataBinding.prototype.setUIData = function(data) {
      this.uiData = data;
      return this.updateUIData();
    };

    DataBinding.prototype.updateUIData = function() {
      if (this.get()) {
        return this.get()['.ui'] = this.uiData;
      }
    };

    DataBinding.prototype.get = function() {
      var fieldParts, obj, part, _i, _len;
      if (this.data && this.field) {
        fieldParts = this.field.split('.');
        obj = this.data;
        if (obj) {
          for (_i = 0, _len = fieldParts.length; _i < _len; _i++) {
            part = fieldParts[_i];
            obj = obj[part];
            if (!obj) {
              return null;
            }
          }
        }
        return obj;
      } else {
        return null;
      }
    };

    DataBinding.prototype.set = function(value) {
      var fieldParts, i, obj, part, _i, _len;
      if (this.data && this.field) {
        fieldParts = this.field.split('.');
        obj = this.data;
        for (i = _i = 0, _len = fieldParts.length; _i < _len; i = ++_i) {
          part = fieldParts[i];
          if (i === fieldParts.length - 1) {
            obj[part] = value;
          } else {
            if (obj[part] == null) {
              obj[part] = {};
            }
            obj = obj[part];
          }
        }
      }
      this.updateUIData();
      return typeof onModified === "function" ? onModified() : void 0;
    };

    DataBinding.prototype.binding = function(field) {
      var v;
      v = this.get();
      if (v === null || v === void 0) {
        this.set({});
      } else if (!_.isPlainObject(v)) {
        throw new Error('invalid type');
      }
      return new DataBinding(this.get(), field);
    };

    DataBinding.prototype.push = function(value) {
      var v;
      v = this.get();
      if (v === null || v === void 0) {
        this.set([]);
        this.get().push(value);
      } else if (_.isArray(v)) {
        v.push(value);
      } else {
        console.debug(v);
        throw new Error('invalid type');
      }
      this.updateUIData();
      return typeof onModified === "function" ? onModified() : void 0;
    };

    DataBinding.prototype.setKey = function(key, value) {
      var v;
      v = this.get();
      if (v === null || v === void 0) {
        this.set({});
        this.get()[key] = value;
      } else if (_.isPlainObject(v)) {
        v[key] = value;
      } else {
        console.debug(v);
        throw new Error('invalid type');
      }
      this.updateUIData();
      return typeof onModified === "function" ? onModified() : void 0;
    };

    return DataBinding;

  })();
  stripUIData = function(data) {
    var i, key, newData, value, _i, _len;
    if (data !== null && data !== void 0) {
      newData = _.clone(data);
      if (newData['.ui']) {
        delete newData['.ui'];
      }
      if (_.isArray(newData)) {
        for (i = _i = 0, _len = newData.length; _i < _len; i = ++_i) {
          value = newData[i];
          newData[i] = stripUIData(value);
        }
      } else if (_.isPlainObject(newData)) {
        for (key in newData) {
          value = newData[key];
          if (value === '' || value === null || value === void 0) {
            delete newData[key];
          } else {
            newData[key] = stripUIData(value);
          }
        }
      }
      return newData;
    }
  };
  return {
    DataInterface: DataInterface,
    setInputs: function(obj) {
      return inputs = obj;
    },
    setInterfaces: function(obj) {
      return interfaces = obj;
    },
    setOnModified: function(func) {
      return onModified = func;
    },
    stripUIData: stripUIData,
    createInterface: createInterface = function(interfaceName, dataInterface, element) {
      var actionsContEl, addEl, data, dictionaryEl, el, elementType, i, iface, input, key, keyEl, listEl, selectEl, value, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
      iface = _.clone(interfaces[interfaceName]);
      if (iface.type == null) {
        iface.type = 'form';
      }
      el = $('<div class="interface" />').addClass(iface.type).addClass(interfaceName);
      actionsContEl = $('<div class="actions"><button class="copy">Copy</button><button class="paste">Paste</button></div>').appendTo(el);
      actionsContEl.find('.copy').click(function() {
        return window.copyBuffer = stripUIData(dataInterface.get());
      });
      actionsContEl.find('.paste').click(function() {
        dataInterface.set(window.copyBuffer);
        return resetInterface();
      });
      if (element) {
        el.append("<span class='name'><button class='toggle'>Toggle</button> " + interfaceName + " (" + (element != null ? element.bind : void 0) + ")</span>");
      } else {
        el.append("<span class='name'><button class='toggle'>Toggle</button> " + interfaceName + "</span>");
      }
      el.find('.name .toggle').click(function() {
        return el.toggleClass('minimized');
      });
      dataInterface.setUIData({
        el: el
      });
      switch (iface.type) {
        case 'form':
          if (iface.elements) {
            _ref = iface.elements;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              element = _ref[_i];
              if (element["interface"]) {
                el.append(createInterface(element["interface"], dataInterface.binding(element.bind), element));
              } else if (element.input) {
                input = resolveInput(element.input);
                el.append($('<div class="field" />').addClass(input.type).addClass(element.bind).append(createInput(input, dataInterface.binding(element.bind), element)));
              }
            }
          }
          break;
        case 'list':
          listEl = $('<ul />').appendTo(el);
          addEl = function(elementType, arrayDataInterface) {
            var li;
            return listEl.append(li = $('<li />').append(createInterface(elementType, arrayDataInterface)).append($('<button class="delete">X</button>').click(function() {
              arrayDataInterface["delete"]();
              return li.slideUp(function() {
                return li.remove();
              });
            })));
          };
          if (dataInterface.get()) {
            _ref1 = dataInterface.get();
            for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
              data = _ref1[i];
              elementType = iface.map ? iface.map(data) : iface.elementType;
              addEl(elementType, new ArrayElementInterface(dataInterface, i));
            }
          }
          if (iface.elementType) {
            el.children('.name').append($('<button class="add">Add</button>').click(function() {
              var obj;
              obj = {};
              if (typeof iface.initObj === "function") {
                iface.initObj(obj, iface.elementType);
              }
              dataInterface.push(obj);
              return addEl(iface.elementType, new ArrayElementInterface(dataInterface, dataInterface.get().length - 1));
            }));
          } else if (iface.elementTypes) {
            selectEl = $('<select />');
            _ref2 = iface.elementTypes;
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              elementType = _ref2[_k];
              selectEl.append($("<option>" + elementType + "</option>"));
            }
            $('<div class="add" />').appendTo(el.children('.name')).append(selectEl).append($('<button class="add">Add</button>').click(function() {
              var obj;
              obj = {};
              if (typeof iface.initObj === "function") {
                iface.initObj(obj, selectEl.val(), dataInterface.push(obj));
              }
              return addEl(selectEl.val(), new ArrayElementInterface(dataInterface, dataInterface.get().length - 1));
            }));
          }
          break;
        case 'dictionary':
          dictionaryEl = $('<ul />').appendTo(el);
          addEl = function(key) {
            var liEl, objectDataInterface;
            objectDataInterface = new ObjectElementInterface(dataInterface.get(), key);
            liEl = $('<li />');
            liEl.append($('<input type="text" />').val(key).change(function() {
              return objectDataInterface.changeKey($(this).val());
            }));
            liEl.append(createInterface(iface.valueInterface, objectDataInterface));
            liEl.append($('<button class="delete">X</button>').click(function() {
              liEl.slideUp(function() {
                return liEl.remove();
              });
              return objectDataInterface["delete"]();
            }));
            return dictionaryEl.append(liEl);
          };
          _ref3 = dataInterface.get();
          for (key in _ref3) {
            value = _ref3[key];
            if (key === '.ui') {
              continue;
            }
            addEl(key);
          }
          keyEl = $('<input type="text">');
          $('<div class="add" />').appendTo(el.children('.name')).append(keyEl).append($('<button>Add</button>').click(function() {
            key = keyEl.val();
            dataInterface.setKey(key, {});
            return addEl(key);
          }));
      }
      if (typeof iface.init === "function") {
        iface.init(el, dataInterface);
      }
      return el;
    }
  };
});

//# sourceMappingURL=interface.map