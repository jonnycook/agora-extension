// Generated by CoffeeScript 1.7.1
var add, matchAll, matchName, output, set,
  __slice = [].slice;

output = null;

RegExp.prototype._exec = RegExp.prototype.exec;

RegExp.prototype.exec = function(subject) {
  var matches;
  matches = this._exec(subject);
  add({
    type: 'match',
    value: matches
  });
  return matches;
};

String.prototype._match = String.prototype.match;

String.prototype.match = function(pattern) {
  var matches;
  matches = this._match(pattern);
  add({
    type: 'match',
    value: matches
  });
  return matches;
};

matchName = null;

set = function(name) {
  return matchName = name;
};

add = function(opts) {
  if (matchName && !opts.name) {
    opts.name = matchName;
    matchName = null;
  }
  return output.push(opts);
};

matchAll = function(subject, pattern, group) {
  var globalMatch, globalMatches, matches, r, regExp, _i, _len;
  if (group == null) {
    group = false;
  }
  if (!pattern) {
    return [];
  }
  if (pattern instanceof RegExp) {
    pattern = pattern.source;
  }
  globalMatches = subject._match(new RegExp(pattern, 'g'));
  if (!globalMatches) {
    console.error("failed to match " + pattern);
    return [];
  }
  regExp = new RegExp(pattern);
  r = [];
  for (_i = 0, _len = globalMatches.length; _i < _len; _i++) {
    globalMatch = globalMatches[_i];
    matches = globalMatch._match(regExp);
    if (group === false) {
      r.push(matches);
    } else {
      r.push(matches[group]);
    }
  }
  add({
    type: (group === false ? 'matchAll' : 'match'),
    value: r
  });
  return r;
};

window.addEventListener('message', function(event) {
  var code;
  window.subject = event.data.subject;
  output = [];
  code = event.data.code;
  (function() {
    var match, matches, name, variableName, __, _i, _len, _ref, _results;
    eval(code);
    matches = code._match(/(\$\w*)\s*=/g);
    if (matches) {
      _results = [];
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        match = matches[_i];
        _ref = /(\$(\w*))\s*=/._exec(match), __ = _ref[0], variableName = _ref[1], name = _ref[2];
        _results.push(eval("add({type:'variable', name:'" + name + "', value:" + variableName + "});"));
      }
      return _results;
    }
  }).apply({
    matchAll: matchAll,
    resource: {
      _match: function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return typeof subject !== "undefined" && subject !== null ? subject._match.apply(subject, args) : void 0;
      },
      toString: function() {
        return subject;
      },
      matchAll: function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return matchAll.apply(null, [subject].concat(__slice.call(args)));
      },
      match: function(pattern) {
        return subject.match(pattern);
      }
    }
  });
  return event.source.postMessage(output, event.origin);
});

//# sourceMappingURL=eval.map
