// Generated by CoffeeScript 1.10.0
var $, CacheManager, fs, request, requirejs, urlUtil, util,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

requirejs = require('requirejs');

requirejs.config({
  nodeRequire: require,
  baseUrl: __dirname + "/../lib/",
  paths: {
    underscore: '../../libs/lodash.min',
    text: '../../libs/text'
  }
});

request = require('request');

$ = {
  ajax: require('najax')
};

CacheManager = require('./CacheManager');

util = require('util');

urlUtil = require('url');

fs = require('fs');

requirejs(['Background', 'Site', 'underscore', 'models/init'], function(Background, Site, _, initModels) {
  var NodeBackground, Product, background, db, fn, i, j, len, len1, modelManager, product, products, ref, ref1, results, site, siteName;
  NodeBackground = (function(superClass) {
    extend(NodeBackground, superClass);

    function NodeBackground(opts) {
      NodeBackground.__super__.constructor.apply(this, arguments);
      this.cache = opts.useCache;
    }

    NodeBackground.prototype.onRequest = function() {};

    NodeBackground.prototype._httpGet = function(url, opts) {
      console.log('start', url);
      return $.ajax(url, {
        type: opts.method,
        data: opts.data,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.72 Safari/537.36'
        },
        success: (function(_this) {
          return function(response, status) {
            fs.writeFileSync('out.html', url + "\n" + response);
            return typeof opts.cb === "function" ? opts.cb(response, {
              status: status,
              header: function(name) {
                return xhr.getResponseHeader(name);
              }
            }) : void 0;
          };
        })(this),
        error: function() {
          return console.log('error', url);
        },
        complete: (function(_this) {
          return function(xhr, status) {
            var redirectUrl;
            if (status === 'error') {
              if ((xhr.status + '')[0] === '3') {
                redirectUrl = urlUtil.resolve(url, xhr.getResponseHeader('Location'));
                return _this._httpGet(redirectUrl, opts);
              }
            }
          };
        })(this),
        dataType: opts.dataType,
        error: opts.error
      });
    };

    NodeBackground.prototype.require = function(libs, cb) {
      return requirejs(libs, cb);
    };

    NodeBackground.prototype.httpRequest = function(url, opts) {
      if (opts == null) {
        opts = {};
      }
      if (this.cache) {
        return this.cache.putThrough({
          name: url,
          cb: opts.cb,
          get: (function(_this) {
            return function(sendValue) {
              var cb;
              cb = opts.cb;
              opts.cb = function(response) {
                _this.cache.cacheResponse(url, response);
                return sendValue(response);
              };
              return _this._httpGet(url, opts);
            };
          })(this)
        });
      } else {
        return this._httpGet(url, opts);
      }
    };

    return NodeBackground;

  })(Background);
  background = new NodeBackground({
    useCache: null
  });
  ref = initModels(background), db = ref.db, modelManager = ref.modelManager;
  Product = modelManager.getModel('Product');
  Product.node = true;
  if (process.argv[2]) {
    site = Site.site(process.argv[2]);
    switch (process.argv[3]) {
      case 'product':
        if (process.argv[5]) {
          Product.siteProduct(Product.getBySid(site.name, process.argv[4]), function(siteProduct) {
            return siteProduct.property([process.argv[5]], function(property) {
              return console.log(property);
            });
          });
        } else {
          site.productScraper(background, process.argv[4], function(scraper) {
            return scraper.scrape(['more'], function(properties) {
              return console.log(properties);
            });
          });
        }
        break;
      case 'test':
        site.productScraperClass(background, function(ProductScraper) {
          var i, len, ref1, results, sid;
          if (ProductScraper.testProducts) {
            ref1 = ProductScraper.testProducts;
            results = [];
            for (i = 0, len = ref1.length; i < len; i++) {
              sid = ref1[i];
              results.push(site.productScraper(background, sid, function(scraper) {
                var properties;
                properties = ['price', 'title', 'image', 'more'];
                if (indexOf.call(site.features, 'reviews') >= 0) {
                  properties.push('reviews');
                }
                return scraper.scrape(properties, function(values) {
                  return console.log(scraper.productSid + " " + values.title);
                });
              }));
            }
            return results;
          }
        });
    }
  } else {
    ref1 = ['Amazon', 'Zappos'];
    fn = function(site) {
      return site.productScraperClass(background, function(ProductScraper) {
        var j, len1, ref2, results, sid;
        if (ProductScraper.testProducts) {
          ref2 = ProductScraper.testProducts;
          results = [];
          for (j = 0, len1 = ref2.length; j < len1; j++) {
            sid = ref2[j];
            results.push(site.productScraper(background, sid, function(scraper) {
              var properties;
              properties = ['price', 'title', 'image'];
              if (indexOf.call(site.features, 'reviews') >= 0) {
                properties.push('reviews');
              }
              return scraper.scrape(properties, function(values) {
                return console.log(scraper.productSid + " " + values.title);
              });
            }));
          }
          return results;
        }
      });
    };
    for (i = 0, len = ref1.length; i < len; i++) {
      siteName = ref1[i];
      site = Site.site(siteName);
      fn(site);
      console.log('done');
    }
  }
  return;
  products = [];
  if (process.argv[2]) {
    products.push({
      site: process.argv[2],
      sid: process.argv[3]
    });
  } else {
    products = [
      {
        site: 'Newegg',
        sid: 'N82E16824236174'
      }
    ];
  }
  results = [];
  for (j = 0, len1 = products.length; j < len1; j++) {
    product = products[j];
    results.push((function(product) {
      return Site.site(product.site).productScraper(background, product.sid, function(scraper) {
        return scraper.scrape(['image'], function(properties) {
          return console.log(properties);
        });
      });
    })(product));
  }
  return results;
});

//# sourceMappingURL=node.js.map
