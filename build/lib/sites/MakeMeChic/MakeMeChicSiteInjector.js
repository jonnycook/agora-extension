// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var MakeMeChicSiteInjector;
      return MakeMeChicSiteInjector = (function(_super) {
        __extends(MakeMeChicSiteInjector, _super);

        function MakeMeChicSiteInjector() {
          return MakeMeChicSiteInjector.__super__.constructor.apply(this, arguments);
        }

        MakeMeChicSiteInjector.prototype.productListing = {
          image: 'a img[src^="http://www.makemechic.com/media/catalog/product"]',
          productSid: function(href, a, img) {
            var name, _ref;
            name = (_ref = href.match(/([^\/]*?)\.html$/)) != null ? _ref[1] : void 0;
            return name;
          }
        };

        MakeMeChicSiteInjector.prototype.productPage = {
          mode: 2,
          test: function() {
            return $('meta[property="og:type"]').attr('content') === 'product';
          },
          productSid: function() {
            return document.location.href.match(/([^\/]*?)\.html$/)[1];
          },
          image: '#wrap img',
          overlay: '.mousetrap',
          attach: '#image',
          variant: function() {
            var className, colorAbbreviation, colorId, colorName;
            colorAbbreviation = $('#image img').attr('src').match(/\/\w+-([a-z]+)[^\/]*\.\w*$/)[1];
            className = $('.color-swatch-wrapper').find("img[src*='-" + colorAbbreviation + "']").parent().get(0).className;
            colorId = className.match(/color-swatch-\d*-(\d*)/)[1];
            colorName = $('#attribute85').find("option[value=" + colorId + "]").html();
            return {
              Color: colorName
            };
          }
        };

        return MakeMeChicSiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=MakeMeChicSiteInjector.map
