// Generated by CoffeeScript 1.7.1
define(function() {
  return function() {
    var ListWidget;
    return ListWidget = (function() {
      function ListWidget(data) {
        var item, _i, _len, _ref;
        this.title = data.title;
        this.el = $('<ul />');
        _ref = data.content;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          this.el.append("<li>" + item + "</li>");
        }
      }

      return ListWidget;

    })();
  };
});

//# sourceMappingURL=ListWidget.map
