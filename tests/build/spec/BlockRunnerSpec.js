(function() {
  var _it;

  _it = function() {};

  req(['BlockRunner'], function(BlockRunner) {
    return describe('BlockRunner', function() {
      it('should work', function() {
        var block, log;
        log = function(str) {
          return console.log(str);
        };
        block = new BlockRunner(function() {
          return this.eachSerially({
            1: function() {
              return this["try"]({
                a: function() {
                  return log('a');
                },
                b: function() {
                  log('b');
                  return true;
                }
              });
            }
          });
        });
        block.exec(function() {
          return log('done all');
        });
        return log('end');
      });
      return it('should work', function() {
        var block, done, log, logs;
        done = false;
        logs = [];
        log = function(str) {
          console.log(str);
          return logs.push(str);
        };
        block = new BlockRunner(function() {
          this.onDone(function() {
            return log('done a');
          });
          log('run a');
          this.execBlock(function() {
            this.onDone(function() {
              return log('done a.b');
            });
            log('run a.b');
            return this.execBlock(function() {
              var _this = this;
              this.onDone(function() {
                return log('done a.b.c');
              });
              log('run a.b.c');
              setTimeout((function() {
                return _this.done();
              }), 2000);
              return null;
            });
          });
          return this.execBlock(function() {
            var _this = this;
            this.onDone(function() {
              return log('done a.d');
            });
            log('run a.d');
            setTimeout((function() {
              return _this.done();
            }), 1000);
            return null;
          });
        });
        block.exec(function() {
          log('done all');
          expect(logs.toString()).toBe(['run a', 'run a.b', 'run a.b.c', 'run a.d', 'done a.d', 'done a.b.c', 'done a.b', 'done a', 'done all'].toString());
          return done = true;
        });
        return waitsFor(function() {
          return done;
        });
      });
    });
  });

}).call(this);
