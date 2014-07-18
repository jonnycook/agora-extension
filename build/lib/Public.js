// Generated by CoffeeScript 1.7.1
define(function() {
  var Public;
  return Public = (function() {
    function Public() {}

    Public.prototype.route = function(obj) {
      var garbledId, hash, i, id, _i, _ref;
      if (obj.isA('Decision')) {
        hash = md5(obj.saneId() + 'salty apple sauce');
        id = obj.saneId() + '';
        garbledId = '';
        for (i = _i = 0, _ref = id.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          garbledId += id[i] + hash[i];
        }
        return "" + env.base + "/decisions/" + garbledId;
      }
    };

    Public.prototype.get = function(type, id, cb) {
      var record;
      record = this.agora.db.table(type).bySaneId(id);
      if (record) {
        return typeof cb === "function" ? cb(true) : void 0;
      } else {
        return this.agora.background.httpRequest(this.agora.background.apiRoot + 'public/data.php', {
          data: {
            type: type,
            id: id
          },
          dataType: 'json',
          cb: (function(_this) {
            return function(response) {
              if (response === 'accessDenied' || response === 'invalidId') {
                return cb(false);
              } else {
                return _this.agora.updater.transport.executeChanges(response.data, 0, function() {
                  return cb(true, response.id);
                });
              }
            };
          })(this)
        });
      }
    };

    return Public;

  })();
});

//# sourceMappingURL=Public.map
