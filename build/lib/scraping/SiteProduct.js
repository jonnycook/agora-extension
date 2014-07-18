// Generated by CoffeeScript 1.7.1
define(['taxonomy', 'util', 'underscore'], function(taxonomy, util, _) {
  var SiteProduct;
  return SiteProduct = (function() {
    function SiteProduct(product) {
      this.product = product;
    }

    SiteProduct.prototype.properties = function(properties, cb) {};

    SiteProduct.prototype.usedProperties = function(type, cb) {
      var count, properties, property, usedProperties, _i, _len, _results;
      properties = taxonomy.properties(type);
      count = properties.length;
      if (count) {
        usedProperties = [];
        _results = [];
        for (_i = 0, _len = properties.length; _i < _len; _i++) {
          property = properties[_i];
          _results.push((function(_this) {
            return function(property) {
              return _this.property(property, function(value) {
                if (value !== void 0) {
                  usedProperties.push(property);
                }
                if (!--count) {
                  return cb(usedProperties);
                }
              });
            };
          })(this)(property));
        }
        return _results;
      } else {
        return cb([]);
      }
    };

    SiteProduct.prototype.property = function(path, cb) {
      var func, parts, _ref, _ref1;
      parts = path.split('.');
      func = (_ref = this.types) != null ? (_ref1 = _ref[parts[0]]) != null ? _ref1[parts[1]] : void 0 : void 0;
      if (func) {
        return func.call(this, cb);
      } else {
        return cb();
      }
    };

    SiteProduct.prototype.reviews = function(cb) {
      return this.product["with"]('reviews', function(reviews) {
        return cb({
          reviews: reviews != null ? reviews : []
        });
      });
    };

    SiteProduct.prototype.genWidgets = function(obj, widgetDefs) {
      var dataType, name, o, parts, prop, type, value, widget, widgetDef, widgets, _ref;
      widgets = [];
      for (prop in widgetDefs) {
        widgetDef = widgetDefs[prop];
        value = (function() {
          var _i, _len;
          if (widgetDef.obj) {
            return widgetDef.obj;
          } else {
            parts = prop.split('.');
            o = obj;
            for (_i = 0, _len = parts.length; _i < _len; _i++) {
              name = parts[_i];
              o = o[name];
            }
            return o;
          }
        })();
        if (value == null) {
          continue;
        }
        dataType = _.isString(value) ? 'string' : _.isArray(value) ? 'array' : _.isPlainObject(value) ? 'object' : void 0;
        type = (function() {
          if (prop === 'reviews') {
            return 'Reviews';
          } else {
            switch (dataType) {
              case 'string':
                return 'html';
              case 'array':
                return 'List';
              case 'object':
                return 'Details';
            }
          }
        })();
        if (type === 'Reviews') {
          if (value.length === 0) {
            continue;
          }
        }
        if (_.isString(widgetDef)) {
          widgetDef = {
            title: widgetDef,
            type: type
          };
        }
        widget = {
          type: (_ref = widgetDef.type) != null ? _ref : type,
          data: {
            title: widgetDef.title
          }
        };
        if (widget.type === 'html') {
          if (widgetDef.stripHtml == null) {
            widgetDef.stripHtml = true;
          }
          widget.data.maxHeight = widgetDef.maxHeight != null ? widgetDef.maxHeight : 'none';
        } else if (widget.type === 'Reviews') {
          if (widgetDef.maxHeight != null) {
            widget.data.maxHeight = widgetDef.maxHeight;
          }
          if (widgetDef.count != null) {
            widget.data.count = widgetDef.count;
          }
        }
        if (widget.type === 'html' && widgetDef.stripHtml) {
          widget.data.content = util.stripHtml(value, null, this.baseUrl);
        } else {
          if (widget.type === 'Reviews') {
            value = _.map(value, (function(_this) {
              return function(review) {
                var mapping, newReview, p, _ref1;
                newReview = _.clone(review);
                newReview.url = util.url(newReview.url);
                if (widgetDef.map) {
                  _ref1 = widgetDef.map;
                  for (p in _ref1) {
                    mapping = _ref1[p];
                    if (_.isFunction(mapping)) {
                      newReview[p] = mapping(review);
                    } else {
                      newReview[p] = review[mapping];
                    }
                  }
                }
                newReview.review = util.stripHtml(newReview.review, null, _this.baseUrl);
                return newReview;
              };
            })(this));
          } else {
            if (widget.type === 'List') {
              value = _.map(value, (function(_this) {
                return function(v) {
                  return util.stripHtml(v, null, _this.baseUrl);
                };
              })(this));
            }
            if (widgetDef.map) {
              if (dataType === 'array') {
                value = _.map(value, widgetDef.map);
              } else if (dataType === 'string') {
                if (_.isString(widgetDef.map)) {
                  value = value[widgetDef.map];
                } else {
                  value = widgetDef.map(value);
                }
              }
            }
          }
          widget.data.content = value;
        }
        widgets.push(widget);
      }
      return widgets;
    };

    return SiteProduct;

  })();
});

//# sourceMappingURL=SiteProduct.map
