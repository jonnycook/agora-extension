// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['underscore'], function(_) {
  var Resource;
  return Resource = (function(superClass) {
    extend(Resource, superClass);

    function Resource(value, url) {
      this.value = value;
      this.url = url;
      String.call(this, this.value);
    }

    Resource.prototype.safeMatch = function(pattern) {
      var matches;
      matches = this.match(pattern);
      if (matches) {
        return matches;
      } else {
        throw new Error(pattern + " not found in " + this.url);
      }
    };

    Resource.prototype.matchAll = function(pattern, group) {
      var globalMatches, i, matches, r, regExp;
      if (pattern instanceof RegExp) {
        pattern = pattern.source;
      }
      r = [];
      globalMatches = this.match(new RegExp(pattern, "g"));
      if (globalMatches) {
        regExp = new RegExp(pattern);
        i = 0;
        while (i < globalMatches.length) {
          matches = globalMatches[i].match(regExp);
          if (typeof group === "undefined") {
            r.push(matches);
          } else {
            r.push(matches[group]);
          }
          ++i;
        }
      }
      return r;
    };

    Resource.prototype.valueOf = function() {
      return this.value;
    };

    Resource.prototype.toString = function() {
      return this.value;
    };

    Resource.prototype.substr = function() {
      return new Resource(Resource.__super__.substr.apply(this, arguments));
    };

    return Resource;

  })(String);
});

//# sourceMappingURL=Resource.js.map
