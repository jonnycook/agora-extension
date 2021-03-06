// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var EbayProductScraper;
  return EbayProductScraper = (function(superClass) {
    extend(EbayProductScraper, superClass);

    function EbayProductScraper() {
      return EbayProductScraper.__super__.constructor.apply(this, arguments);
    }

    EbayProductScraper.testProducts = [];

    EbayProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.ebay.com/itm/-/" + this.productSid;
        }
      }
    };

    EbayProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta\s+property="og:title"\s+content="([^"]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper([[new RegExp(/<span\s+class="notranslate"\s+id="prcIsum"\s+itemprop="price"\s+style="[^"]*">US \$([^<]*)/), 1], [new RegExp(/<span class="notranslate" id="prcIsum_bidPrice" itemprop="price">US \$([^<]*)/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<img id="icImg" class="[^"]*" itemprop="image" src="([^"]*)/), 1)
      }
    };

    return EbayProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=EbayProductScraper.js.map
