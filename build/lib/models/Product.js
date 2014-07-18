// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['model/Model', 'Site', 'model/ModelInstance', 'util'], function(Model, Site, ModelInstance, util) {
  var Product, ProductInstance, ProductRetriever;
  ProductRetriever = (function() {
    ProductRetriever.cache = {};

    ProductRetriever.get = function(Product, input) {
      var key, retriever;
      key = null;
      if (typeof input === 'number' || typeof input === 'string') {
        key = input;
      } else if (input.productSid) {
        key = "" + input.siteName + "/" + input.productSid;
      } else if (input.productUrl) {
        key = input.productUrl;
      } else {
        key = "" + input.pageUrl + "|" + input.linkUrl;
      }
      retriever = this.cache[key];
      if (!retriever) {
        retriever = this.cache[key] = new ProductRetriever(Product, input);
      }
      return retriever;
    };

    function ProductRetriever(Product, input) {
      this.Product = Product;
      this.input = input;
      this.subscribers = [];
      if (this.input.productSid) {
        this.product = Product.find({
          siteName: this.input.siteName,
          productSid: this.input.productSid
        });
      } else if (this.input.retrievalId) {
        this.product = Product.find({
          retrievalId: this.input.retrievalId
        });
      }
    }

    ProductRetriever.prototype._retrieve = function(method) {
      this.retrieving = true;
      return method((function(_this) {
        return function(product) {
          var subscriber, _i, _len, _ref;
          _this.product = product;
          if (_this.subscribers.length) {
            _ref = _this.subscribers;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              subscriber = _ref[_i];
              subscriber(product);
            }
            delete _this.subscribers;
          }
          return _this.retrieving = false;
        };
      })(this));
    };

    ProductRetriever.prototype.withProduct = function(cb, create) {
      if (create == null) {
        create = true;
      }
      if (this.product) {
        return cb(this.product);
      } else {
        this.subscribers.push(cb);
        if (create && !this.retrieving) {
          if (typeof this.input === 'number' || typeof this.input === 'string') {
            return this._retrieve((function(_this) {
              return function(cb) {
                var product;
                product = _this.Product.withId(_this.input);
                _this.Product.update(product);
                return cb(product);
              };
            })(this));
          } else if (this.input.productSid) {
            return this._retrieve((function(_this) {
              return function(cb) {
                return cb(_this.Product.getBySid(_this.input.siteName, _this.input.productSid, _this.input));
              };
            })(this));
          } else if (this.input.retrievalId) {
            return this._retrieve((function(_this) {
              return function(cb) {
                var product;
                product = _this.Product.find(function(p) {
                  return p.get('retrievalId') === _this.input.retrievalId;
                });
                if (product) {
                  return cb(product);
                } else {
                  return _this.Product.getFromUrl(_this.input.productUrl, _this.input, cb, _this.input.retrievalId);
                }
              };
            })(this));
          } else if (this.input.productUrl) {
            return this._retrieve((function(_this) {
              return function(cb) {
                return _this.Product.getFromUrl(_this.input.productUrl, _this.input, cb);
              };
            })(this));
          } else {
            return this._retrieve((function(_this) {
              return function(cb) {
                return _this.Product.explorativeGet(_this.input.linkUrl, _this.input.pageUrl, _this.input, cb);
              };
            })(this));
          }
        } else if (!this.retrieving) {
          return cb(null);
        }
      }
    };

    return ProductRetriever;

  })();
  ProductInstance = (function(_super) {
    __extends(ProductInstance, _super);

    function ProductInstance() {
      return ProductInstance.__super__.constructor.apply(this, arguments);
    }

    ProductInstance.prototype.instanceMethods = ['update', 'displayValue', 'getDisplayValue', 'site', 'interface', 'productId'];

    ProductInstance.prototype.productId = function() {
      return this.get('id');
    };

    ProductInstance.prototype.site = function() {
      return Site.site(this.get('siteName'));
    };

    ProductInstance.prototype["interface"] = function(cb) {
      return this.model.siteProduct(this, cb);
    };

    ProductInstance.prototype.getDisplayValue = function(property) {
      var value;
      value = this.get(property);
      if (value === this.model.errorMap[property]) {
        switch (property) {
          case 'ratingCount':
            return 'error';
          case 'image':
            return agora.background.getResourceUrl('resources/images/agorabelt-512.png');
          default:
            return '(error)';
        }
      } else {
        switch (property) {
          case 'price':
            return this.get('displayPrice');
          case 'ratingCount':
            return util.numberWithCommas(value);
          default:
            return value;
        }
      }
    };

    ProductInstance.prototype.displayValue = function(property) {
      return (function(_this) {
        return function(value) {
          return _this.getDisplayValue(property);
        };
      })(this);
    };

    ProductInstance.prototype.update = function() {
      return this.model.update(this);
    };

    ProductInstance.prototype.retrievers = {
      more: function(cb) {
        var site;
        site = Site.site(this._get('siteName'));
        return site.productScraper(this.model.background, this.get('productSid'), (function(_this) {
          return function(scraper) {
            return scraper.scrapeProperty('more', function(value, error) {
              if (error) {
                return cb({});
              } else {
                return cb(value);
              }
            });
          };
        })(this));
      },
      reviews: function(cb) {
        var site;
        site = Site.site(this._get('siteName'));
        return site.productScraper(this.model.background, this.get('productSid'), (function(_this) {
          return function(scraper) {
            if (scraper.canScrapeProperty('reviews')) {
              return scraper.scrapeProperty('reviews', cb);
            } else {
              return cb();
            }
          };
        })(this));
      },
      offers: function(cb) {
        var getOffers, site;
        site = Site.site(this._get('siteName'));
        if (site.config.query) {
          getOffers = (function(_this) {
            return function() {
              var query;
              query = site.config.query(_this);
              query.site = _this._get('siteName');
              return _this.model.background.httpRequest("" + _this.model.background.apiRoot + "products.php", {
                data: query,
                cb: function(response) {
                  return cb((response.products === '' ? null : response.products));
                }
              });
            };
          })(this);
          if (!site.config.hasMore || this.get('more')) {
            return getOffers();
          } else {
            return this.field('more').observe((function(_this) {
              return function(mutation) {
                if (mutation.value) {
                  _this.field('more').stopObserving(arguments.callee);
                  return getOffers();
                }
              };
            })(this));
          }
        } else {
          console.debug('no offers');
          return cb();
        }
      }
    };

    return ProductInstance;

  })(ModelInstance);
  return Product = (function(_super) {
    __extends(Product, _super);

    Product.prototype.errorMap = {
      title: 'AGORA_ERROR',
      image: 'AGORA_ERROR',
      price: 'AGORA_ERROR',
      rating: -1,
      ratingCount: 999999999
    };

    function Product() {
      Product.__super__.constructor.apply(this, arguments);
      this.ModelInstance = ProductInstance;
    }

    Product.prototype.init = function() {
      return this._list.observe((function(_this) {
        return function(mutation) {
          var instance;
          if (mutation.type === 'insertion') {
            instance = mutation.value;
            if (!instance.get('image')) {
              return instance.update();
            }
          }
        };
      })(this));
    };

    Product.prototype.update = function(product) {
      var site;
      if (!env.core) {
        site = Site.site(product.get('siteName'));
        return site.productScraper(this.background, product.get('productSid'), (function(_this) {
          return function(scraper) {
            var allProperties, count, errors, properties, property, version, _i, _j, _len, _len1, _results;
            version = scraper.versionString();
            allProperties = ['title', 'price', 'image'];
            if (__indexOf.call(site.features, 'rating') >= 0) {
              allProperties = allProperties.concat(['rating', 'ratingCount']);
            }
            properties = [];
            if (product.get('scraper_version') !== version) {
              properties = allProperties;
            } else {
              for (_i = 0, _len = allProperties.length; _i < _len; _i++) {
                property = allProperties[_i];
                if (product._get(property) == null) {
                  properties.push(property);
                }
              }
            }
            product.retrieve('more');
            if (!Product.node) {
              if (__indexOf.call(site.features, 'reviews') >= 0) {
                product.retrieve('reviews');
              }
              if (__indexOf.call(site.features, 'offers') >= 0) {
                product.retrieve('offers');
              }
            }
            if (properties.length) {
              product.set('last_scraped_at', parseInt(new Date().getTime() / 1000));
              product.set('scraper_version', version);
              count = properties.length;
              errors = 0;
              product.set('status', 1);
              _results = [];
              for (_j = 0, _len1 = properties.length; _j < _len1; _j++) {
                property = properties[_j];
                _results.push((function(property) {
                  return scraper.scrapeProperty(property, function(value, error) {
                    if (error) {
                      ++errors;
                      product.set(property, _this.errorMap[property]);
                    } else {
                      product.set(property, value);
                    }
                    if (!--count) {
                      if (errors) {
                        return product.set('status', 2);
                      } else {
                        return product.set('status', 3);
                      }
                    }
                  });
                })(property));
              }
              return _results;
            }
          };
        })(this));
      }
    };

    Product.prototype.getBySid = function(siteName, productSid, context) {
      var product, site;
      console.log("" + siteName + " " + productSid);
      product = this.find((function(_this) {
        return function(p) {
          return p._get('siteName') === siteName && p._get('productSid') === productSid;
        };
      })(this));
      site = Site.site(siteName);
      if (!product) {
        product = this.add({
          siteName: siteName,
          productSid: productSid,
          image: context != null ? context.image : void 0,
          retrievalId: context != null ? context.retrievalId : void 0,
          status: 0
        });
      }
      this.update(product);
      return product;
    };

    Product.prototype.getFromUrl = function(url, context, cb, retrievalId) {
      var site;
      site = Site.siteForUrl(url);
      return site.productSid(this.background, url, ((function(_this) {
        return function(productSid) {
          if (productSid) {
            return cb(_this.getBySid(site.name, productSid, context));
          } else {
            throw new Error("failed to get sid from " + url);
            return cb();
          }
        };
      })(this)), retrievalId);
    };

    Product.prototype.explorativeGet = function(linkUrl, pageUrl, context, cb) {
      if (linkUrl) {
        return this.background.httpRequest(linkUrl, {
          cb: (function(_this) {
            return function(response, extra) {
              if (extra.header('Content-Type').match(/^text\/html/)) {
                return _this.getFromUrl(linkUrl, context, cb);
              } else {
                return _this.getFromUrl(pageUrl, context, cb);
              }
            };
          })(this)
        });
      } else {
        return this.getFromUrl(pageUrl, context, cb);
      }
    };

    Product.prototype.scraper = function(input, cb) {
      return this.resolveInput(input, (function(_this) {
        return function(input) {
          var site;
          site = Site.site(input.siteName);
          return site.productScraper(_this.background, input.productSid, cb);
        };
      })(this));
    };

    Product.prototype.resolveInput = function(input, cb) {
      var site;
      if (input.siteName && input.productSid) {
        return cb(input);
      } else if (input.productUrl) {
        site = Site.siteForUrl(input.productUrl);
        return site.productSid(this.background, input.productUrl, (function(_this) {
          return function(productSid) {
            return cb({
              siteName: site.name,
              productSid: productSid
            });
          };
        })(this));
      } else {
        throw new Error("invalid input");
      }
    };

    Product.prototype.get = function(input, cb, create) {
      var retriever;
      if (create == null) {
        create = true;
      }
      retriever = ProductRetriever.get(this, input);
      return retriever.withProduct(cb, create);
    };

    Product.prototype.siteProduct = function(product, cb) {
      var site;
      site = Site.site(product.get('siteName'));
      return site.product(this.background, product, cb);
    };

    Product.prototype.images = function(product, cb) {
      return this.siteProduct(product, function(siteProduct) {
        if (siteProduct) {
          return siteProduct.images(cb);
        } else {
          return cb();
        }
      });
    };

    return Product;

  })(Model);
});

//# sourceMappingURL=Product.map