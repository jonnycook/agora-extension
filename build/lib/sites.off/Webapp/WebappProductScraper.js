// Generated by CoffeeScript 1.7.1
define(function() {
  var AgoraProductScraper;
  return AgoraProductScraper = (function() {
    function AgoraProductScraper(site, productSid, background) {
      var properties;
      this.site = site;
      this.productSid = productSid;
      this.background = background;
      properties = this.properties;
      this.properties = {};
      this.product = DevProductScraper.products[this.productSid];
      ['image', 'title', 'price'].forEach((function(_this) {
        return function(name) {
          return _this.properties[name] = {
            scrape: (function(cb) {
              return cb(this.product[name]);
            }),
            productSid: productSid,
            product: _this.product
          };
        };
      })(this));
    }

    AgoraProductScraper.products = {
      SID1: {
        image: 'http://agoraext.dev/resources/dev/519sTkNOmIL._AA300_.jpg',
        title: 'PlayStation 3 This name is really long so that I can see it wrap',
        price: '$199.00'
      },
      SID2: {
        image: 'http://agoraext.dev/resources/dev/416WlFamYGL._AA300_.jpg',
        title: 'PlayStation 3 Controller',
        price: '$199.00'
      },
      SID3: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Metal Gear Solid',
        price: '$199.00'
      },
      SID4: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 4',
        price: '$199.00'
      },
      SID5: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 5',
        price: '$199.00'
      },
      SID6: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 6',
        price: '$199.00'
      },
      SID7: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 7',
        price: '$199.00'
      },
      SID8: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 8',
        price: '$199.00'
      },
      SID9: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 9',
        price: '$199.00'
      },
      SID10: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 10',
        price: '$199.00'
      },
      SID11: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 11',
        price: '$199.00'
      },
      SID12: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 12',
        price: '$199.00'
      },
      SID13: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 13',
        price: '$199.00'
      },
      SID14: {
        image: 'http://agoraext.dev/resources/dev/414SdVNOsuL._SL500_AA300_.jpg',
        title: 'Product 14',
        price: '$199.00'
      }
    };

    return AgoraProductScraper;

  })();
});

//# sourceMappingURL=WebappProductScraper.map
