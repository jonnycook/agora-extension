// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['SiteInjector'],
    c: function() {
      var DataDrivenSiteInjector, doHandleOverlay, handleOverlay;
      doHandleOverlay = function(overlayEl, image, hide) {
        var down, event;
        if (hide == null) {
          hide = false;
        }
        $(overlayEl).unbind('.agora');
        down = false;
        event = null;
        return Q(overlayEl).bind('mousedown.agora', function(e) {
          down = true;
          Q('html').disableSelection();
          e.preventDefault();
          event = e;
          return true;
        }).bind('mouseup.agora', function() {
          down = false;
          return true;
        }).bind('mousemove.agora', function(e) {
          if (down) {
            down = false;
            if (hide) {
              Q(this).hide();
            }
            image.trigger(event);
            setTimeout(((function(_this) {
              return function() {
                return image.trigger(event);
              };
            })(this)), 100);
            return $('html').one('mouseup', (function(_this) {
              return function() {
                $('html').enableSelection();
                if (hide) {
                  return $(_this).show();
                }
              };
            })(this));
          }
        });
      };
      handleOverlay = function(overlayEl, image, hide) {
        if (hide == null) {
          hide = false;
        }
        return Q('body').delegate(overlayEl, 'mouseover', function() {
          return doHandleOverlay(overlayEl, image($(this)), hide);
        });
      };
      return DataDrivenSiteInjector = (function(superClass) {
        extend(DataDrivenSiteInjector, superClass);

        DataDrivenSiteInjector.productListing = {
          testProductLink: function(a) {
            return true;
          },
          productSid: function(href) {
            return this.parseUrl(href);
          },
          productData: function(href, a, img) {
            var productSid;
            productSid = this.productListing.productSid.call(this, href, a, img);
            if (productSid) {
              return {
                productSid: productSid
              };
            }
          }
        };

        DataDrivenSiteInjector.productPage = {
          productSid: function() {
            throw new Error('unimplemented');
          },
          test: function() {
            return $('meta[property="og:type"]').attr('content') === 'product';
          },
          waitFor: 'body',
          imgEl: null,
          productSid: function(href) {
            return this.parseUrl(document.location.href);
          }
        };

        function DataDrivenSiteInjector() {
          DataDrivenSiteInjector.__super__.constructor.apply(this, arguments);
          if (!_.isFunction(this.productListing)) {
            this.productListing = _.extend(_.clone(DataDrivenSiteInjector.productListing), this.productListing);
          }
          this.productPage = _.extend(_.clone(DataDrivenSiteInjector.productPage), this.productPage);
        }

        DataDrivenSiteInjector.prototype.run = function() {
          return this.initPage((function(_this) {
            return function() {
              var base, doInitProducts, initProducts, that;
              _this.shoppingBarView = new ShoppingBarView(_this.contentScript);
              Q(_this.shoppingBarView.el).appendTo(document.body);
              _this.shoppingBarView.represent();
              if (_.isFunction(_this.productListing)) {
                _this.productListing.call(_this);
              } else {
                if ((base = _this.productListing).image == null) {
                  base.image = _this.productListing.imgSelector;
                }
                if (_this.productListing.init) {
                  _this.productListing.init.call(_this);
                }
                if (_this.productListing.mode === 2) {
                  if (_this.productListing.overlay) {
                    handleOverlay(_this.productListing.overlay, _this.productListing.overlayImage);
                  }
                  doInitProducts = function(selector, params) {
                    var a, el, href, i, img, len, positionEl, productData, ref, results;
                    ref = $(selector);
                    results = [];
                    for (i = 0, len = ref.length; i < len; i++) {
                      el = ref[i];
                      img = params.image && params.image !== selector ? params.image($(el)) : el;
                      a = params.anchor ? params.anchor($(el)) : $(img).parents('a');
                      href = a.prop('href');
                      productData = params.productData.call(_this, href, a, $(img), $(el));
                      if (productData) {
                        positionEl = params.positionA ? a : params.position ? params.position($(el)) : img;
                        if (params.anchorProxy) {
                          doHandleOverlay(a, img);
                        }
                        _this.initProductEl(img, productData, {
                          overlay: false
                        });
                        if (params.forcePositioned) {
                          Q(a).css('position', 'relative');
                        }
                        results.push(_this.attachOverlay({
                          positionEl: $(positionEl),
                          attachEl: a,
                          productData: productData,
                          overlayZIndex: 9999,
                          position: params.overlayPosition
                        }));
                      } else {
                        results.push(void 0);
                      }
                    }
                    return results;
                  };
                  window.initProducts = initProducts = function() {
                    var base1, params, ref, results, selector;
                    if (typeof (base1 = _this.productListing).custom === "function") {
                      base1.custom();
                    }
                    if (_this.productListing.selectors) {
                      ref = _this.productListing.selectors;
                      results = [];
                      for (selector in ref) {
                        params = ref[selector];
                        results.push(doInitProducts(selector, params));
                      }
                      return results;
                    } else {
                      return doInitProducts(_this.productListing.image, _this.productListing);
                    }
                  };
                  $(initProducts);
                  Q(window).load(initProducts);
                  Q.setInterval(initProducts, 2000);
                  if (_this.productListing.image) {
                    that = _this;
                    Q('body').delegate(_this.productListing.image, 'mouseenter', function() {
                      var a, href, img, productData;
                      img = this;
                      a = $(img).parents('a');
                      href = a.prop('href');
                      productData = that.productListing.productData.call(that, href, a, $(img));
                      if (productData) {
                        return that.initProductEl(this, productData, {
                          overlay: false
                        });
                      }
                    });
                  }
                } else {
                  window.initProducts = initProducts = function() {
                    var a, contEl, href, i, img, imgEl, len, productSid, ref, results;
                    ref = $(_this.productListing.image);
                    results = [];
                    for (i = 0, len = ref.length; i < len; i++) {
                      img = ref[i];
                      a = $(img).parents('a');
                      href = a.prop('href');
                      productSid = _this.productListing.productSid.call(_this, href, a, $(img));
                      if (productSid) {
                        if (_this.productListing.container && $(img).parents(_this.productListing.container).length) {
                          contEl = $(img).parents(_this.productListing.container);
                          _this.initProductEl(contEl, {
                            productSid: productSid
                          }, {
                            image: false,
                            overlayZIndex: _this.productListing.overlayZIndex,
                            overlayPosition: _this.productListing.overlayPosition
                          });
                          results.push((function() {
                            var j, len1, ref1, results1;
                            ref1 = a.find('img');
                            results1 = [];
                            for (j = 0, len1 = ref1.length; j < len1; j++) {
                              imgEl = ref1[j];
                              results1.push(this.initProductEl(imgEl, {
                                productSid: productSid
                              }, {
                                overlay: false
                              }));
                            }
                            return results1;
                          }).call(_this));
                        } else {
                          results.push(_this.initProductEl(img, {
                            productSid: productSid
                          }, {
                            overlayPosition: _this.productListing.overlayPosition
                          }));
                        }
                      } else {
                        results.push(void 0);
                      }
                    }
                    return results;
                  };
                  $(initProducts);
                  $(window).load(initProducts);
                  Q.setInterval(initProducts, 2000);
                }
              }
              return $(function() {
                var base1, lastProductSid, overlay, overlayEl, ref, ref1, update;
                if ((ref = _this.productPage) != null ? typeof ref.test === "function" ? ref.test() : void 0 : void 0) {
                  console.debug('product page');
                  if (_this.productPage.initPage) {
                    _this.productPage.initPage.call(_this);
                  }
                  if (_this.productPage.mode === 2) {
                    if (_this.productPage.overlay) {
                      if ((base1 = _this.productPage).hideOverlay == null) {
                        base1.hideOverlay = true;
                      }
                      overlay = _this.productPage.overlay;
                      Q('body').delegate(overlay, 'mouseover', function() {
                        var down, event;
                        $(overlay).unbind('.agora');
                        down = false;
                        event = null;
                        return Q(overlay).bind('mousedown.agora', function(e) {
                          down = true;
                          Q('html').disableSelection();
                          e.preventDefault();
                          event = e;
                          return true;
                        }).bind('mouseup.agora', function() {
                          down = false;
                          return true;
                        }).bind('mousemove.agora', function(e) {
                          var el, i, len, ref1, selector;
                          if (down) {
                            down = false;
                            selector = _this.productPage.image;
                            ref1 = $(selector);
                            for (i = 0, len = ref1.length; i < len; i++) {
                              el = ref1[i];
                              _this.clearProductEl(el);
                              _this.initProductEl(el, {
                                productSid: _this.productPage.productSid.call(_this),
                                variant: _this.productPage.variant
                              }, {
                                overlay: false
                              });
                            }
                            return setTimeout((function() {
                              if (_this.productPage.hideOverlay) {
                                Q(overlay).hide();
                              }
                              console.debug($(selector));
                              $(selector).trigger(event);
                              return $('html').one('mouseup', function() {
                                $('html').enableSelection();
                                if (_this.productPage.hideOverlay) {
                                  return $(overlay).show();
                                }
                              });
                            }), 100);
                          }
                        });
                      });
                    }
                    if (_this.productPage.image) {
                      that = _this;
                      lastProductSid = null;
                      Q('body').delegate(_this.productPage.image, 'mouseenter', function() {
                        var img, productSid;
                        img = this;
                        productSid = that.productPage.productSid.call(that);
                        that.clearProductEl(this);
                        return that.initProductEl(this, {
                          productSid: productSid,
                          variant: that.productPage.variant
                        }, {
                          overlay: false
                        });
                      });
                    }
                    update = function() {
                      var ref1, ref2;
                      console.debug(_this.productPage.productSid.call(_this));
                      _this.removeOverlay($(_this.productPage.attach));
                      return _this.attachOverlay({
                        attachEl: $(_this.productPage.attach),
                        positionEl: $((ref1 = _this.productPage.position) != null ? ref1 : _this.productPage.image),
                        productData: {
                          productSid: _this.productPage.productSid.call(_this)
                        },
                        overlayZIndex: (ref2 = _this.productPage.zIndex) != null ? ref2 : 9999,
                        init: function(overlay) {
                          return overlay.addAlwaysShow('productPage');
                        }
                      });
                    };
                    return _this.waitFor(_this.productPage.attach, function() {
                      lastProductSid = null;
                      return Q.setInterval((function() {
                        var productSid;
                        productSid = _this.productPage.productSid.call(_this);
                        if (productSid && productSid !== lastProductSid) {
                          lastProductSid = productSid;
                          return update();
                        }
                      }), 500);
                    });
                  } else {
                    if (_this.productPage.overlayEl) {
                      overlayEl = _this.productPage.overlayEl;
                      Q('body').delegate(overlayEl, 'mouseover', function() {
                        var down, event;
                        $(overlayEl).unbind('.agora');
                        down = false;
                        event = null;
                        return Q(overlayEl).bind('mousedown.agora', function(e) {
                          down = true;
                          Q('html').disableSelection();
                          e.preventDefault();
                          event = e;
                          return true;
                        }).bind('mouseup.agora', function() {
                          down = false;
                          return true;
                        }).bind('mousemove.agora', function(e) {
                          var selector;
                          if (down) {
                            down = false;
                            selector = _this.productPage.imgEl;
                            return setTimeout((function() {
                              Q(overlayEl).hide();
                              $(selector).trigger(event);
                              return $('html').one('mouseup', function() {
                                $('html').enableSelection();
                                return $(overlayEl).show();
                              });
                            }), 100);
                          }
                        });
                      });
                    }
                    update = function() {
                      var el, ref1;
                      console.debug(_this.productPage.productSid.call(_this));
                      if (_this.productPage.initProduct) {
                        return _this.productPage.initProduct.call(_this);
                      } else {
                        el = _this.productPage.imgEl;
                        _this.clearProductEl(el);
                        return _this.initProductEl(el, {
                          productSid: _this.productPage.productSid.call(_this)
                        }, {
                          overlayZIndex: (ref1 = _this.productPage.overlayZIndex) != null ? ref1 : 1000,
                          initOverlay: function(overlay) {
                            return overlay.addAlwaysShow('productPage');
                          }
                        });
                      }
                    };
                    return _this.waitFor((ref1 = _this.productPage.waitFor) != null ? ref1 : _this.productPage.imgEl, function() {
                      lastProductSid = null;
                      return Q.setInterval((function() {
                        var productSid;
                        productSid = _this.productPage.productSid.call(_this);
                        if (productSid && productSid !== lastProductSid) {
                          lastProductSid = productSid;
                          return update();
                        }
                      }), 1000);
                    });
                  }
                }
              });
            };
          })(this));
        };

        return DataDrivenSiteInjector;

      })(SiteInjector);
    }
  };
});

//# sourceMappingURL=DataDrivenSiteInjector.js.map
