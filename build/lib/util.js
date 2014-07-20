// Generated by CoffeeScript 1.7.1
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['Site', 'underscore', 'ObjectWrapper'], function(Site, _, ObjectWrapper) {
  var util;
  return util = {
    syncArrays: function(ctx, a, b, mapping) {
      var setRemoveCallback;
      setRemoveCallback = function(cb, position) {
        if (b.__removeCallback == null) {
          b.__removeCallback = [];
        }
        return b.__removeCallback[position] = cb;
      };
      a.each(function(el, i) {
        return b.push(mapping(el, (function(cb) {
          return setRemoveCallback(cb, i);
        }), i));
      });
      b.__syncedTo = a;
      return ctx.observe(a, b.__syncObserver = function(mutation) {
        var _name, _ref;
        if (mutation.type === 'insertion') {
          return b.insert(mapping(mutation.value, (function(cb) {
            return setRemoveCallback(cb, mutation.position);
          }), mutation.position), mutation.position);
        } else if (mutation.type === 'deletion') {
          if ((_ref = b.__removeCallback) != null) {
            if (typeof _ref[_name = mutation.position] === "function") {
              _ref[_name]();
            }
          }
          return b["delete"](mutation.position);
        } else if (mutation.type === 'movement') {
          return b.move(mutation.from, mutation.to);
        }
      });
    },
    unsyncArrays: function(a, b) {
      a.stopObserving(b.__syncObserver);
      return delete b.__syncObserver;
    },
    unsync: function(array) {
      return this.unsyncArrays(array.__syncedTo, array);
    },
    reorder: function(list, fromIndex, toIndex) {
      var i, instance, _i, _j, _ref, _ref1;
      instance = list.get(fromIndex);
      if (toIndex > fromIndex) {
        for (i = _i = _ref = fromIndex + 1; _ref <= toIndex ? _i <= toIndex : _i >= toIndex; i = _ref <= toIndex ? ++_i : --_i) {
          list.get(i).set('index', i - 1);
        }
      } else if (fromIndex > toIndex) {
        for (i = _j = _ref1 = fromIndex - 1; _ref1 <= toIndex ? _j <= toIndex : _j >= toIndex; i = _ref1 <= toIndex ? ++_j : --_j) {
          list.get(i).set('index', i + 1);
        }
      }
      return instance.set('index', toIndex);
    },
    addElement: function(obj, element) {
      return obj.get('contents').add(util.resolveObject(element));
    },
    resolveObject: function(element) {
      if (_.isFunction(element.getObj)) {
        return element.getObj();
      } else if (element.obj) {
        return element.obj;
      } else if (element.modelName.match(/Element$/)) {
        return element.get('element');
      } else {
        return element;
      }
    },
    feelingEmotionString: function(feeling) {
      var emotion, i, _i, _j, _ref, _ref1;
      emotion = '';
      for (i = _i = 0, _ref = feeling.get('positive'); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        emotion += '+';
      }
      for (i = _j = 0, _ref1 = feeling.get('negative'); 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        emotion += '-';
      }
      return emotion;
    },
    listPreview: function(ctx, list) {
      var clientList, getContents, reset;
      clientList = ctx.clientArray();
      getContents = (function(_this) {
        return function() {
          var contents, obj, sources, stack, state, _ref;
          stack = [
            {
              list: list,
              pos: 0
            }
          ];
          contents = [];
          sources = [list];
          while (stack.length && contents.length < 4) {
            state = stack[stack.length - 1];
            if (state.list.length() === state.pos) {
              stack.pop();
              continue;
            }
            obj = state.list.get(state.pos++).get('element');
            while (true) {
              if ((_ref = obj.modelName) === 'Product' || _ref === 'ProductVariant') {
                contents.push(obj.getDisplayValue('image'));
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
          return [contents, sources];
        };
      })(this);
      reset = (function(_this) {
        return function() {
          var contents, source, sources, _i, _len, _ref;
          ctx.clear();
          _ref = getContents(), contents = _ref[0], sources = _ref[1];
          for (_i = 0, _len = sources.length; _i < _len; _i++) {
            source = sources[_i];
            ctx.observe(source, function(mutation) {
              return reset();
            });
          }
          return clientList.setArray(contents);
        };
      })(this);
      reset();
      return clientList;
    },
    dismissDecisionElement: function(decision, element) {
      return decision.get('dismissed').add(element);
    },
    lastFeeling: function(ctx, product, lastFeelingCv) {
      var updateLastFeeling;
      if (lastFeelingCv == null) {
        lastFeelingCv = null;
      }
      if (lastFeelingCv == null) {
        lastFeelingCv = ctx.clientValue();
      }
      updateLastFeeling = (function(_this) {
        return function() {
          var emotion, feelings, lastFeeling;
          feelings = product.get('feelings');
          lastFeeling = feelings.length() ? feelings.get(feelings.length() - 1) : void 0;
          if (lastFeeling) {
            emotion = util.feelingEmotionString(lastFeeling);
            return lastFeelingCv.set({
              thought: lastFeeling.get('thought'),
              positive: lastFeeling.get('positive'),
              negative: lastFeeling.get('negative')
            });
          } else {
            return lastFeelingCv.set(null);
          }
        };
      })(this);
      updateLastFeeling();
      ctx.observe(product.get('feelings'), updateLastFeeling);
      return lastFeelingCv;
    },
    lastArgument: function(ctx, product, lastArgumentCv) {
      var updateLastArgument;
      if (lastArgumentCv == null) {
        lastArgumentCv = ctx.clientValue();
      }
      updateLastArgument = (function(_this) {
        return function() {
          var arguments_, lastArgument;
          arguments_ = product.get('arguments');
          lastArgument = arguments_.length() ? arguments_.get(arguments_.length() - 1) : void 0;
          if (lastArgument) {
            return lastArgumentCv.set({
              thought: lastArgument.get('thought'),
              "for": lastArgument.get('for'),
              against: lastArgument.get('against')
            });
          } else {
            return lastArgumentCv.set(null);
          }
        };
      })(this);
      updateLastArgument();
      ctx.observe(product.get('arguments'), updateLastArgument);
      return lastArgumentCv;
    },
    feelings: function(parentCtx, obj) {
      return parentCtx.clientArray(obj.get('feelings'), (function(_this) {
        return function(feeling, onRemove) {
          var ctx, emotion;
          ctx = parentCtx.context();
          onRemove(function() {
            return ctx.destruct();
          });
          emotion = util.feelingEmotionString(feeling);
          return {
            id: feeling.get('id'),
            negative: ctx.clientValue(feeling.field('negative')),
            positive: ctx.clientValue(feeling.field('positive')),
            thought: ctx.clientValue(feeling.field('thought'))
          };
        };
      })(this));
    },
    "arguments": function(parentCtx, obj) {
      return parentCtx.clientArray(obj.get('arguments'), (function(_this) {
        return function(argument, onRemove) {
          var ctx;
          ctx = parentCtx.context();
          onRemove(function() {
            return ctx.destruct();
          });
          return {
            id: argument.get('id'),
            "for": ctx.clientValue(argument.field('for')),
            against: ctx.clientValue(argument.field('against')),
            thought: ctx.clientValue(argument.field('thought'))
          };
        };
      })(this));
    },
    resolveProducts: function(obj, p) {
      var id, objs;
      if (p == null) {
        p = false;
      }
      if (obj.isA('Product')) {
        return [obj];
      } else if (obj.isA('Bundle')) {
        objs = [];
        id = obj.get('id');
        obj.get('elements').each(function(el) {
          return objs = objs.concat(util.resolveProducts(el.get('element'), id));
        });
        return objs;
      } else if (obj.isA('Decision')) {
        objs = [];
        obj.get('selection').each(function(el) {
          return objs = objs.concat(util.resolveProducts(el.get('element')));
        });
        return objs;
      } else {
        return [];
      }
    },
    observeContents: function(ctx, elements, cb) {
      var observeElement, observeObj;
      observeElement = function(el) {
        ctx.observe(el.get('element'), function() {
          observeObj(el.get('element'));
          return cb();
        });
        return observeObj(el.get('element'));
      };
      observeObj = function(obj) {
        var els;
        if (obj.isA('Bundle') || obj.isA('Decision')) {
          els = obj.isA('Decision') ? obj.get('selection') : obj.get('elements');
          return util.observeContents(ctx, els, cb);
        }
      };
      ctx.observe(elements, function(mutation) {
        if (mutation.type === 'insertion') {
          observeElement(mutation.value);
        }
        return cb();
      });
      return elements.each(function(el) {
        return observeElement(el);
      });
    },
    numberWithCommas: function(x) {
      var parts;
      if (x != null) {
        parts = x.toString().split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return parts.join('.');
      }
    },
    stripHtml: function(html, tags, baseUrl) {
      if (tags == null) {
        tags = null;
      }
      if (baseUrl == null) {
        baseUrl = null;
      }
      if (!_.isString(html)) {
        return html;
      }
      if (tags == null) {
        tags = ['h1', 'h2', 'h3', 'h4', 'p', 'small', 'b', 'small', 'a', 'br', 'em', 'ul', 'li'];
      }
      return html.replace(/<\s*(\/?)\s*(\w*)([^>]*)>/g, function(match, slash, tag, attrs) {
        var field, matches, newAttrs, value;
        tag = tag.toLowerCase();
        if (__indexOf.call(tags, tag) >= 0) {
          if (slash) {
            return "</" + tag + ">";
          } else {
            newAttrs = {};
            if (tag === 'a') {
              matches = attrs.match(/href\s*=\s*"([^"]*)"/);
              if (matches) {
                newAttrs['href'] = util.url(matches[1], baseUrl);
                newAttrs['target'] = '_blank';
              }
            } else if (tag === 'img') {
              matches = attrs.match(/src\s*=\s*"([^"]*)"/);
              if (matches) {
                newAttrs['src'] = matches[1];
                newAttrs['width'] = 100;
              }
            }
            newAttrs = ((function() {
              var _results;
              _results = [];
              for (field in newAttrs) {
                value = newAttrs[field];
                _results.push("" + field + "=\"" + value + "\"");
              }
              return _results;
            })()).join(' ');
            if (newAttrs.length) {
              newAttrs = ' ' + newAttrs;
            }
            return "<" + tag + newAttrs + ">";
          }
        } else {
          return '';
        }
      }).trim();
    },
    colorForUser: function(baseUser, coloredUser) {
      var colorId, colorPair, colorPairs, coloredUserId, colors, currentColors, userId, _i, _len, _ref;
      coloredUserId = typeof coloredUser === 'number' || typeof coloredUser === 'string' ? parseInt(coloredUser) : coloredUser.saneId();
      if (baseUser.saneId() === coloredUserId) {
        return '#FFFFFF';
      }
      colors = ['#AC8AB2', '#25BA26', '#C3230C', '#DD49DA', '#6B5825', '#3FC0A4', '#D73A76', '#8987D6', '#EDCD28', '#7D3B83', '#026A5D', '#8A2519', '#4DA7C7', '#B6B12E', '#4F4F77', '#426A2D', '#8BAA39', '#F4A720', '#75AD6F', '#DD625E', '#A15ED9', '#D87D9B', '#6B98D5', '#C8907D', '#DE7C19'];
      currentColors = baseUser.get('user_colors');
      if (currentColors) {
        colorPairs = currentColors.split(' ');
        for (_i = 0, _len = colorPairs.length; _i < _len; _i++) {
          colorPair = colorPairs[_i];
          _ref = colorPair.split(':'), userId = _ref[0], colorId = _ref[1];
          if (userId == coloredUserId) {
            return colors[colorId];
          }
        }
        if (colorPairs.length === colors.length) {
          return '#000000';
        } else {
          colorId = colorPairs.length;
          baseUser.set('user_colors', "" + (baseUser.get('user_colors')) + " " + coloredUserId + ":" + colorId);
          return colors[colorId];
        }
      } else {
        baseUser.set('user_colors', "" + coloredUserId + ":0");
        return colors[0];
      }
    },
    ucfirst: function(string) {
      return string.toLowerCase().replace(/(\b)(\w)/g, function(match, leading, letter) {
        return "" + leading + (letter.toUpperCase());
      });
    },
    find: function(list, predicate) {
      if (_.isPlainObject(predicate)) {
        return list.find(function(instance) {
          var name, value;
          for (name in predicate) {
            value = predicate[name];
            if (instance.get(name) !== value) {
              return false;
            }
          }
          return true;
        });
      } else {
        return list.find(predicate);
      }
    },
    userWrapper: function(userId) {
      if (window._userWrappers == null) {
        window._userWrappers = {};
      }
      if (!_userWrappers[userId]) {
        _userWrappers[userId] = ObjectWrapper.create(userId, '@', {
          name: 'User ' + userId
        });
      }
      return _userWrappers[userId];
    },
    findAll: function(list, predicate) {
      if (_.isPlainObject(predicate)) {
        return list.findAll(function(instance) {
          var name, value;
          for (name in predicate) {
            value = predicate[name];
            if (instance.get(name) !== value) {
              return false;
            }
          }
          return true;
        });
      } else {
        return list.findAll(predicate);
      }
    },
    filteredArray: function(ctx, subject, output, test, reversed, watch) {
      var add, t;
      if (reversed == null) {
        reversed = false;
      }
      if (watch == null) {
        watch = null;
      }
      add = reversed ? function(obj) {
        return output.unshift(obj);
      } : function(obj) {
        return output.push(obj);
      };
      t = function(obj) {
        return function() {
          if (test(obj) && !output.contains(obj)) {
            return add(obj);
          } else if (!test(obj) && output.contains(obj)) {
            return output.remove(obj);
          }
        };
      };
      subject.each((function(_this) {
        return function(record) {
          if (typeof watch === "function") {
            watch(ctx, record, t(record));
          }
          if (test(record)) {
            return add(record);
          }
        };
      })(this));
      return ctx.observeObject(subject, (function(_this) {
        return function(mutation) {
          if (mutation.type === 'insertion') {
            if (typeof watch === "function") {
              watch(ctx, mutation.value, t(mutation.value));
            }
            if (test(mutation.value)) {
              return add(mutation.value);
            }
          } else if (mutation.type === 'deletion') {
            if (test(mutation.value)) {
              return output.remove(mutation.value);
            }
          }
        };
      })(this));
    },
    url: function(url, baseUrl) {
      var part, _ref;
      if (baseUrl == null) {
        baseUrl = null;
      }
      if (url) {
        part = (_ref = url.match(/^https?:\/\/(.*)$/)) != null ? _ref[1] : void 0;
        if (part) {
          return 'http://agora.sh/url/' + part;
        } else if (baseUrl && url[0] === '/') {
          return util.url(baseUrl + url);
        } else {
          return url;
        }
      }
    },
    mapObjects: function(array, map) {
      if (array) {
        return _.map(array, (function(_this) {
          return function(el) {
            var mapping, newEl, p;
            newEl = _.clone(el);
            for (p in map) {
              mapping = map[p];
              if (_.isFunction(mapping)) {
                newEl[p] = mapping(el);
              } else {
                newEl[p] = el[mapping];
              }
            }
            return newEl;
          };
        })(this));
      }
    },
    shoppingBar: {
      pushRootState: function(user) {
        var belt;
        belt = user.get('belts').get(0);
        return shoppingBarView.pushState({
          state: 'root',
          shareObject: function() {
            return "belts." + (belt.saneId());
          },
          shared: function() {
            return belt.field('shared');
          },
          isShared: function() {
            return belt.get('shared');
          },
          contents: (function(_this) {
            return function() {
              return belt.get('elements');
            };
          })(this),
          contentMap: (function(_this) {
            return function(el) {
              return {
                elementType: 'BeltElement',
                elementId: el.get('id')
              };
            };
          })(this),
          ripped: function(view) {
            _activity('remove', belt, util.resolveObject(view.element));
            return view.element["delete"]();
          },
          dropped: (function(_this) {
            return function(element) {
              var obj;
              obj = util.resolveObject(element);
              _activity('add', belt, obj);
              return belt.get('contents').add(obj);
            };
          })(this)
        });
      },
      pushBeltState: function(belt) {
        return shoppingBarView.pushState({
          state: 'root',
          shareObject: function() {
            return "belts." + (belt.saneId());
          },
          shared: function() {
            return belt.field('shared');
          },
          isShared: function() {
            return belt.get('shared');
          },
          contents: (function(_this) {
            return function() {
              return belt.get('elements');
            };
          })(this),
          contentMap: (function(_this) {
            return function(el) {
              return {
                elementType: 'BeltElement',
                elementId: el.get('id')
              };
            };
          })(this),
          ripped: function(view) {
            _activity('remove', belt, util.resolveObject(view.element));
            return view.element["delete"]();
          },
          dropped: (function(_this) {
            return function(element) {
              var obj;
              obj = util.resolveObject(element);
              _activity('add', belt, obj);
              return belt.get('contents').add(obj);
            };
          })(this)
        });
      },
      pushDecisionState: function(decision) {
        return shoppingBarView.pushState({
          shareObject: function() {
            return "decisions." + (decision.record.saneId());
          },
          shared: function() {
            return decision.field('shared');
          },
          isShared: function() {
            return decision.get('shared');
          },
          dropped: (function(_this) {
            return function(element) {
              var obj;
              obj = util.resolveObject(element);
              _activity('add', decision, obj);
              return decision.get('list').get('contents').add(obj);
            };
          })(this),
          ripped: (function(_this) {
            return function(view) {
              return view.element["delete"]();
            };
          })(this),
          contents: (function(_this) {
            return function() {
              return decision.get('list').get('elements');
            };
          })(this),
          contentMap: (function(_this) {
            return function(el) {
              return {
                elementType: 'ListElement',
                elementId: el.get('id'),
                decisionId: decision.get('id')
              };
            };
          })(this),
          state: 'Decision',
          args: {
            decisionId: decision.get('id')
          }
        });
      }
    }
  };
});

//# sourceMappingURL=util.map
