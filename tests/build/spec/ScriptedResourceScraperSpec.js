(function() {

  req(['scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/Resource'], function(ScriptedResourceScraper, Resource) {
    return describe('ScriptedResourceScraper', function() {
      return it('should work', function() {
        var scraper;
        scraper = new ScriptedResourceScraper(function() {
          return this["try"]({
            hasSky: function() {
              var _this = this;
              setTimeout((function() {
                if (_this.resource.match('as')) {
                  _this.value({
                    status: 'has sky'
                  });
                  return _this.done(true);
                } else {
                  return _this.done(false);
                }
              }), 1000);
              return null;
            },
            noSky: function() {
              this.value({
                status: 'no sky'
              });
              return this.eachSerially({
                color: function() {
                  var color, matches,
                    _this = this;
                  matches = this.resource.match('red|blue');
                  color = matches[0];
                  this.value({
                    color: color
                  });
                  setTimeout((function() {
                    return _this.done(true);
                  }), 1000);
                  return null;
                },
                moonOrPlanet: function() {
                  var matches, moonOrPlanet;
                  matches = this.resource.match('moon|planet');
                  moonOrPlanet = matches[0];
                  return this.value({
                    moonOrPlanet: moonOrPlanet
                  });
                }
              });
            }
          });
        });
        scraper.pushResource(new Resource("The sky is red under the planet"));
        return scraper.scrape(function() {
          return console.log(scraper.value());
        });
      });
    });
  });

}).call(this);
