// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['View', 'Site', 'Formatter', 'util', 'underscore'], function(View, Site, Formatter, util, _) {
  var ProductPopupView;
  return ProductPopupView = (function(_super) {
    __extends(ProductPopupView, _super);

    function ProductPopupView() {
      return ProductPopupView.__super__.constructor.apply(this, arguments);
    }

    ProductPopupView.nextId = 0;

    ProductPopupView.id = function(args) {
      return ++this.nextId;
    };

    ProductPopupView.prototype.initAsync = function(args, done) {
      return this.resolveObject(args, (function(_this) {
        return function(product, element) {
          var selected, site, updateSelected;
          _this.product = product;
          _this.element = element;
          if (_this.product) {
            _this.product.update();
            site = Site.site(product._get('siteName'));
            _this.data = {
              title: _this.clientValue(product.field('title'), product.displayValue('title')),
              site: {
                name: product.get('siteName'),
                url: product.get('siteUrl'),
                icon: site.icon
              },
              price: _this.clientValue(product.field('price'), product.displayValue('price')),
              image: _this.clientValue(product.field('image'), product.displayValue('image')),
              url: product.get('url'),
              lastFeeling: util.lastFeeling(_this.ctx, product),
              lastArgument: util.lastArgument(_this.ctx, product)
            };
            if (site.hasFeature('rating')) {
              _.extend(_this.data, {
                rating: _this.clientValue(product.field('rating'), product.displayValue('rating')),
                ratingCount: _this.clientValue(product.field('ratingCount'), product.displayValue('ratingCount'))
              });
            }
            if (args.decisionId) {
              selected = _this.clientValueNamed('selected');
              _this.decision = _this.agora.modelManager.getInstance('Decision', args.decisionId);
              updateSelected = function() {
                return selected.set(_this.decision.get('selection').contains(_this.element));
              };
              updateSelected();
              _this.decision.get('selection').observe(updateSelected);
              _this.data.selected = selected;
            }
          }
          return done();
        };
      })(this));
    };

    ProductPopupView.prototype.methods = {
      remove: function() {
        var Bag, Product, bag, product;
        Bag = this.agora.modelManager.getModel('Bag');
        Product = this.agora.modelManager.getModel('Product');
        bag = Bag.withId(this.args.bagId);
        product = Product.getBySid(this.args.siteName, this.args.productSid);
        return this.agora.removeFromBag(product, bag);
      },
      setSelected: function(view, selected) {
        if (this.decision) {
          if (selected) {
            _activity('decision.select', this.decision, this.element.get('element'));
            return this.decision.get('selection').add(this.element);
          } else {
            this.decision.get('selection').remove(this.element);
            return _activity('decision.deselect', this.decision, this.element.get('element'));
          }
        }
      },
      dismiss: function() {
        if (this.decision) {
          return util.dismissDecisionElement(this.decision, this.element);
        }
      }
    };

    return ProductPopupView;

  })(View);
});

//# sourceMappingURL=ProductPopupView.map