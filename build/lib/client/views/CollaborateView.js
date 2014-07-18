// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['View', 'util', 'icons', 'Frame2', 'views/DecisionPreviewView'],
    c: function() {
      var CollaborateView;
      return CollaborateView = (function(_super) {
        __extends(CollaborateView, _super);

        CollaborateView.prototype.type = 'Collaborate';

        function CollaborateView() {
          CollaborateView.__super__.constructor.apply(this, arguments);
          this.viewEl('<div class="v-collaborate collaborators"> <div class="tabs"> <div class="tab collaborators">Collaborators</div> <div class="tab activity">Activity</div> </div> <div class="content"> <div class="collaborators"> <ul class="collaborators"> <li class="collaborator"> <span class="abbreviation" /> <span class="name" /> <a href="#" class="delete" /> </li> </ul> <a href="#" class="invite">Invite Collaborators</a> </div> <div class="activity"> <ul class="activity"> <li class="entry"> <span class="type" /> <span class="imagePreview" /> <span class="text" /> <span class="timestamp" /> </li> </ul> </div> </div> </div>');
          this.el.find('.tabs .collaborators').click((function(_this) {
            return function() {
              _this.el.removeClass('activity');
              return _this.el.addClass('collaborators');
            };
          })(this));
          this.el.find('.tabs .activity').click((function(_this) {
            return function() {
              _this.el.addClass('activity');
              return _this.el.removeClass('collaborators');
            };
          })(this));
          util.trapScrolling(this.el.find('ul.activity'));
          this.el.find('.invite').click((function(_this) {
            return function() {
              util.showDialog(function() {
                var view;
                view = new ShareView(_this.contentScript);
                view.represent(_this.args);
                return view;
              });
              return false;
            };
          })(this));
        }

        CollaborateView.prototype.onDisplay = function() {};

        CollaborateView.prototype.onClose = function() {};

        CollaborateView.prototype.configure = function(data) {
          if (this.stateView) {
            this.stateView.destruct();
          }
          this.stateView = this.createView();
          if (data.owner) {
            this.el.addClass('owner');
          } else {
            this.el.removeClass('owner');
          }
          this.el.find('ul.collaborators').html('<li class="collaborator"> <span class="abbreviation" /> <span class="name" /> <a href="#" class="delete" /> </li>');
          this.stateView.listInterface(this.el.find('ul.collaborators'), '.collaborator', (function(_this) {
            return function(el, data, pos, onRemove) {
              var view;
              view = _this.stateView.createView();
              onRemove(function() {
                return view.destruct();
              });
              if (data.pending) {
                el.addClass('pending');
                el.find('.abbreviation').html('...');
                el.find('.name').html(data.name + ' (pending)');
                el.find('.delete').click(function() {
                  _this.callBackgroundMethod('deletePending', [data.id]);
                  return false;
                });
              } else {
                view.withData(data.abbreviation, function(abbreviation) {
                  return el.find('.abbreviation').html(abbreviation);
                });
                if (data.color === '#FFFFFF') {
                  el.find('.abbreviation').addClass('white');
                }
                el.find('.abbreviation').css({
                  backgroundColor: data.color
                });
                view.withData(data.name, function(name) {
                  if (data.owner) {
                    name += ' (owner)';
                  }
                  return el.find('.name').html(name);
                });
                if (data.owner) {
                  el.find('.delete').remove();
                } else {
                  el.find('.delete').click(function() {
                    _this.callBackgroundMethod('delete', [data.id]);
                    return false;
                  });
                }
              }
              return el;
            };
          })(this)).setDataSource(data.collaborators);
          this.el.find('ul.activity').html('<li class="entry"> <span class="type" /> <span class="imagePreview" /> <span class="text" /> <span class="timestamp" /> </li>');
          return this.stateView.listInterface(this.el.find('ul.activity'), '.entry', (function(_this) {
            return function(el, data, pos, onRemove) {
              var classesForLength, comp, image, imageEl, objEl, textEl, view, _fn, _i, _j, _len, _len1, _ref, _ref1;
              view = _this.stateView.createView();
              onRemove(function() {
                return view.destruct();
              });
              el.addClass(data.type.replace('.', '-'));
              if (data.images.length) {
                el.addClass('hasImage');
                classesForLength = {
                  0: 'empty',
                  1: 'oneItem',
                  2: 'twoItems',
                  3: 'threeItems',
                  4: 'fourItems'
                };
                el.find('.imagePreview').addClass(classesForLength[data.images.length]);
                _ref = data.images;
                _fn = function(imageEl) {
                  if (image === 'decision') {
                    return icons.setIcon(imageEl, 'list', {
                      itemClass: false
                    });
                  } else if (image === 'bundle') {
                    return icons.setIcon(imageEl, 'bundle', {
                      itemClass: false
                    });
                  } else if (image === 'belt') {

                  } else {
                    return _this.withData(image, function(image) {
                      return imageEl.css('backgroundImage', "url('" + image + "')");
                    });
                  }
                };
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  image = _ref[_i];
                  imageEl = $('<span class="image" />').appendTo(el.find('.imagePreview'));
                  _fn(imageEl);
                }
              }
              textEl = el.find('.text');
              _ref1 = data.text;
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                comp = _ref1[_j];
                if (typeof comp === 'string') {
                  textEl.append(document.createTextNode(comp));
                } else {
                  objEl = $('<span class="object" />');
                  if (comp.type === 'user') {
                    objEl.addClass('user');
                    objEl.html("<span class='name'>" + comp.text + "</span> <span class='color' style='background-color: " + comp.color + "' />");
                  } else if (comp.model) {
                    if (comp.model === 'Product') {
                      objEl.addClass('product');
                      (function(comp, objEl) {
                        var popup;
                        objEl.click(function() {
                          return util.openProductPreview({
                            modelName: 'Product',
                            instanceId: comp.id
                          });
                        });
                        _this.el.find('.activity').one('scroll', function() {
                          return popup.close();
                        });
                        popup = util.popupTrigger2(objEl, {
                          delay: 300,
                          closeDelay: 0,
                          createPopup: function(cb, close, addEl) {
                            var connectorEl, frame, productPopupView, updateConnectorEl;
                            productPopupView = _this.createView('ProductPopupView', {
                              unconstrainedPictureHeight: true
                            });
                            tracking.page("" + (_this.path()) + "/" + (productPopupView.pathElement()));
                            frame = Frame.frameAbove(objEl, productPopupView.el, {
                              type: 'balloon',
                              distance: 10,
                              position: (objEl.offset().top - $(window).scrollTop() < ($(window).height()) / 3 ? 'below' : 'above'),
                              onClose: function() {
                                productPopupView.destruct();
                                return productPopupView = null;
                              }
                            });
                            productPopupView.close = close;
                            productPopupView.sizeChanged = function() {
                              frame.update();
                              return updateConnectorEl();
                            };
                            productPopupView.addEl = addEl;
                            productPopupView.shown();
                            setTimeout((function() {
                              return frame.update();
                            }), 500);
                            productPopupView.represent({
                              modelName: 'Product',
                              instanceId: comp.id
                            });
                            if (typeof _this.addExtension === "function") {
                              _this.addExtension(frame.el);
                            }
                            connectorEl = $('<div />');
                            connectorEl.appendTo(frame.el);
                            updateConnectorEl = function() {
                              var height;
                              height = objEl.offset().top - (frame.el.offset().top + frame.el.height());
                              return connectorEl.css({
                                position: 'absolute',
                                bottom: -height,
                                left: 0,
                                width: '100%',
                                height: height
                              });
                            };
                            updateConnectorEl();
                            return frame.el;
                          },
                          onClose: function(el) {
                            var _ref2;
                            if (typeof _this.removeExtension === "function") {
                              _this.removeExtension(el.data('frame').el);
                            }
                            return (_ref2 = el.data('frame')) != null ? typeof _ref2.close === "function" ? _ref2.close(100) : void 0 : void 0;
                          }
                        });
                        return objEl.mousedown(function() {
                          return popup.close();
                        });
                      })(comp, objEl);
                    } else if (comp.model === 'Decision') {
                      objEl.addClass('decision');
                      (function(comp, objEl) {
                        var popup;
                        _this.el.find('.activity').one('scroll', function() {
                          return popup.close();
                        });
                        popup = util.popupTrigger2(objEl, {
                          delay: 300,
                          closeDelay: 0,
                          createPopup: function(cb, close, addEl) {
                            var connectorEl, decisionPreviewView, frame, updateConnectorEl;
                            if (window.suppressPopups) {
                              return false;
                            }
                            decisionPreviewView = _this.createView('DecisionPreview');
                            decisionPreviewView.editInModalDialog = true;
                            decisionPreviewView.represent({
                              modelName: 'Decision',
                              instanceId: comp.id
                            });
                            decisionPreviewView.close = close;
                            decisionPreviewView.editEnv = function(cb) {
                              return cb(objEl);
                            };
                            tracking.page("" + (_this.path()) + "/" + (decisionPreviewView.pathElement()));
                            frame = Frame.frameAbove(objEl, decisionPreviewView.el, {
                              type: 'balloon',
                              distance: 10,
                              position: (objEl.offset().top - $(window).scrollTop() < ($(window).height()) / 3 ? 'below' : 'above'),
                              onClose: function() {
                                decisionPreviewView.destruct();
                                return decisionPreviewView = null;
                              }
                            });
                            if (typeof _this.addExtension === "function") {
                              _this.addExtension(frame.el);
                            }
                            decisionPreviewView.sizeChanged = function() {
                              frame.update();
                              return updateConnectorEl();
                            };
                            connectorEl = $('<div />');
                            connectorEl.appendTo(frame.el);
                            updateConnectorEl = function() {
                              var height;
                              height = objEl.offset().top - (frame.el.offset().top + frame.el.height());
                              return connectorEl.css({
                                position: 'absolute',
                                bottom: -height,
                                left: 0,
                                width: '100%',
                                height: height
                              });
                            };
                            updateConnectorEl();
                            return frame.el;
                          },
                          onClose: function(el) {
                            var _ref2;
                            if (typeof _this.removeExtension === "function") {
                              _this.removeExtension(el.data('frame').el);
                            }
                            return (_ref2 = el.data('frame')) != null ? typeof _ref2.close === "function" ? _ref2.close(100) : void 0 : void 0;
                          }
                        });
                        return objEl.mousedown(function() {
                          return popup.close();
                        });
                      })(comp, objEl);
                    }
                    objEl.html(comp.text);
                  } else {
                    objEl.html(comp.text);
                  }
                  textEl.append(objEl);
                }
                textEl.append(document.createTextNode(' '));
              }
              el.find('.timestamp').html(data.timestamp);
              return el;
            };
          })(this)).setDataSource(data.activity);
        };

        CollaborateView.prototype.onData = function(data) {
          return this.withData(data, (function(_this) {
            return function(data) {
              return _this.configure(data);
            };
          })(this));
        };

        return CollaborateView;

      })(View);
    }
  };
});

//# sourceMappingURL=CollaborateView.map