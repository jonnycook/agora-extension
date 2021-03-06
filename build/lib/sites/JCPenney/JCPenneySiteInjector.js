// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(function() {
  return {
    d: ['DataDrivenSiteInjector'],
    c: function() {
      var JCPenneySiteInjector;
      return JCPenneySiteInjector = (function(superClass) {
        extend(JCPenneySiteInjector, superClass);

        function JCPenneySiteInjector() {
          return JCPenneySiteInjector.__super__.constructor.apply(this, arguments);
        }

        JCPenneySiteInjector.prototype.productListing = {
          imgSelector: 'a img[src^="http://s7d9.scene7.com/is/image/JCPenney/"]',
          productSid: function(href, a, img) {
            var match, name, ref, ref1, sid;
            name = (ref = href.match(/^http:\/\/www\.jcpenney\.com\/.*?\/prod\.jump\?ppId=([a-z]*\d+)/)) != null ? ref[1] : void 0;
            sid = name;
            if (!sid) {
              href = unescape(href);
              match = (ref1 = /(http:\/\/www\.jcpenney.com\/.*?)(?:&|$)/.exec(href)) != null ? ref1[1] : void 0;
              if (match) {
                sid = match;
              }
            }
            return sid;
          }
        };

        JCPenneySiteInjector.prototype.productPage = {
          test: function() {
            return $('meta[name="keywords"]').attr('content');
          },
          productSid: function() {
            return document.location.href.match(/^http:\/\/www\.jcpenney\.com\/.*?\/prod\.jump\?ppId=([a-z]*\d+)/)[1];
          },
          imgEl: '#izView img',
          waitFor: '#izView img',
          overlayEl: '#myZoomView'
        };

        return JCPenneySiteInjector;

      })(DataDrivenSiteInjector);
    }
  };
});

//# sourceMappingURL=JCPenneySiteInjector.js.map
