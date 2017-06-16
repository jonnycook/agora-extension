// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['View', 'Frame', 'views/OffersView', 'views/AddFeelingView', 'views/AddArgumentView'],
    c: function() {
      var ProductPreviewView;
      return ProductPreviewView = (function(superClass) {
        extend(ProductPreviewView, superClass);

        ProductPreviewView.prototype.type = 'ProductPreview';

        ProductPreviewView.prototype.flexibleLayout = true;

        function ProductPreviewView(contentScript) {
          this.contentScript = contentScript;
          ProductPreviewView.__super__.constructor.call(this, this.contentScript);
          this.el = $('<div class="-agora v-productPreview loading"> <a href="#" class="title"><span class="title" /> <span class="continue">continue to product page <span class="arrow">&rarr;</span></span></a> <span class="price" /> <ul class="pictures" /> <span class="picture lowRes" /> <span class="picture mediumRes" /> <a class="picture hiRes" /> <div class="stylesWrapper"><ul class="styles" /></div> <div class="productMenu white" /> </div>');
          this.alsoRepresent(this.createView('ProductMenu', this.el.find('.productMenu')));
          util.initDragging(this.el.find('.picture.hiRes'), {
            acceptsDrop: false,
            affect: false,
            context: 'page',
            helper: function(event) {
              return $('<div class="-agora -agora-productClip t-item dragging" style="position:absolute"> <span class="p-image"></span> <div class="g-productInfo"> <span class="p-title">loading...</span> <span class="p-site">loading...</span> <span class="p-price">loading...</span> </div> </div>');
            },
            start: (function(_this) {
              return function(event, ui) {
                var clip, clipTimerId, height, image, item, itemState, marginLeft, marginTop, offsetX, offsetY, price, site, size, target, title, view, width;
                _this.event('dragProduct');
                target = $(event.currentTarget);
                width = target.width();
                height = target.height();
                image = ui.helper.find('.p-image');
                image.css({
                  backgroundImage: "url('" + (_this.image() ? _this.image().small : _this.defaultImage) + "')",
                  width: width,
                  height: height
                });
                title = ui.helper.find('.p-title');
                site = ui.helper.find('.p-site');
                price = ui.helper.find('.p-price');
                view = new View(_this.contentScript);
                view.type = 'ProductClip';
                view.onData = function(data) {
                  if (data.title.get()) {
                    title.html(data.title.get());
                  }
                  view.observe(data.title, function(mutation) {
                    return title.html(mutation.value);
                  });
                  if (data.site.get()) {
                    site.html(data.site.get());
                  }
                  view.observe(data.site, function(mutation) {
                    return site.html(mutation.value);
                  });
                  if (data.price.get()) {
                    price.html(data.price.get());
                  }
                  return view.observe(data.price, function(mutation) {
                    return price.html(mutation.value);
                  });
                };
                ui.helper.data('dragging', {
                  data: _this.args
                });
                marginLeft = 0;
                marginTop = 0;
                offsetX = event.pageX - target.offset().left + marginLeft;
                offsetY = event.pageY - target.offset().top + marginTop;
                ui.helper.css({
                  marginLeft: marginLeft,
                  width: width,
                  height: height,
                  zIndex: 999999
                });
                ui.helper.find('.g-productInfo').css({
                  opacity: 0
                });
                size = {
                  width: 48,
                  height: 48
                };
                clip = function() {
                  var curve, time;
                  time = 200;
                  curve = null;
                  ui.helper.animate({
                    marginLeft: offsetX - size.width * .9,
                    marginTop: offsetY - size.height * .9,
                    width: 148,
                    height: size.height
                  }, time, curve);
                  image.animate({
                    width: 44,
                    height: 44
                  }, time, curve);
                  return setTimeout((function() {
                    if (!itemState) {
                      return ui.helper.find('.g-productInfo').animate({
                        opacity: 1
                      }, time, curve);
                    }
                  }), time);
                };
                itemState = false;
                item = function() {
                  var time;
                  itemState = true;
                  time = 300;
                  image.animate({
                    width: 44,
                    height: 44
                  }, time);
                  ui.helper.find('.g-productInfo').stop(true).animate({
                    opacity: 0
                  }, time, function() {});
                  return ui.helper.stop(true).animate({
                    width: size.width,
                    height: size.height,
                    marginLeft: offsetX - size.width / 2,
                    marginTop: offsetY - size.height / 2
                  }, time);
                };
                view.represent(_this.args);
                ui.args.onDraggedOver = function(el) {
                  if (el) {
                    clearTimeout(clipTimerId);
                    if (!itemState) {
                      item();
                    }
                    return ui.helper.addClass('adding');
                  } else {
                    return ui.helper.removeClass('adding');
                  }
                };
                ui.args.stop = function(event, ui) {
                  view.destruct();
                  return ui.helper.animate({
                    marginLeft: offsetX,
                    marginTop: offsetY,
                    width: 10,
                    height: 10,
                    opacity: 0
                  }, 100, 'linear', function() {
                    return ui.helper.remove();
                  });
                };
                return clipTimerId = setTimeout(clip, 100);
              };
            })(this)
          });
          $(document).bind('keydown.-agoraProductPreview', (function(_this) {
            return function(e) {
              if (e.which === 27) {
                _this.event('close', 'esc');
                if (typeof _this.close === "function") {
                  _this.close();
                }
                return $(document).unbind('keydown', arguments.callee);
              }
            };
          })(this));
          this.el.find('.title').click((function(_this) {
            return function() {
              return _this.event('continueToProduct');
            };
          })(this));
        }

        ProductPreviewView.prototype.onRepresent = function(args) {
          this.createView('ProductPrice', this.el.find('.price')).represent(args);
          return this.product;
        };

        ProductPreviewView.prototype.updateLayout = function() {
          var contWidth, width;
          contWidth = this.el.find('.stylesWrapper').width();
          width = this.el.find('.styles').width();
          return this.el.find('.styles').css({
            marginLeft: Math.max(0, (contWidth - width) / 2)
          });
        };

        ProductPreviewView.prototype.setStyle = function(style) {
          var fn, i, image, j, len, ref, ref1;
          this.style = style;
          if (style && this.images[style]) {
            this.el.find('.pictures').html('');
            ref = this.images[style];
            fn = (function(_this) {
              return function(i) {
                return _this.el.find('.pictures').append($("<li style=\"background-image:url('" + image.small + "')\" />").click(function() {
                  _this.event('selectImage', 'click');
                  return _this.setImage(i);
                }));
              };
            })(this);
            for (i = j = 0, len = ref.length; j < len; i = ++j) {
              image = ref[i];
              fn(i);
            }
            this.setImage((ref1 = this.imageIndex) != null ? ref1 : 0);
            this.el.find('.styles .active').removeClass('active');
            return this.el.find(".styles [productstyle=\"" + style + "\"]").addClass('active');
          }
        };

        ProductPreviewView.prototype.image = function() {
          var ref, ref1;
          return (ref = this.images) != null ? (ref1 = ref[this.style]) != null ? ref1[this.imageIndex] : void 0 : void 0;
        };

        ProductPreviewView.prototype.setImage = function(index) {
          if (index >= this.images[this.style].length) {
            index = this.images[this.style].length - 1;
          }
          this.imageIndex = index;
          this.el.find('.picture.lowRes').css({
            backgroundImage: "url('" + this.images[this.style][index].small + "')"
          });
          this.el.find('.picture.mediumRes').css({
            backgroundImage: "url('" + this.images[this.style][index].medium + "')"
          });
          this.el.find('.picture.hiRes').css({
            backgroundImage: "url('" + this.images[this.style][index].large + "')"
          });
          this.el.find('.pictures .active').removeClass('active');
          return this.el.find(".pictures li:nth-child(" + (index + 1) + ")").addClass('active');
        };

        ProductPreviewView.prototype.onData = function(data) {
          var imageEl, title, updateImages;
          title = this.el.children('.title');
          imageEl = this.el.find('.picture');
          if (data.title.get()) {
            title.find('.title').html(data.title.get());
          }
          this.observe(data.title, function(mutation) {
            return title.find('.title').html(mutation.value);
          });
          title.attr({
            href: data.url
          });
          this.el.find('.picture.hiRes').attr({
            href: data.url
          });
          this.defaultImage = data.image.get();
          if (data.image.get()) {
            imageEl.css({
              backgroundImage: "url('" + (data.image.get()) + "')"
            });
          }
          this.observe(data.image, (function(_this) {
            return function(mutation) {
              _this.defaultImage = mutation.value;
              return imageEl.css({
                backgroundImage: "url('" + mutation.value + "')"
              });
            };
          })(this));
          if (data.layout === 'basic') {
            return this.el.removeClass('loading');
          } else {
            updateImages = (function(_this) {
              return function() {
                var fn, images, ref, style;
                _this.el.find('.styles').html('');
                if (data.styleInfo.get()) {
                  _this.el.removeClass('loading');
                  _this.images = data.styleInfo.get().images;
                  if (_this.images && !_.isEmpty(_this.images)) {
                    _this.el.removeClass('singlePicture');
                    ref = _this.images;
                    fn = function(style) {
                      return _this.el.find('.styles').append($("<li productstyle='" + style + "' style=\"background-image:url('" + images[0].small + "')\" />").click(function() {
                        _this.event('selectStyle');
                        return _this.setStyle(style);
                      }));
                    };
                    for (style in ref) {
                      images = ref[style];
                      fn(style);
                    }
                  } else {
                    _this.el.addClass('singlePicture');
                  }
                  _this.updateLayout();
                  _this.setStyle(data.styleInfo.get().currentStyle);
                  util.scrollbar(_this.el.find('.stylesWrapper'));
                  return util.scrollbar(_this.el.find('.pictures'));
                }
              };
            })(this);
            updateImages();
            return data.styleInfo.observe(updateImages);
          }
        };

        ProductPreviewView.prototype.shown = function() {
          return this.event('open');
        };

        ProductPreviewView.prototype.destruct = function() {
          ProductPreviewView.__super__.destruct.apply(this, arguments);
          return $(document).unbind('.-agoraProductPreview');
        };

        return ProductPreviewView;

      })(View);
    }
  };
});

//# sourceMappingURL=ProductPreviewView2.js.map
