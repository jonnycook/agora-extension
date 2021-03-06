// Generated by CoffeeScript 1.10.0
define(['underscore'], function(_) {
  var sort;
  sort = function(array, args) {
    var a, action, actions, compare, findBetween, from, get, i, j, k, l, len, len1, len2, length, m, move, n, orderedRanges, originalPosition, r, range, rangeA, rangeB, ranges, ref, ref1, results, shouldMove, sortedRanges, to;
    move = args.move, compare = args.compare, get = args.get, length = args.length;
    findBetween = function(a, b, skips) {
      var i, j, ref;
      if (skips == null) {
        skips = [];
      }
      for (i = j = 0, ref = length(array); 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
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
    for (i = j = 0, ref = length(array) - 1; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
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
    for (k = 0, len = orderedRanges.length; k < len; k++) {
      r = orderedRanges[k];
      originalPosition = 0;
      from = 0;
      for (i = l = 0, len1 = sortedRanges.length; l < len1; i = ++l) {
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
      for (i = m = 0, ref1 = sortedRanges.length; 0 <= ref1 ? m <= ref1 : m >= ref1; i = 0 <= ref1 ? ++m : --m) {
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
    results = [];
    for (n = 0, len2 = actions.length; n < len2; n++) {
      action = actions[n];
      a = 0;
      results.push((function() {
        var o, ref2, ref3, results1;
        results1 = [];
        for (i = o = ref2 = action.from, ref3 = action.from + action.length; ref2 <= ref3 ? o < ref3 : o > ref3; i = ref2 <= ref3 ? ++o : --o) {
          from = i;
          to = action.to + i - action.from;
          results1.push(move(array, from, to));
        }
        return results1;
      })());
    }
    return results;
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
      var a, i, instance, j, len, results, stop;
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
        results = [];
        for (i = j = 0, len = stopFuncs.length; j < len; i = ++j) {
          a = stopFuncs[i];
          if (a.obj === mutation.value) {
            a.func();
            stopFuncs.splice(i, 1);
            break;
          } else {
            results.push(void 0);
          }
        }
        return results;
      }
    });
  };
});

//# sourceMappingURL=maintainOrder2.js.map
