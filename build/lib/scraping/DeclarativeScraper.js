// Generated by CoffeeScript 1.10.0
define(function() {
  var DeclarativeScraper, Value;
  Value = (function() {
    function Value(name1, value1) {
      this.name = name1;
      this.value = value1;
    }

    return Value;

  })();
  return DeclarativeScraper = (function() {
    DeclarativeScraper.prototype.executeMatches = function(matches, subject) {
      var i, j, len, match, values;
      values = [];
      if (matches) {
        for (i = j = 0, len = matches.length; j < len; i = ++j) {
          match = matches[i];
          if (match.disabled) {
            continue;
          }
          values = values.concat(this.execute(match, subject, i));
        }
      }
      return values;
    };

    DeclarativeScraper.prototype.getPath = function() {
      var el, j, len, ref, results;
      ref = this.path;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        el = ref[j];
        results.push({
          index: el.index,
          type: el.type
        });
      }
      return results;
    };

    DeclarativeScraper.prototype.hasValue = function(obj, key) {
      return obj && key in obj && obj[key] !== null && obj[key] !== '';
    };

    DeclarativeScraper.prototype.executeMatch = function(el, matches) {
      var capture, group, r, ref, values;
      values = [];
      if (el.captures) {
        ref = el.captures;
        for (group in ref) {
          capture = ref[group];
          r = this.execute(capture, matches[parseInt(group)], group);
          if (r) {
            values = values.concat(r);
          }
        }
      }
      return this.processValue(el, values, matches);
    };

    DeclarativeScraper.prototype.processValue = function(el, values, matches, tieredMatches, subject) {
      var a, array, content, i, j, k, l, len, len1, len2, name, obj, part, parts, value;
      if (el.value) {
        name = el.value.name;
        if (this.hasValue(el.value, 'name') && matches) {
          name = name.replace(/\$(\d+):(\d+)/g, function(match, p1, p2) {
            return tieredMatches[parseInt(p1)][parseInt(p2)];
          });
          name = name.replace(/\$([a-z]*)(\d+)/g, function(match, flag, p1) {
            var value;
            value = matches[parseInt(p1)];
            if (flag === 'lc') {
              value = value.toLowerCase();
            }
            return value;
          });
        }
        if (this.hasValue(el.value, 'type')) {
          if (el.value.type === 'array') {
            array = [];
            for (j = 0, len = values.length; j < len; j++) {
              value = values[j];
              array.push(value.value);
            }
            return [new Value(name, array)];
          } else if (el.value.type === 'object') {
            obj = {};
            for (k = 0, len1 = values.length; k < len1; k++) {
              value = values[k];
              if (!value.name) {
                console.debug(el, values);
                throw new Error('ValueMustHaveName');
              }
              a = obj;
              parts = value.name.split('.');
              for (i = l = 0, len2 = parts.length; l < len2; i = ++l) {
                part = parts[i];
                if (i === parts.length - 1) {
                  a[part] = value.value;
                } else {
                  if (a[part] == null) {
                    a[part] = {};
                  }
                  a = a[part];
                }
              }
            }
            return [new Value(name, obj)];
          }
        } else if (this.hasValue(el.value, 'content')) {
          content = el.value.content;
          if (matches) {
            content = content.replace(/\$(\d+):(\d+)/g, function(match, p1, p2) {
              return tieredMatches[parseInt(p1)][parseInt(p2)].replace(/"/g, '\\"');
            });
            content = content.replace(/\$([a-z]*)(\d+)/g, function(match, flag, p1) {
              value = matches[parseInt(p1)].replace(/"/g, '\\"');
              if (flag === 'lc') {
                value = value.toLowerCase();
              }
              return value;
            });
          }
          return [new Value(name, JSON.parse(content))];
        } else if (matches && this.hasValue(el.value, 'capture')) {
          return [new Value(name, matches[el.value.capture])];
        } else if (this.hasValue(el.value, 'name')) {
          if (values.length) {
            values[0].name = name;
          } else {
            return [new Value(name, subject)];
          }
        }
      }
      return values;
    };

    DeclarativeScraper.prototype.execute = function(el, subject, index) {
      var capture, caseObj, e, error, error1, error2, error3, globalMatch, globalMatches, group, i, j, k, l, len, len1, len2, match, matches, ref, ref1, ref2, regExp, retVal, tieredMatches, value, values;
      if (index == null) {
        index = 0;
      }
      retVal = null;
      if (el.type || el.pattern) {
        if (el.type == null) {
          el.type = 'Match';
        }
        this.path.push({
          type: 'match',
          index: index,
          el: el
        });
        switch (el.type) {
          case 'Match':
            regExp = new RegExp(el.pattern);
            matches = subject.match(regExp);
            if (matches) {
              values = [];
              if (el.captures) {
                try {
                  ref = el.captures;
                  for (group in ref) {
                    capture = ref[group];
                    values = values.concat(this.execute(capture, matches[parseInt(group)], group));
                  }
                } catch (error) {
                  e = error;
                  if (el.optional && e.message === 'FailedRequirement') {
                    retVal = [];
                  } else {
                    throw e;
                  }
                }
              }
              retVal = this.processValue(el, values, matches);
            } else if (el.optional) {
              retVal = [];
            } else {
              throw new Error('FailedRequirement');
            }
            break;
          case 'MatchAll':
            regExp = new RegExp(el.pattern);
            globalMatches = subject.match(new RegExp(el.pattern, 'g'));
            tieredMatches = [];
            if (globalMatches) {
              values = [];
              try {
                for (i = j = 0, len = globalMatches.length; j < len; i = ++j) {
                  globalMatch = globalMatches[i];
                  matches = globalMatch.match(regExp);
                  tieredMatches[i] = matches;
                  values = values.concat(this.executeMatch({
                    type: 'Match',
                    captures: el.match.captures,
                    value: el.match.value
                  }, matches));
                }
              } catch (error1) {
                e = error1;
                if (el.optional && e.message === 'FailedRequirement') {
                  retVal = [];
                } else {
                  throw e;
                }
              }
              retVal = this.processValue(el, values, globalMatches, tieredMatches);
            } else if (el.optional) {
              retVal = [];
            } else {
              throw new Error('FailedRequirement');
            }
            break;
          case 'Or':
            ref1 = el.matches;
            for (i = k = 0, len1 = ref1.length; k < len1; i = ++k) {
              match = ref1[i];
              if (match.disabled) {
                continue;
              }
              try {
                value = this.execute(match, subject, i);
                if (value.length) {
                  retVal = this.processValue(el, value, null, null, subject);
                  break;
                }
              } catch (error2) {
                e = error2;
                if (e.message !== 'FailedRequirement') {
                  throw e;
                } else {
                  this.path.pop();
                }
              }
            }
            if (!retVal) {
              if (el.optional) {
                retVal = [];
              } else {
                throw new Error('FailedRequirement');
              }
            }
            break;
          case 'Switch':
            value = null;
            try {
              ref2 = el.cases;
              for (i = l = 0, len2 = ref2.length; l < len2; i = ++l) {
                caseObj = ref2[i];
                if (caseObj.disabled) {
                  continue;
                }
                if (this.hasValue(caseObj, 'pattern') && subject.match(new RegExp(caseObj.pattern)) || !this.hasValue(caseObj, 'pattern')) {
                  value = this.processValue(caseObj, this.executeMatches(caseObj.matches, subject), null, null, subject);
                  break;
                }
              }
            } catch (error3) {
              e = error3;
              if (el.optional && e.message === 'FailedRequirement') {
                retVal = [];
              } else {
                throw e;
              }
            }
            value = this.processValue(el, value, null, null, subject);
            if (value.length) {
              retVal = value;
            } else if (el.optional) {
              retVal = [];
            } else {
              throw new Error('FailedRequirement');
            }
            break;
          case 'Count':
            regExp = new RegExp(el.pattern, 'g');
            matches = subject.match(regExp);
            if (matches) {
              retVal = [new Value(null, matches.length)];
            } else {
              retVal = [];
            }
        }
      } else {
        this.path.push({
          type: 'text',
          index: index
        });
        values = this.executeMatches(el.matches, subject);
        retVal = this.processValue(el, values, null, null, subject);
      }
      if (retVal === null) {
        throw new Error('return is null');
      }
      this.path.pop();
      return retVal;
    };

    function DeclarativeScraper(scraper) {
      this.scraper = scraper;
      this.path = [];
    }

    DeclarativeScraper.prototype.scrape = function(subject) {
      return this.execute(this.scraper, subject);
    };

    return DeclarativeScraper;

  })();
});

//# sourceMappingURL=DeclarativeScraper.js.map
