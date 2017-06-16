// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['views/compare/TileItem', 'views/ProductPopupView', 'util', 'Frame'],
    c: function() {
      var ProductTileItem;
      return ProductTileItem = (function(superClass) {
        extend(ProductTileItem, superClass);

        function ProductTileItem() {
          return ProductTileItem.__super__.constructor.apply(this, arguments);
        }

        ProductTileItem.prototype.html = function(layout) {
          var html;
          return html = (function() {
            switch (layout) {
              case 'tiles':
                return '<span class="image" /><a />';
              case 'masonry':
                return '<div><img class="image" /><a /><ul class="properties"><li /></ul><div class="productMenu" /></div>';
            }
          })();
        };

        ProductTileItem.prototype.width = function() {
          return ProductTileItem.__super__.width.apply(this, arguments) + 48;
        };

        ProductTileItem.prototype.init = function() {
          var triggerEl;
          ProductTileItem.__super__.init.apply(this, arguments);
          triggerEl = this.el.find('.image');
          triggerEl.click((function(_this) {
            return function() {
              return _this.callBackgroundMethod('click');
            };
          })(this));
          triggerEl.css('cursor', 'pointer');
          this.el.bind('mouseenter.tutorial', (function(_this) {
            return function() {
              return _tutorial(['AccessProductPortalFromWorkspace', 'Workspace/Dismiss', 'Select'], [
                _this.el.find('.image'), {
                  positionEl: _this.el.find('.actions .dismiss'),
                  attachEl: _this.el
                }, {
                  positionEl: _this.el.find('.actions .chosen'),
                  attachEl: _this.el
                }
              ], function(close) {
                _this.el.find('.image').one('mousedown', close);
                return _this.el.one('mouseleave', close);
              });
            };
          })(this));
          if (this.view.compareView["public"] && !this.view.contentScript.webApp) {
            return util.draggableImage({
              view: this.view,
              el: this.el.find('.image'),
              productData: (function(_this) {
                return function() {
                  return _this.view.args;
                };
              })(this)
            });
          }
        };

        ProductTileItem.prototype.updateMasonryLayout = function() {
          return this.el.height(Math.max(70, this.el.children('div').height()));
        };

        ProductTileItem.prototype.onData = function(data1) {
          var iface, lastEmotion, updateForImage, updateForLastFeeling;
          this.data = data1;
          updateForImage = (function() {
            switch (this.view.compareView.layout) {
              case 'tiles':
                return (function(_this) {
                  return function() {
                    if (_this.data.image.get()) {
                      return _this.el.find('.image').css({
                        backgroundImage: "url('" + (_this.data.image.get()) + "')"
                      });
                    }
                  };
                })(this);
              case 'masonry':
                return (function(_this) {
                  return function() {
                    var updateMenuPos;
                    updateMenuPos = function() {
                      return _this.el.find('.productMenu').css({
                        bottom: 6
                      });
                    };
                    _this.el.find('.image').attr('src', _this.data.image.get()).load(function() {
                      _this.widthChanged();
                      return updateMenuPos();
                    });
                    if (_this.el.find('.image').prop('complete')) {
                      _this.widthChanged();
                      updateMenuPos();
                    }
                    return updateMenuPos();
                  };
                })(this);
            }
          }).call(this);
          updateForImage();
          this.data.image.observe(updateForImage);
          if (this.view.compareView.layout === 'masonry') {
            iface = this.view.listInterface(this.el.find('.properties'), 'li', (function(_this) {
              return function(el, data, pos, onRemove) {
                var argumentsIface, feelingsIface, view;
                view = _this.view.createView();
                onRemove(function() {
                  return view.destruct();
                });
                switch (data.property) {
                  case 'price':
                    _this.view.createView('ProductPrice', el).represent(data.value);
                    break;
                  case 'rating':
                    if (data.value) {
                      el.addClass("rating").html("<div class='ratingInfo'><span class='rating'>" + util2.ratingHtml + "</span><span class='reviews'>Loading...</span>");
                      util2.setRating(el.find('.rating'), data.value.rating.get());
                      data.value.rating.observe(function() {
                        return util2.setRating(el.find('.rating'), data.value.rating.get());
                      });
                      view.valueInterface(el.find('.reviews')).setDataSource(data.value.ratingCount);
                    }
                    break;
                  case 'title':
                    view.valueInterface(el).setDataSource(data.value);
                    break;
                  case 'feelings':
                    el.html('<ul class="feelings"> <li> <span class="emotion" /> <span class="thought" /> <a href="#" class="delete" /> </li> </ul>');
                    feelingsIface = view.listInterface(el, '.feelings li', function(el, data, pos, onRemove) {
                      var feelingsView, previousEmotion, updateForEmotion;
                      feelingsView = view.view();
                      onRemove(function() {
                        return feelingsView.destruct();
                      });
                      feelingsView.valueInterface(el.find('.thought')).setDataSource(data.thought);
                      previousEmotion = null;
                      updateForEmotion = function() {
                        var emotion;
                        emotion = util.emotionClass(data.positive.get(), data.negative.get());
                        if (previousEmotion) {
                          el.find('.emotion').removeClass(previousEmotion);
                        }
                        el.find('.emotion').addClass(emotion);
                        return previousEmotion = emotion;
                      };
                      data.positive.observe(updateForEmotion);
                      data.negative.observe = updateForEmotion;
                      updateForEmotion();
                      el.find('.delete').click(function() {
                        _this.callBackgroundMethod('deleteFeeling', data.id);
                        return false;
                      });
                      return el;
                    });
                    feelingsIface.onMutation = function() {
                      return typeof _this.widthChanged === "function" ? _this.widthChanged() : void 0;
                    };
                    feelingsIface.setDataSource(data.value);
                    break;
                  case 'arguments':
                    el.html('<ul class="arguments"> <li> <span class="position" /> <span class="thought" /> <a href="#" class="delete" /> </li> </ul>');
                    argumentsIface = view.listInterface(el, '.arguments li', function(el, data, pos, onRemove) {
                      var argumentsView, previousPosition, updateForPosition;
                      argumentsView = view.view();
                      onRemove(function() {
                        return argumentsView.destruct();
                      });
                      argumentsView.valueInterface(el.find('.thought')).setDataSource(data.thought);
                      previousPosition = null;
                      updateForPosition = function() {
                        var position;
                        position = util.positionClass(data["for"].get(), data.against.get());
                        if (previousPosition) {
                          el.find('.position').removeClass(previousPosition);
                        }
                        el.find('.position').addClass(position);
                        return previousPosition = position;
                      };
                      data["for"].observe(updateForPosition);
                      data.against.observe = updateForPosition;
                      updateForPosition();
                      el.find('.delete').click(function() {
                        _this.callBackgroundMethod('deleteArgument', data.id);
                        return false;
                      });
                      return el;
                    });
                    argumentsIface.onMutation = function() {
                      return _this.widthChanged();
                    };
                    argumentsIface.setDataSource(data.value);
                    break;
                  default:
                    view.valueInterface(el).setDataSource(data.value);
                }
                return el;
              };
            })(this));
            iface.onMutation = (function(_this) {
              return function() {
                return typeof _this.widthChanged === "function" ? _this.widthChanged() : void 0;
              };
            })(this);
            iface.setDataSource(this.data.properties);
            this.view.createView('ProductMenu', this.el.find('.productMenu'), {
              orientation: 'horizontal',
              pinSidebar: (function(_this) {
                return function() {
                  return _this.el.addClass('pinSidebar');
                };
              })(this),
              unpinSidebar: (function(_this) {
                return function() {
                  return _this.el.removeClass('pinSidebar');
                };
              })(this)
            }).represent(this.view.args);
          }
          this.el.append('<span class="feelingBadge"><span class="icon" /><span class="text">buffalo</span></span>');
          lastEmotion = null;
          updateForLastFeeling = (function(_this) {
            return function() {
              var emotionClass;
              if (lastEmotion) {
                _this.el.find('.feelingBadge').removeClass(lastEmotion);
              }
              if (_this.data.lastFeeling.get()) {
                _this.el.find('.feelingBadge').show();
                _this.el.find('.feelingBadge .text').html(_this.data.lastFeeling.get().thought);
                emotionClass = util.emotionClass(_this.data.lastFeeling.get().positive, _this.data.lastFeeling.get().negative);
                _this.el.find('.feelingBadge').addClass(emotionClass);
                return lastEmotion = emotionClass;
              } else {
                return _this.el.find('.feelingBadge').hide();
              }
            };
          })(this);
          this.data.lastFeeling.observe(updateForLastFeeling);
          updateForLastFeeling();
          return this.widthChanged();
        };

        ProductTileItem.prototype.destruct = function() {
          ProductTileItem.__super__.destruct.apply(this, arguments);
          this.el.css('backgroundImage', '');
          this.el.css('cursor', '');
          if (this.popupFrame) {
            return this.popupFrame.el.remove();
          }
        };

        return ProductTileItem;

      })(TileItem);
    }
  };
});

//# sourceMappingURL=ProductTileItem.js.map
