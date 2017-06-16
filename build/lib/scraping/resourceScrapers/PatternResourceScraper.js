// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['../ResourceScraper', 'underscore'], function(ResourceScraper, _) {
  var PatternResourceScraper;
  return PatternResourceScraper = (function(superClass) {
    extend(PatternResourceScraper, superClass);

    function PatternResourceScraper(pattern1, match1, _default) {
      this.pattern = pattern1;
      this.match = match1;
      this["default"] = _default;
      if (this === window) {
        return ResourceScraper(arguments);
      }
    }

    PatternResourceScraper.prototype.scrape = function(cb) {
      var i, j, len, m, map, match, matches, pattern, ref, ref1, ref2;
      map = (ref = this.map) != null ? ref : (function(value) {
        return value;
      });
      if (_.isArray(this.pattern)) {
        ref1 = this.pattern;
        for (i = j = 0, len = ref1.length; j < len; i = ++j) {
          ref2 = ref1[i], pattern = ref2[0], match = ref2[1], m = ref2[2];
          matches = this.resource[i === this.pattern.length - 1 ? 'safeMatch' : 'match'](pattern);
          if (matches) {
            cb((m != null ? m : map)(matches[match]));
            return;
          }
        }
        return cb(null);
      } else {
        matches = this.resource[this["default"] != null ? 'match' : 'safeMatch'](this.pattern);
        if (matches) {
          return cb(map(matches[this.match]));
        } else if (this["default"] != null) {
          return cb(this["default"]);
        } else {
          return cb(null);
        }
      }
    };

    return PatternResourceScraper;

  })(ResourceScraper);
});

//# sourceMappingURL=PatternResourceScraper.js.map
