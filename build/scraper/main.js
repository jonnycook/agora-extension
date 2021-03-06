// Generated by CoffeeScript 1.10.0
var env, page, webserver;

page = require('webpage').create();

webserver = require('webserver').create();

env = require('./env.phantom');

webserver.listen(3002, function(request, response) {
  var i, len, name, params, part, queryString, queryStringParts, ref, value;
  queryString = request.url.match(/^\/[^?]*(?:\?(.*))?$/)[1];
  queryStringParts = queryString.split('&');
  params = {};
  for (i = 0, len = queryStringParts.length; i < len; i++) {
    part = queryStringParts[i];
    ref = part.split('='), name = ref[0], value = ref[1];
    params[name] = unescape(value);
  }
  console.log(JSON.stringify(params.products));
  page.evaluate((function(cb, products) {
    return scrapeProducts(cb, products);
  }), params.cb, JSON.parse(params.products));
  return response.closeGracefully();
});

page.onConsoleMessage = function(msg) {
  return console.log(msg);
};

page.open(env.page, function(status) {
  return console.log(status);
});

//# sourceMappingURL=main.js.map
