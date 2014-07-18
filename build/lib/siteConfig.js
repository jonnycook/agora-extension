define({Amazon: {
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
},AmericanApparel: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'americanapparel',
  hosts: ['store.americanapparel.net'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://i.americanapparel.net/static/atg/1.22.0/media/favicons/favicon_blue.ico',
  twoTap: true
},Asos: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'asos',
  hosts: ['us.asos.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.asos.com/favicon.ico',
  twoTap: true
},BarnesAndNoble: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'barnesandnoble',
  hosts: ['www.barnesandnoble.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.barnesandnoble.com/favicon.ico'
},BestBuy: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'bestbuy',
  hosts: ['www.bestbuy.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.bestbuy.com/favicon.ico'
},Bloomingdales: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'bloomingdales',
  hosts: ['www1.bloomingdales.com', 'www.bloomingdales.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.bloomingdales.com/favicon.ico',
  twoTap: true
},ColdwaterCreek: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'coldwatercreek',
  hosts: ['www.coldwatercreek.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.coldwatercreek.com/favicon.ico'
},Costco: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'costco',
  hosts: ['www.costco.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.costco.com/favicon.ico'
},Dev: {
  hasProductClass: true,
  hosts: ['agoraext.local', 'baggg.it', 'agora.local', 'ext.agora.dev'],
  productUrl: function(sid) {
    return "#" + sid;
  }
},Diapers: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'diapers',
  hosts: ['www.diapers.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.diapers.com/favicon.ico'
},Ebay: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'ebay',
  hosts: ['www.ebay.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.ebay.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},Etsy: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'etsy',
  hosts: ['www.etsy.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.etsy.com/favicon.ico',
  productUrl: function(sid) {
    return "http://www.etsy.com/listing/" + sid;
  }
},Express: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'express',
  hosts: ['www.express.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.express.com/favicon.ico'
},Fab: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'fab',
  hosts: ['fab.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://fab.com/favicon.ico'
},Fancy: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'fancy',
  hosts: ['fancy.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://fancy.com/favicon.ico'
},FashionBug: {
  excludedFeatures: ['offers', 'deals', 'reviews'],
  hasProductClass: false,
  slug: 'fashionbug',
  hosts: ['www.fashionbug.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.fashionbug.com/favicon.ico'
},Forever21: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'forever21',
  hosts: ['www.forever21.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.foreve21.com/favicon.ico',
  twoTap: true
},FreePeople: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'freepeople',
  hosts: ['www.freepeople.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.freepeople.com/favicon.ico',
  twoTap: true
},Gap: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'gap',
  hosts: ['www.gap.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.gap.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},General: {
  slug: 'general',
  currency: 'embedded',
  scraper: true,
  enabled: 'check',
  offersPane: false
},HM: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'hm',
  hosts: ['www.hm.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.hm.com/favicon.ico'
},HomeDepot: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'homedepot',
  hosts: ['www.homedepot.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.homedepot.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},JCPenney: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'jcpenney',
  hosts: ['www.jcpenney.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.jcpenney.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},JCrew: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'jcrew',
  hosts: ['www.jcrew.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.jcrew.com/favicon.ico',
  twoTap: true
},KateSpade: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'katespade',
  hosts: ['www.katespade.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.katespade.com/favicon.ico',
  twoTap: true
},Kmart: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'kmart',
  hosts: ['www.kmart.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.kmart.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},Kohls: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'kohls',
  hosts: ['www.kohls.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.kohls.com/favicon.ico'
},LLBean: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'llbean',
  hosts: ['www.llbean.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.llbean.com/favicon.ico'
},LandsEnd: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'landsend',
  hosts: ['www.landsend.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.landsend.com/favicon.ico'
},LuLus: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'lulus',
  hosts: ['www.lulus.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://cdn.lulus.com/images/icons/favicon.ico',
  twoTap: true
},Macys: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'macys',
  hosts: ['www.macys.com', 'www1.macys.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.macys.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},MakeMeChic: {
  excludedFeatures: ['offers', 'deals', 'reviews'],
  hasProductClass: true,
  slug: 'makemechic',
  hosts: ['www.makemechic.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.makemechic.com/favicon.ico'
},ModCloth: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'modcloth',
  hosts: ['www.modcloth.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.modcloth.com/favicon.ico',
  twoTap: true
},NastyGal: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'nastygal',
  hosts: ['www.nastygal.com', 'nastygal.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://assets.nastygal.com/assets/current/images/favicon/favicon-32.png',
  twoTap: true
},Newegg: {
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
},Nordstrom: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'nordstrom',
  hosts: ['shop.nordstrom.com', 'www.nordstrom.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.nordstrom.com/favicon.ico',
  twoTap: true
},Overstock: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'overstock',
  hosts: ['www.overstock.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.overstock.com/favicon.ico',
  productUrl: function(sid) {
    return "";
  }
},QVC: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'qvc',
  hosts: ['www.qvc.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.qvc.com/favicon.ico'
},Rakuten: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'rakuten',
  hosts: ['www.rakuten.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.rakuten.com/favicon.ico'
},Rei: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'rei',
  hosts: ['www.rei.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.rei.com/favicon.ico'
},RentTheRunway: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'renttherunway',
  hosts: ['www.renttherunway.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.renttherunway.com/favicon.ico'
},SamsClub: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'samsclub',
  hosts: ['www.samsclub.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.samsclub.com/favicon.ico'
},Sears: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'sears',
  hosts: ['www.sears.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.sears.com/favicon.ico',
  productUrl: function(sid) {
    return "http://www.sears.com/-/p-" + sid;
  }
},Singer22: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'singer22',
  hosts: ['www.singer22.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.singer22.com/favicon.ico'
},SixPM: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: '6pm',
  hosts: ['www.6pm.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.6pm.com/favicon.ico'
},Soap: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'soap',
  hosts: ['www.soap.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.soap.com/favicon.ico'
},Target: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: false,
  slug: 'target',
  hosts: ['www.target.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.target.com/favicon.ico',
  productUrl: function(sid) {
    return "http://www.sears.com/-/p-" + sid;
  }
},TheLimited: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'thelimited',
  hosts: ['www.thelimited.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.thelimited.com/favicon.ico',
  twoTap: true
},ToysRUs: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'toysrus',
  hosts: ['www.toysrus.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.toysrus.com/favicon.ico'
},Tutorial: {
  hosts: ['tutorial.agora']
},Uniqlo: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'uniqlo',
  hosts: ['www.uniqlo.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.uniqlo.com/favicon.ico'
},VictoriasSecret: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'victoriassecret',
  hosts: ['www.victoriassecret.com', 'sp10048b28.guided.ss-omtrdc.net'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.victoriassecret.com/favicon.ico'
},Walgreens: {
  excludedFeatures: ['offers', 'deals', 'reviews', 'rating'],
  hasProductClass: true,
  slug: 'walgreens',
  hosts: ['www.walgreens.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.walgreens.com/favicon.ico'
},Webapp: {
  hosts: ['webapp.agora', 'webapp.agora.dev', 'agora.sh/view/'],
  productUrl: function(sid) {
    return "#" + sid;
  }
},WetSeal: {
  excludedFeatures: ['offers', 'deals'],
  hasProductClass: true,
  slug: 'wetseal',
  hosts: ['www.wetseal.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.wetseal.com/favicon.ico',
  twoTap: true
},WomanWithin: {
  excludedFeatures: ['offers', 'deals', 'priceWatch'],
  hasProductClass: true,
  slug: 'womanwithin',
  hosts: ['www.womanwithin.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: false,
  icon: 'http://www.womanwithin.com/favicon.ico'
},Zappos: {
  excludedFeatures: ['deals', 'offers'],
  hasProductClass: true,
  slug: 'zappos',
  hosts: ['www.zappos.com'],
  currency: 'dollar',
  scraper: true,
  hasMore: true,
  icon: 'http://www.zappos.com/favicon.ico',
  productUrl: function(sid) {
    var colorId, productId, _ref;
    _ref = sid.split('-'), productId = _ref[0], colorId = _ref[1];
    if (colorId) {
      return "http://www.zappos.com/viewProduct.do?productId=" + productId + "&colorId=" + colorId;
    } else {
      return "http://www.zappos.com/viewProduct.do?productId=" + productId;
    }
  },
  query: function(product) {
    return {
      brand: product.get('more').brand.name,
      title: product.get('more').name
    };
  }
}});