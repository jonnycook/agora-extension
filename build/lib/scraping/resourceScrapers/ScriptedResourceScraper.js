// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['underscore', '../ResourceScraper', 'BlockRunner', '../DeclarativeScraper'], function(_, ResourceScraper, BlockRunner, DeclarativeScraper) {
  var ScriptedResourceScraper;
  return ScriptedResourceScraper = (function(superClass) {
    extend(ScriptedResourceScraper, superClass);

    function ScriptedResourceScraper(script) {
      this.script = script;
      if (this === window) {
        return ResourceScraper(arguments);
      }
    }

    ScriptedResourceScraper.prototype.value = function(arg) {
      if (_.isUndefined(arg)) {
        return this.vCont.value;
      } else if (typeof arg === 'object' && !_.isArray(arg)) {
        if (typeof this.vCont.value !== 'object') {
          this.vCont.value = {};
        }
        return _.extend(this.vCont.value, arg);
      } else {
        return this.vCont.value = arg;
      }
    };

    ScriptedResourceScraper.prototype.scrape = function(cb) {
      var A, a;
      this.vCont = {};
      A = function() {};
      A.prototype = this;
      a = new A;
      _.extend(a, BlockRunner.prototype);
      BlockRunner.call(a, this.script);
      a.onDone((function(_this) {
        return function() {
          return cb(_this.vCont.value);
        };
      })(this));
      return a.exec();
    };

    ScriptedResourceScraper.prototype.get = function(url, cb, fail) {
      if (fail == null) {
        fail = null;
      }
      return this.propertyScraper.productScraper.background.httpRequest(url, {
        method: 'get',
        dataType: 'text',
        cb: (function(_this) {
          return function(responseText, response) {
            if (response.status === 200 || response.status === 'success') {
              return cb.call(_this, responseText);
            } else {
              if (fail) {
                return fail(response);
              } else {
                throw new Error(url + ": http status " + response.status);
              }
            }
          };
        })(this)
      });
    };

    ScriptedResourceScraper.prototype.post = function(url, data, cb) {
      return this.propertyScraper.productScraper.background.httpRequest(url, {
        method: 'post',
        dataType: 'text',
        data: data,
        cb: (function(_this) {
          return function(responseText, response) {
            if (response.status === 200 || response.status === 'success') {
              return cb.call(_this, responseText);
            } else {
              throw new Error(url + ": http status " + response.status);
            }
          };
        })(this)
      });
    };

    ScriptedResourceScraper.prototype.matchAll = function(string, pattern, group) {
      var i, j, len, len1, match, matches, results, results1;
      if (group == null) {
        group = false;
      }
      matches = string.match(new RegExp((_.isString(pattern) ? pattern : pattern.source), 'g'));
      if (matches) {
        if (group === false) {
          results = [];
          for (i = 0, len = matches.length; i < len; i++) {
            match = matches[i];
            results.push(match.match(pattern));
          }
          return results;
        } else {
          results1 = [];
          for (j = 0, len1 = matches.length; j < len1; j++) {
            match = matches[j];
            results1.push(match.match(pattern)[group]);
          }
          return results1;
        }
      } else {
        return [];
      }
    };

    ScriptedResourceScraper.prototype.getResource = function(resourceName, cb) {
      var resourceFetcher;
      resourceFetcher = this.propertyScraper.productScraper.resource(resourceName);
      return resourceFetcher.fetch((function(_this) {
        return function(resource) {
          return cb.call(_this, resource);
        };
      })(this));
    };

    ScriptedResourceScraper.prototype.declarativeScraper = function(name, property, subject) {
      var e, error, i, len, ref, result, scraper, scrapers;
      if (property == null) {
        property = this.propertyScraper.propertyName;
      }
      if (subject == null) {
        subject = null;
      }
      scrapers = this.propertyScraper.productScraper.background.declarativeScrapers;
      for (i = 0, len = scrapers.length; i < len; i++) {
        scraper = scrapers[i];
        if (scraper.site === this.site.name && scraper.name === name) {
          if (scraper.properties[property]) {
            scraper = new DeclarativeScraper(scraper.properties[property]);
            try {
              result = (ref = scraper.scrape(subject != null ? subject : this.resource)[0]) != null ? ref.value : void 0;
              if (this.map) {
                return this.map(result);
              } else {
                return result;
              }
            } catch (error) {
              e = error;
              e.info = {
                path: scraper.getPath()
              };
              throw e;
            }
          } else {
            return null;
          }
        }
      }
      throw new Error("failed to find scraper for " + this.site.name + " " + this.name);
    };

    return ScriptedResourceScraper;

  })(ResourceScraper);
});

//# sourceMappingURL=ScriptedResourceScraper.js.map
