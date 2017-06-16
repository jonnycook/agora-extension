// Generated by CoffeeScript 1.10.0
define(function() {
  return function() {
    var DetailsWidget;
    return DetailsWidget = (function() {
      DetailsWidget.prototype.expands = false;

      function DetailsWidget(data) {
        var detail, name, ref;
        this.title = data.title;
        this.el = $('<ul />');
        ref = data.content;
        for (name in ref) {
          detail = ref[name];
          this.el.append("<li><span class='name'>" + name + "</span>: <span class='value'>" + detail + "</span></li>");
        }
      }

      return DetailsWidget;

    })();
  };
});

//# sourceMappingURL=DetailsWidget.js.map
