// Generated by CoffeeScript 1.10.0
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
    var details, model, more, name, ref, section, value;
    more = product.get('more');
    model = null;
    ref = more.details;
    for (section in ref) {
      details = ref[section];
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

//# sourceMappingURL=config.js.map
