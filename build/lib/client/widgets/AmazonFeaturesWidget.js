// Generated by CoffeeScript 1.7.1
define(function() {
  return function() {
    var AmazonFeatureWidget;
    return AmazonFeatureWidget = (function() {
      AmazonFeatureWidget.prototype.title = 'Features';

      AmazonFeatureWidget.prototype.expands = false;

      function AmazonFeatureWidget(data) {
        var feature, _i, _len;
        this.el = $('<ul />');
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          feature = data[_i];
          this.el.append("<li>" + feature + "</li>");
        }
      }

      return AmazonFeatureWidget;

    })();
  };
});

//# sourceMappingURL=AmazonFeaturesWidget.map