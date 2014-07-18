// Generated by CoffeeScript 1.7.1
define(['underscore'], function(_) {
  var sort;
  sort = function(array, args) {
    var a, action, actions, compare, findBetween, from, get, i, length, move, orderedRanges, originalPosition, r, range, rangeA, rangeB, ranges, shouldMove, sortedRanges, to, _i, _j, _k, _l, _len, _len1, _len2, _m, _ref, _ref1, _results;
    move = args.move, compare = args.compare, get = args.get, length = args.length;
    findBetween = function(a, b, skips) {
      var i, _i, _ref;
      if (skips == null) {
        skips = [];
      }
      for (i = _i = 0, _ref = length(array); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (i === a || i === b) {
          continue;
        }
        if (compare(get(array, i), get(array, a)) > 0 && compare(get(array, i), get(array, b)) < 0) {
          return true;
        }
      }
      return false;
    };
    ranges = [];
    rangeA = 0;
    rangeB = 0;
    range = [];
    for (i = _i = 0, _ref = length(array) - 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      range.push(get(array, i));
      if (compare(get(array, i), get(array, i + 1)) > 0 || findBetween(i, i + 1)) {
        ranges.push({
          a: rangeA,
          b: rangeB,
          range: range,
          aValue: get(array, rangeA),
          bValue: get(array, rangeB)
        });
        range = [];
        rangeA = rangeB = i + 1;
      } else {
        rangeB++;
      }
    }
    range.push(get(array, length(array) - 1));
    ranges.push({
      a: rangeA,
      b: rangeB,
      range: range,
      aValue: get(array, rangeA),
      bValue: get(array, rangeB)
    });
    orderedRanges = ranges.slice(0, ranges.length).sort(function(a, b) {
      return a.range.length - b.range.length;
    });
    sortedRanges = ranges.slice(0, ranges.length);
    actions = [];
    for (_j = 0, _len = orderedRanges.length; _j < _len; _j++) {
      r = orderedRanges[_j];
      originalPosition = 0;
      from = 0;
      for (i = _k = 0, _len1 = sortedRanges.length; _k < _len1; i = ++_k) {
        range = sortedRanges[i];
        if (range === r) {
          originalPosition = i;
          sortedRanges.splice(i, 1);
          break;
        } else {
          from += range.range.length;
        }
      }
      to = 0;
      for (i = _l = 0, _ref1 = sortedRanges.length; 0 <= _ref1 ? _l <= _ref1 : _l >= _ref1; i = 0 <= _ref1 ? ++_l : --_l) {
        shouldMove = false;
        if (i === sortedRanges.length) {
          shouldMove = true;
        } else {
          if (compare(r.bValue, sortedRanges[i].aValue) <= 0) {
            shouldMove = true;
          }
        }
        if (shouldMove) {
          if (originalPosition !== i) {
            actions.push({
              from: from,
              to: to,
              length: r.range.length
            });
          }
          sortedRanges.splice(i, 0, r);
          break;
        } else {
          to += sortedRanges[i].range.length;
        }
      }
    }
    _results = [];
    for (_m = 0, _len2 = actions.length; _m < _len2; _m++) {
      action = actions[_m];
      a = 0;
      _results.push((function() {
        var _n, _ref2, _ref3, _results1;
        _results1 = [];
        for (i = _n = _ref2 = action.from, _ref3 = action.from + action.length; _ref2 <= _ref3 ? _n < _ref3 : _n > _ref3; i = _ref2 <= _ref3 ? ++_n : --_n) {
          from = i;
          to = action.to + i - action.from;
          _results1.push(move(array, from, to));
        }
        return _results1;
      })());
    }
    return _results;
  };
  return function(list, orderBy) {
    var maintainOrder, startedTimer, stopFuncs;
    startedTimer = false;
    maintainOrder = function(instance) {
      var compare, order;
      compare = (function(_this) {
        return function(a, b) {
          var result;
          if (a.get(orderBy.field) < b.get(orderBy.field)) {
            result = -1;
          } else if (a.get(orderBy.field) > b.get(orderBy.field)) {
            result = 1;
          } else {
            result = 0;
          }
          if (orderBy.direction === 'desc') {
            result *= -1;
          }
          return result;
        };
      })(this);
      list.sort(compare);
      order = function() {
        if (startedTimer) {
          return;
        }
        startedTimer = true;
        return setTimeout((function() {
          startedTimer = false;
          return sort(list, {
            length: function(array) {
              return array.length();
            },
            compare: (function(_this) {
              return function(a, b) {
                var result;
                if (a.get(orderBy.field) < b.get(orderBy.field)) {
                  result = -1;
                } else if (a.get(orderBy.field) > b.get(orderBy.field)) {
                  result = 1;
                } else {
                  result = 0;
                }
                if (orderBy.direction === 'desc') {
                  result *= -1;
                }
                return result;
              };
            })(this),
            move: function(array, from, to) {
              return array.move(from, to);
            },
            get: function(array, i) {
              return array.get(i);
            }
          });
        }), 0);
      };
      instance.field(orderBy.field).observe(order);
      return function() {
        return instance.field(orderBy.field).stopObserving(order);
      };
    };
    stopFuncs = [];
    return list.observe(function(mutation) {
      var a, i, instance, stop, _i, _len, _results;
      instance = mutation.value;
      if (mutation.type === 'insertion') {
        if (instance.get(orderBy.field) === null) {
          instance.set(orderBy.field, list.length());
        }
        stop = maintainOrder(mutation.value);
        stopFuncs.push({
          obj: mutation.value,
          func: stop
        });
      }
      if (mutation.type === 'deletion') {
        _results = [];
        for (i = _i = 0, _len = stopFuncs.length; _i < _len; i = ++_i) {
          a = stopFuncs[i];
          if (a.obj === mutation.value) {
            a.func();
            stopFuncs.splice(i, 1);
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    });
  };
});

//# sourceMappingURL=maintainOrder2.map
