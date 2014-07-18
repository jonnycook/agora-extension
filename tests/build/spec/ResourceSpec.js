(function() {

  req(['scraping/Resource'], function(Resource) {
    return describe('Resource', function() {
      return it('should work', function() {
        var resource;
        resource = new Resource("test");
        expect(resource).toLookLike('test');
        expect(resource.safeMatch('test')).toBeTruthy;
        expect(function() {
          return resource.safeMatch('poop');
        }).toThrow('poop not found');
        return expect(resource.substr(0, 1)).toLookLike('t');
      });
    });
  });

}).call(this);
