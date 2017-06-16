// Generated by CoffeeScript 1.10.0
({
  hasProductClass: true,
  slug: 'amazon',
  hosts: ['www.amazon.com'],
  scraper: true,
  currency: 'dollar',
  icon: 'http://www.amazon.com/favicon.ico',
  productUrl: function(sid) {
    return "http://www.amazon.com/gp/product/" + sid;
  },
  query: function(product) {
    return {
      sku: product.get('productSid')
    };
  }
});

//# sourceMappingURL=config.js.map
