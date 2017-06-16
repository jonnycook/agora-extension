// Generated by CoffeeScript 1.10.0
define(function() {
  return function() {
    var htmlWidget;
    return htmlWidget = (function() {
      htmlWidget.prototype.expands = true;

      function htmlWidget(data1) {
        this.data = data1;
        this.title = data.title;
        this.el = $("<div class='htmlContent'>" + data.content + "</div>");
        if (data.maxHeight != null) {
          this.el.css('max-height', data.maxHeight);
        }
      }

      htmlWidget.prototype.init = function() {
        if (this.data.maxHeight !== 'none') {
          this.el.dotdotdot();
          if (!this.el.triggerHandler('isTruncated')) {
            return this.expands = false;
          }
        }
      };

      return htmlWidget;

    })();
  };
});

//# sourceMappingURL=htmlWidget.js.map
