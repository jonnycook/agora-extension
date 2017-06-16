// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View'], function(View) {
  var SocialShareView;
  return SocialShareView = (function(superClass) {
    extend(SocialShareView, superClass);

    function SocialShareView() {
      return SocialShareView.__super__.constructor.apply(this, arguments);
    }

    SocialShareView.nextId = 1;

    SocialShareView.id = function() {
      return this.nextId++;
    };

    SocialShareView.prototype.init = function(args) {
      var view;
      if (args.id) {
        this.decision = this.agora.modelManager.getInstance('Decision', args.id);
      } else if (args.viewId) {
        view = this.agora.View.clientViews[args.viewId].view;
        if (view.name === 'compare/Compare') {
          this.decision = view.currentDecision();
        }
      }
      return this.data = {
        access: this.clientValue(this.decision.field('access')),
        url: this.agora["public"].route(this.decision),
        owner: this.decision.record.storeId === this.agora.user.saneId()
      };
    };

    SocialShareView.prototype.methods = {
      setAccess: function(view, access) {
        return this.decision.set('access', access);
      }
    };

    return SocialShareView;

  })(View);
});

//# sourceMappingURL=SocialShareView.js.map
