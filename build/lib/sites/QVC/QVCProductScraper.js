// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var QVCProductScraper;
  return QVCProductScraper = (function(superClass) {
    extend(QVCProductScraper, superClass);

    function QVCProductScraper() {
      return QVCProductScraper.__super__.constructor.apply(this, arguments);
    }

    QVCProductScraper.testProducts = ['E249454'];

    QVCProductScraper.prototype.parseSid = function(sid) {
      var color, id, ref;
      ref = sid.split('-'), id = ref[0], color = ref[1];
      return {
        id: id,
        color: color
      };
    };

    QVCProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          var url;
          url = "http://www.qvc.com/.product." + this.productSid.id + ".html";
          if (this.productSid.color) {
            url += "?itemId=" + this.productSid.color;
          }
          return url;
        }
      }
    };

    QVCProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:title" content="([^"]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper([[new RegExp(/<p id="parProductDetailPrice">\$([\S\s]*?)<\/p>/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var matches, shortId, url;
          matches = this.resource.match(/var arrSizeValues = new Array([\S\s]*?)<\/script>/);
          shortId = matches[1].match(new RegExp(this.productSid.color + ":[^:]*:[^:]*:([^:]*)", 'i'))[1].toLowerCase();
          url = "http://images.qvc.com/is/image/" + this.resource.match(/<meta property="og:image" content="http:\/\/images.qvc.com\/is\/image\/([^\.]*)/)[1] + "_" + shortId + ".102?$uslarge$";
          return this.value(url);
        })
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var colorMatches, colorPics, i, id, imageMatches, images, j, k, len, len1, len2, match, matches, pic, pics, switches, value;
          switches = {
            images: true,
            description: false,
            rating: false,
            ratingCount: false,
            originalPrice: false,
            colors: true,
            shipping: false
          };
          value = {};
          if (switches.colors) {
            matches = this.resource.match(/var arrSizeValues = new Array([\S\s]*?)<\/script>/);
            colorMatches = this.matchAll(matches[1], /arrSizeValues\[.*?\]\[.*?\]="(.*?)"/, 1);
            value.colors = [];
            for (i = 0, len = colorMatches.length; i < len; i++) {
              match = colorMatches[i];
              matches = match.match(/^([^:]*):[^:]*:[^:]*:([^:]*):[^:]*:([^:]*)$/);
              value.colors.push({
                longId: matches[1],
                shortId: matches[2],
                name: matches[3]
              });
            }
          }
          if (switches.description) {
            matches = this.resource.match(/<div id="divProductDetailDescriptionAreaDisplay1"([\S\s]*?)<div id="divProductDetailDescriptionAreaDisplay2"/);
            value.description = "<div" + matches[1];
          }
          if (switches.rating) {
            matches = this.resource.match(/var avgRating = '([^']*)/);
            if (matches) {
              value.rating = matches[1];
            }
          }
          if (switches.reviewCount) {
            matches = this.resource.match(/var productReviews = '([^']*)/);
            if (matches) {
              value.reviewCount = matches[1];
            }
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/<span class="spanStrike">\$([\S\s]*?)<\/span>/);
            if (matches) {
              value.originalPrice = matches[1];
            } else {
              matches = this.resource.match(/product_price:\['([^']*)/);
              if (matches) {
                value.originalPrice = matches[1];
              }
            }
          }
          if (switches.images) {
            images = {};
            colorMatches = this.resource.match(/colorImages\[[^\]]*\] = "([^"]*)/g);
            if (colorMatches) {
              colorPics = {};
              for (j = 0, len1 = colorMatches.length; j < len1; j++) {
                match = colorMatches[j];
                pic = match.match(/colorImages\[[^\]]*\] = "([^"]*)/);
                id = match.match(new RegExp(this.productSid.id + "_([^\.]*)", 'i'));
                colorPics[id[1]] = pic[1];
              }
              images["colorPics"] = colorPics;
            }
            imageMatches = this.resource.match(/viewImages\[[^\]]*\] = "([^"]*)/g);
            if (imageMatches) {
              pics = [];
              for (k = 0, len2 = imageMatches.length; k < len2; k++) {
                match = imageMatches[k];
                pic = match.match(/viewImages\[[^\]]*\] = "([^"]*)/);
                pics.push(pic[1]);
              }
              images["pics"] = pics;
            }
            value.images = images;
          }
          return this.value(value);
        })
      }
    };

    return QVCProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=QVCProductScraper.js.map
