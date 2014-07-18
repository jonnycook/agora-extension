// Generated by CoffeeScript 1.7.1
({
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasMore: false,
  slug: 'newegg',
  hosts: ['www.newegg.com'],
  currency: 'dollar',
  scraper: true,
  icon: 'http://www.newegg.com/favicon.ico',
  productUrl: function(sid) {},
  query: function(product) {
    var details, model, more, name, section, value, _ref;
    more = product.get('more');
    model = null;
    _ref = more.details;
    for (section in _ref) {
      details = _ref[section];
      for (name in details) {
        value = details[name];
        if (name === 'Model') {
          model = value;
          break;
        }
      }
      if (model) {
        break;
      }
    }
    return {
      sku: product.get('productSid'),
      brand: product.get('more').brand.name,
      model: model
    };
  }
});

//# sourceMappingURL=config.map