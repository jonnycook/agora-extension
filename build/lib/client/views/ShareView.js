// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['View', 'util', 'icons'],
    c: function() {
      var ShareView;
      return ShareView = (function(superClass) {
        extend(ShareView, superClass);

        ShareView.prototype.type = 'Share';

        function ShareView() {
          var addEl, shareTitleEl, submit;
          ShareView.__super__.constructor.apply(this, arguments);
          this.viewEl('<div class="v-share t-dialog"> <h2>Invite Collaborators</h2> <div class="content"> <input type="text" class="title" placeholder="Title"> <textarea class="message" placeholder="Message"></textarea> <input type="text" class="add" placeholder="Add"> <input type="button" value="invite"> </div> </div>');
          submit = (function(_this) {
            return function() {
              _this.callBackgroundMethod('add', [shareTitleEl.val(), _this.el.find('.message').val(), addEl.val()]);
              addEl.val('');
              _this.el.addClass('success');
              return setTimeout((function() {
                return typeof _this.close === "function" ? _this.close() : void 0;
              }), 1500);
            };
          })(this);
          addEl = this.el.find('.add');
          this.el.find('[type=button]').click(submit);
          addEl.keyup((function(_this) {
            return function(e) {
              if (e.keyCode === 13) {
                return submit();
              }
            };
          })(this));
          shareTitleEl = this.el.find('.title');
          shareTitleEl.keyup((function(_this) {
            return function(e) {
              if (e.keyCode === 13) {
                _this.callBackgroundMethod('update', [shareTitleEl.val(), _this.el.find('.message').val()]);
                return typeof _this.close === "function" ? _this.close() : void 0;
              }
            };
          })(this));
        }

        ShareView.prototype.onData = function(data) {
          this.el.find('.title').val(data.title);
          this.el.find('.message').val(data.message);
          return this.withData(data.entries, (function(_this) {
            return function(entries) {
              var entry, i, len, results;
              _this.el.find('.users').html('');
              results = [];
              for (i = 0, len = entries.length; i < len; i++) {
                entry = entries[i];
                results.push((function(entry) {
                  var el;
                  el = $("<li><span class='user'>" + entry.with_user_name + "</span> <a href='#' class='delete' /></li>");
                  _this.el.find('.users').append(el);
                  return el.find('.delete').click(function() {
                    _this.callBackgroundMethod('delete', [entry.id]);
                    return false;
                  });
                })(entry));
              }
              return results;
            };
          })(this));
        };

        return ShareView;

      })(View);
    }
  };
});

//# sourceMappingURL=ShareView.js.map
