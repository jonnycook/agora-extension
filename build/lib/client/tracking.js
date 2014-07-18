// Generated by CoffeeScript 1.7.1
var __slice = [].slice;

define(function() {
  return function() {
    return {
      page: function(path, params) {
        if (params == null) {
          params = {};
        }
        return contentScript.triggerBackgroundEvent('tracking', {
          type: 'page',
          path: path,
          params: params
        });
      },
      event: function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return contentScript.triggerBackgroundEvent('tracking', {
          type: 'event',
          args: args
        });
      },
      time: function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return contentScript.triggerBackgroundEvent('tracking', {
          type: 'time',
          args: args
        });
      }
    };
  };
});

//# sourceMappingURL=tracking.map