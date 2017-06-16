// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var HomeDepotProductScraper;
  return HomeDepotProductScraper = (function(superClass) {
    extend(HomeDepotProductScraper, superClass);

    function HomeDepotProductScraper() {
      return HomeDepotProductScraper.__super__.constructor.apply(this, arguments);
    }

    HomeDepotProductScraper.testProducts = ['204617362'];

    HomeDepotProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.homedepot.com/p/" + this.productSid;
        }
      }
    };

    HomeDepotProductScraper.prototype.properties = {
      title: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:title" content="([^"]*)/), 1)
      },
      price: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<span id="ajaxPrice" class="pReg" itemprop="price">\s*\$([^<]*)/), 1)
      },
      image: {
        resource: 'productPage',
        scraper: PatternResourceScraper(new RegExp(/<meta property="og:image" content="([^"]*)/), 1)
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var alt, author, authorBio, authorMatches, authorNames, bioMatch, bioMatches, content, count, detailMatches, details, editorialReviews, erMatches, feature, features, from, full, i, image, imageMatches, images, isbn, item, j, k, l, len, len1, len2, len3, len4, len5, len6, len7, m, match, matches, n, name, o, overview, overviewMatches, p, par, specMatches, specs, switches, text, title, value;
          switches = {
            images: true,
            overview: true,
            specifications: true,
            rating: true,
            ratingCount: true,
            originalPrice: true,
            shipping: false
          };
          value = {};
          if (switches.overview) {
            overview = [];
            matches = this.resource.match(/<div class="main_description([\S\s]*?)<\/div>/);
            overviewMatches = matches[1].match(/<p[^>]+>([\S\s]*?)<\/p>/g);
            for (i = 0, len = overviewMatches.length; i < len; i++) {
              match = overviewMatches[i];
              text = match.match(/<p[^>]+>([\S\s]*?)<\/p>/);
              overview.push(text[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " "));
            }
            features = [];
            specMatches = matches[1].match(/<li>([\S\s]*?)<\/li>/g);
            if (specMatches) {
              for (j = 0, len1 = specMatches.length; j < len1; j++) {
                match = specMatches[j];
                feature = match.match(/<li>([\S\s]*?)<\/li>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
                features.push(feature);
              }
              overview.push(features);
            }
            value.overview = overview;
          }
          if (switches.specifications) {
            matches = this.resource.match(/<div id="specifications"([\S\s]*?)<\/table>/);
            specs = {};
            specMatches = matches[1].match(/<tr([\S\s]*?)<\/tr>|<tr([\S\s]*?)<\/tbody>/g);
            for (k = 0, len2 = specMatches.length; k < len2; k++) {
              match = specMatches[k];
              full = match.match(/<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>/);
              if (full) {
                title = match.match(/<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm, '');
                content = match.match(/<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm, '');
                specs[title] = content;
                title = match.match(/<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm, '');
                content = match.match(/<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm, '');
                specs[title] = content;
              } else {
                title = match.match(/<td>([\S\s]*)<\/td>[\s]*<td>[\S\s]*<\/td>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm, '');
                content = match.match(/<td>[\S\s]*<\/td>[\s]*<td>([\S\s]*)<\/td>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ").replace(/^&nbsp;+|&nbsp;+$/gm, '');
                specs[title] = content;
              }
            }
            value.specifications = specs;
          }
          if (switches.details) {
            details = [];
            matches = this.resource.match(/<div class="product-details([\S\s]*?)<\/section>/);
            detailMatches = matches[1].match(/<li([\S\s]*?)<\/li>/g);
            for (l = 0, len3 = detailMatches.length; l < len3; l++) {
              match = detailMatches[l];
              title = match.match(/<span>([\S\s]*?)<\/span>/)[1];
              content = match.match(/<\/span>([\S\s]*?)<\/li>/)[1];
              text = title + content;
              details.push(text.replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " "));
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
            authorNames = [];
            matches = this.resource.match(/<ul class="contributors([\S\s]*?)<\/ul>/);
            authorMatches = matches[1].match(/<li([\S\s]*?)<\/li>/g);
            count = 0;
            for (m = 0, len4 = authorMatches.length; m < len4; m++) {
              item = authorMatches[m];
              if (count > 0) {
                name = item.match(/<li([\S\s]*?)<\/li>/)[1];
                authorNames.push(name.replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " "));
              }
              count++;
            }
            author["names"] = authorNames;
            authorBio = [];
            bioMatch = this.resource.match(/<div class="basic-info([\S\s]*?)<\/section>/);
            bioMatches = bioMatch[1].match(/<p>([\S\s]*?)<\/p>/g);
            for (n = 0, len5 = bioMatches.length; n < len5; n++) {
              match = bioMatches[n];
              par = match.match(/<p>([\S\s]*?)<\/p>/)[1];
              authorBio.push(par);
            }
            author["bio"] = authorBio;
            value.author = author;
          }
          if (switches.rating) {
            matches = this.resource.match(/<meta itemprop="ratingValue" content="([^"]+)/);
            if (matches) {
              value.rating = matches[1];
            }
          }
          if (switches.reviewCount) {
            matches = this.resource.match(/<meta itemprop="reviewCount" content="([^"]+)/);
            if (matches) {
              value.reviewCount = matches[1];
            }
          }
          if (switches.editorialReviews) {
            editorialReviews = {};
            matches = this.resource.safeMatch(/<h3>Editorial Reviews<\/h3>([\S\s]*?)<\/div>/);
            erMatches = matches[1].match(/<article class="simple-html">([\S\s]*?)<\/article>/g);
            for (o = 0, len6 = erMatches.length; o < len6; o++) {
              match = erMatches[o];
              from = match.match(/<h5>([\S\s]*?)<\/h5>/)[1];
              content = match.match(/<\/h5>([\S\s]*?)<\/article>/)[1].replace(/^\s+|\s+$/gm, '').replace(/\n\r/g, " ");
              editorialReviews[from] = content;
            }
            value.editorialReviews = editorialReviews;
          }
          if (switches.originalPrice) {
            matches = this.resource.match(/<span id="ajaxPriceStrikeThru">[\s]*\$([^<]+)/);
            if (matches) {
              value.originalPrice = matches[1];
            }
          }
          if (switches.images) {
            images = {};
            matches = this.resource.match(/PRODUCT_INLINE_PLAYER_JSON([^<]+)/);
            imageMatches = matches[1].match(/"height":"1000","width":"1000","mediaUrl":"([^\{]+)/g);
            for (p = 0, len7 = imageMatches.length; p < len7; p++) {
              match = imageMatches[p];
              image = match.match(/"height":"1000","width":"1000","mediaUrl":"([^"]+)/)[1];
              alt = match.match(/\}],"([^"]+)/);
              if (alt) {
                images[alt[1]] = image;
              } else {
                images["other"] = image;
              }
            }
            value.images = images;
          }
          return this.value(value);
        })
      }
    };

    return HomeDepotProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=HomeDepotProductScraper.js.map
