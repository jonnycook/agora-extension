// Generated by CoffeeScript 1.7.1
define(function() {
  return function() {
    var DetailsWidget;
    return DetailsWidget = (function() {
      DetailsWidget.prototype.expands = false;

      function DetailsWidget(data) {
        var detail, name, _ref;
        this.title = data.title;
        this.el = $('<ul />');
        _ref = data.content;
        for (name in _ref) {
          detail = _ref[name];
          this.el.append("<li><span class='name'>" + name + "</span>: <span class='value'>" + detail + "</span></li>");
        }
      }

      return DetailsWidget;

    })();
  };
});

//# sourceMappingURL=DetailsWidget.map