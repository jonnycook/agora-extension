// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['./PropertyScraper', './ResourceFetcher', './resourceScrapers/DeclarativeResourceScraper', 'underscore'], function(PropertyScraper, ResourceFetcher, DeclarativeResourceScraper, _) {
  var ProductScraper, ProductSid;
  ProductSid = (function(superClass) {
    extend(ProductSid, superClass);

    function ProductSid(value1) {
      this.value = value1;
      String.call(this, this.value);
    }

    ProductSid.prototype.toString = function() {
      return this.value;
    };

    ProductSid.prototype.valueOf = function() {
      return this.value;
    };

    return ProductSid;

  })(String);
  return ProductScraper = (function() {
    ProductScraper.declarativeProductScraper = function(name, opts) {
      var DeclarativeProductScraper, i, len, prop, properties, ref, ref1;
      properties = {};
      ref = ['title', 'image', 'price', 'more', 'rating', 'ratingCount', 'reviews'];
      for (i = 0, len = ref.length; i < len; i++) {
        prop = ref[i];
        properties[prop] = {
          resource: opts.resource,
          scraper: DeclarativeResourceScraper(name, prop, (ref1 = opts.mapping) != null ? ref1[prop] : void 0)
        };
      }
      return DeclarativeProductScraper = (function(superClass) {
        extend(DeclarativeProductScraper, superClass);

        function DeclarativeProductScraper() {
          return DeclarativeProductScraper.__super__.constructor.apply(this, arguments);
        }

        DeclarativeProductScraper.prototype.resources = opts.resources;

        DeclarativeProductScraper.prototype.parseSid = opts.parseSid;

        DeclarativeProductScraper.prototype.properties = properties;

        return DeclarativeProductScraper;

      })(ProductScraper);
    };

    function ProductScraper(site, productSid, background) {
      var fetcher, properties, property, resource, resources, scraper;
      this.site = site;
      this.background = background;
      this.productSid = new ProductSid(productSid);
      if (this.parseSid) {
        _.extend(this.productSid, this.parseSid(productSid));
      }
      if (this.resources) {
        resources = this.resources;
        this.resources = {};
        for (resource in resources) {
          fetcher = resources[resource];
          this.resources[resource] = new ResourceFetcher(this.productSid, fetcher);
          this.resources[resource].site = this.site;
          this.resources[resource].background = this.background;
          this.resources[resource].scraper = this;
        }
      }
      if (this.properties) {
        properties = this.properties;
        this.properties = {};
        for (property in properties) {
          scraper = properties[property];
          if (_.isFunction(scraper)) {
            this.properties[property] = {
              scrape: scraper,
              productSid: this.productSid
            };
          } else {
            this.properties[property] = new PropertyScraper(this.productSid, this.site, scraper);
            this.properties[property].productScraper = this;
            this.properties[property].background = this.background;
            this.properties[property].propertyName = property;
          }
        }
      }
    }

    ProductScraper.prototype.resource = function(resourceName) {
      var resource;
      resource = this.resources[resourceName];
      if (resource) {
        return resource;
      } else {
        throw new Error("no resource '" + resourceName + "'");
      }
    };

    ProductScraper.prototype.versionString = function() {
      var i, len, parts, ref, ref1, scraper;
      parts = [(ref = this.version) != null ? ref : 0];
      if (this.background.declarativeScrapers) {
        ref1 = this.background.declarativeScrapers;
        for (i = 0, len = ref1.length; i < len; i++) {
          scraper = ref1[i];
          if (scraper.site === this.site.name) {
            parts.push(scraper.timestamp);
          }
        }
      }
      return parts.join(';');
    };

    ProductScraper.prototype.propertyScraper = function(propertyName) {
      return this.properties[propertyName];
    };

    ProductScraper.prototype.scrapeProperty = function(property, cb) {
      var propertyScraper;
      if (env.core) {
        return cb();
      } else {
        propertyScraper = this.propertyScraper(property);
        if (propertyScraper) {
          return propertyScraper.scrape(cb);
        } else {
          return cb();
        }
      }
    };

    ProductScraper.prototype.canScrapeProperty = function(property) {
      return this.propertyScraper(property);
    };

    ProductScraper.prototype.scrape = function(properties, cb) {
      var collectValue, i, len, num, prop, results, values;
      values = {};
      num = 0;
      collectValue = (function(_this) {
        return function(prop, value) {
          values[prop] = value;
          if (++num === properties.length) {
            return cb(values);
          }
        };
      })(this);
      results = [];
      for (i = 0, len = properties.length; i < len; i++) {
        prop = properties[i];
        results.push((function(_this) {
          return function(prop) {
            return _this.scrapeProperty(prop, function(value) {
              return collectValue(prop, value);
            });
          };
        })(this)(prop));
      }
      return results;
    };

    return ProductScraper;

  })();
});

//# sourceMappingURL=ProductScraper.js.map
