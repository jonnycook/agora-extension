// Generated by CoffeeScript 1.10.0
define(function() {
  return function() {
    var AmazonFeatureWidget;
    return AmazonFeatureWidget = (function() {
      AmazonFeatureWidget.prototype.title = 'Features';

      AmazonFeatureWidget.prototype.expands = false;

      function AmazonFeatureWidget(data) {
        var feature, i, len;
        this.el = $('<ul />');
        for (i = 0, len = data.length; i < len; i++) {
          feature = data[i];
          this.el.append("<li>" + feature + "</li>");
        }
      }

      return AmazonFeatureWidget;

    })();
  };
});

//# sourceMappingURL=AmazonFeaturesWidget.js.map
