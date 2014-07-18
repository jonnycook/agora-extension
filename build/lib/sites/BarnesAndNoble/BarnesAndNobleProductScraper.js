// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var BarnesAndNobleProductScraper;
  return BarnesAndNobleProductScraper = (function(_super) {
    __extends(BarnesAndNobleProductScraper, _super);

    function BarnesAndNobleProductScraper() {
      return BarnesAndNobleProductScraper.__super__.constructor.apply(this, arguments);
    }

    BarnesAndNobleProductScraper.testProducts = ['1113003734'];

    BarnesAndNobleProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.barnesandnoble.com/w/-/" + this.productSid;
        }
      }
    };

    BarnesAndNobleProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:title" content="([^"]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper([[new RegExp(/<div class="[^"]*" itemprop="price" data-bntrack="[^"]*" data-bntrack-event="[^"]*">\$([^<]*)/), 1], [new RegExp(/<span class="bb-price">\s*\$(\S*)/), 1], [new RegExp(/<span class="mp-from">from<\/span>\s*\$(\S*)/), 1], [new RegExp(/<em class="bb-title-format">NOOK Book<\/em> <span class="bb-title-info">\(eBook\)<\/span>\s*<\/div>\s*<div class="bb-pricing pricing-break-early" itemprop="offers" itemscope itemtype="http:\/\/schema.org\/Offer">\s*<div class="[^"]*" itemprop="price" data-bntrack="[^"]*" data-bntrack-event="[^"]*">\$([^<]*)/), 1]])
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:image" content="([^"]*)/), 1)
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var author, authorMatches, authorNames, bio, bioMatch, bioMatches, content, count, detailMatches, details, editorialReviews, erMatches, from, image, imageMatch, imageMatches, images, isbn, item, match, matches, name, overviewMatches, specifications, switches, title, url, value, _i, _j, _k, _l, _len, _len1, _len2, _len3;
          switches = {
            images: true,
            overview: true,
            details: true,
            isbn: true,
            author: true,
            rating: true,
            ratingCount: true,
            editorialReviews: true,
            originalPrice: true,
            shipping: false
          };
          value = {};
          if (switches.overview) {
            matches = this.resource.match(/<div id="product-commentary-overview-2"([\S\s]*?)<\/section>/);
            overviewMatches = matches[1].match(/<div class="simple-html"([\S\s]*?)<\/div>/);
            value.overview = overviewMatches[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
          }
          if (switches.details) {
            details = {};
            matches = this.resource.match(/<div class="product-details([\S\s]*?)<\/section>/);
            detailMatches = matches[1].match(/<li([\S\s]*?)<\/li>/g);
            for (_i = 0, _len = detailMatches.length; _i < _len; _i++) {
              match = detailMatches[_i];
              title = match.match(/<span>([\S\s]*?)<\/span>/)[1];
              title = title.match(/([^:]*)/)[1];
              content = match.match(/<\/span>([\S\s]*?)<\/li>/)[1];
              details[title] = content.replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
            }
            value.details = details;
          }
          if (switches.isbn) {
            matches = this.resource.match(/<div class="product-details([\S\s]*?)<\/section>/);
            isbn = matches[1].match(/<span>ISBN-13:<\/span>([\S\s]*?)<\/li>/);
            value.isbn = isbn[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
          }
          if (switches.author) {
            author = {};
            authorNames = {};
            matches = this.resource.match(/<ul class="contributors([\S\s]*?)<\/ul>/);
            authorMatches = matches[1].match(/<li([\S\s]*?)<\/li>/g);
            count = 0;
            for (_j = 0, _len1 = authorMatches.length; _j < _len1; _j++) {
              item = authorMatches[_j];
              if (count > 0) {
                name = item.match(/<li([\S\s]*?)<\/li>/)[1];
                name = name.match(/<a([\S\s]*?)<\/a>/)[1];
                name = name.match(/>([\S\s]*)/)[1];
                url = item.match(/<li([\S\s]*?)<\/li>/)[1];
                authorNames[name] = url.replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
              }
              count++;
            }
            author["names"] = authorNames;
            bioMatch = this.resource.match(/<div class="basic-info([\S\s]*?)<\/section>/);
            if (bioMatch) {
              bioMatches = bioMatch[1].match(/<div class="content([\S\s]*?)<\/div>/);
              bio = bioMatches[1].match(/>([\S\s]+)/);
              author["bio"] = bio[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
            }
            imageMatch = this.resource.match(/<div id="product-commentary-meet-the-author-1"([\S\s]*?)<\/section>/);
            if (imageMatch) {
              image = imageMatch[1].match(/src="([^"]+)/);
              if (image) {
                author["authorImage"] = image[1];
              }
            }
            value.author = author;
          }
          if (switches.rating) {
            matches = this.resource.match(/"customerAvgStarRating" : ([\S\s]*?),/);
            if (matches) {
              value.rating = matches[1];
            }
          }
          if (switches.reviewCount) {
            matches = this.resource.match(/"customerRatingCount" : ([\S\s]*?),/);
            if (matches) {
              value.reviewCount = matches[1];
            }
          }
          if (switches.editorialReviews) {
            matches = this.resource.match(/<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/);
            if (matches) {
              editorialReviews = {};
              erMatches = matches[1].match(/<article class="simple-html">([\S\s]*?)<\/article>/g);
              for (_k = 0, _len2 = erMatches.length; _k < _len2; _k++) {
                match = erMatches[_k];
                from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1];
                content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
                editorialReviews[from] = content;
              }
              value.editorialReviews = editorialReviews;
            }
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/"listPrice" : ([\S\s]*?),/);
            if (matches) {
              value.originalPrice = matches[1];
            }
          }
          if (switches.images) {
            images = [];
            matches = this.resource.match(/id="viewer-image-1"([\S\s]*?)<\/li>/);
            imageMatches = matches[1].match(/data-bn-src-url="([^"]+)/g);
            for (_l = 0, _len3 = imageMatches.length; _l < _len3; _l++) {
              match = imageMatches[_l];
              image = match.match(/data-bn-src-url="([^"]+)/);
              images.push(image[1]);
            }
            value.images = images;
          }
          if (switches.specifications) {
            specifications = {};
            this.execBlock(function() {
              this.getResource('specificationsTab', function(resource) {
                var desc, specMatches, _len4, _m;
                matches = resource.safeMatch(/<tbody>([\S\s]*?)<\/tbody>/);
                specMatches = matches[1].match(/<tr>([\S\s]*?)<\/tr>/g);
                for (_m = 0, _len4 = specMatches.length; _m < _len4; _m++) {
                  match = specMatches[_m];
                  name = match.match(/<th[^>]*>([\S\s]*?)<\/th>/)[1];
                  details = match.match(/<td>([\S\s]*?)<\/td>/)[1];
                  desc = match.match(/<td>([\S\s]*?)<\/td>/g)[1];
                  desc = desc.match(/<td>([\S\s]*?)<\/td>/)[1];
                  specifications[name] = {
                    details: details,
                    desc: desc
                  };
                }
                value.specifications = specifications;
                this.value(value);
                return this.done(true);
              });
              return null;
            });
          }
          return this.value(value);
        })
      }
    };

    return BarnesAndNobleProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=BarnesAndNobleProductScraper.map
