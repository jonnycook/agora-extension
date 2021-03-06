// Generated by CoffeeScript 1.10.0
define(['View', 'Site', 'Formatter', 'util', 'underscore'], function(View, Site, Formatter, util, _) {
  var BarItem;
  return BarItem = (function() {
    function BarItem() {}

    BarItem.prototype.getData = function(cb) {
      return cb(this.data);
    };

    BarItem.prototype.observe = function(object, observer) {
      if (object) {
        return this.ctx.observe(object, observer);
      }
    };

    return BarItem;

  })();
});

//# sourceMappingURL=BarItem.js.map
