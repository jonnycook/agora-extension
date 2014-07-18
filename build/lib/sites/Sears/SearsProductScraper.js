// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['scraping/ProductScraper', 'scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/ScriptedResourceScraper', 'scraping/resourceScrapers/JsonResourceScraper', 'underscore'], function(ProductScraper, PatternResourceScraper, ScriptedResourceScraper, JsonResourceScraper, _) {
  var SearsProductScraper;
  return SearsProductScraper = (function(_super) {
    __extends(SearsProductScraper, _super);

    function SearsProductScraper() {
      return SearsProductScraper.__super__.constructor.apply(this, arguments);
    }

    SearsProductScraper.testProducts = [];

    SearsProductScraper.prototype.resources = {
      productPage: {
        url: function() {
          return "http://www.sears.com/-/p-" + this.productSid;
        }
      },
      productData: {
        type: 'json',
        url: function() {
          return "http://www.sears.com/content/pdp/config/products/v1/products/" + this.productSid + "?site=sears";
        }
      },
      priceData: {
        type: 'json',
        url: function() {
          var number;
          number = this.productSid.value;
          if (number[number.length - 1] === 'P') {
            number = number.substr(0, number.length - 1);
          }
          return "http://www.sears.com/content/pdp/products/pricing/" + number + "?variation=0&regionCode=0";
        }
      }
    };

    SearsProductScraper.prototype.properties = {
      title: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          if (data.data.product.brand) {
            return data.data.product.brand.name + " " + data.data.product.name;
          } else {
            return data.data.product.name;
          }
        })
      },
      price: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var number, price, priceUrl;
          price = '';
          number = this.productSid.value;
          console.debug('asdf');
          console.debug(number);
          if (number[number.length - 1] === 'P') {
            number = number.substr(0, number.length - 1);
          }
          priceUrl = "http://www.sears.com/content/pdp/products/pricing/" + number + "?variation=0&regionCode=0";
          this.execBlock(function() {
            this.get(priceUrl, function(response) {
              var altPriceUrl, originalPrice;
              console.debug(response);
              originalPrice = JSON.parse(response);
              if (originalPrice['price-response']['item-response']['sell-price']['$']) {
                if (originalPrice['price-response']['item-response']['sell-price']['$'] !== "0.00") {
                  price = originalPrice['price-response']['item-response']['sell-price']['$'];
                } else {
                  altPriceUrl = "http://www.sears.com/shc/s/ItemSavestoryAjax?storeId=10153&prdType=VARIATION&prdBeanType=ProductBean&ajaxFlow=true&partNumber=" + number + "P";
                  this.execBlock(function() {
                    this.get(altPriceUrl, function(response) {
                      originalPrice = response.match(/"prodDispPrice":"([^,]+|[^"]+)/);
                      if (originalPrice) {
                        price = originalPrice[1];
                      }
                      this.value(price);
                      return this.done(true);
                    });
                    return null;
                  });
                }
              }
              this.value(price);
              return this.done(true);
            });
            return null;
          });
          return this.value(price);
        })
      },
      image: {
        resource: 'productData',
        scraper: JsonResourceScraper(function(data) {
          if (data.data.product.assets.imgs[0].vals[0].src.indexOf('?') === -1) {
            return "" + data.data.product.assets.imgs[0].vals[0].src + "?hei=623&wid=623&qlt=50,0&op_sharpen=1&op_usm=0.9,0.5,0,0";
          } else {
            return data.data.product.assets.imgs[0].vals[0].src;
          }
        })
      },
      rating: {
        resource: 'productData',
        scraper: ScriptedResourceScraper(function() {
          var ratUrl, rating;
          rating = '';
          ratUrl = "http://www.sears.com/content/pdp/ratings/single/search/Sears/" + this.productSid + "&targetType=product&limit=1&offset=0";
          this.execBlock(function() {
            this.get(ratUrl, function(response) {
              rating = JSON.parse(response);
              if (rating['data']['overall_rating']) {
                rating = rating['data']['overall_rating'];
              }
              this.value(rating);
              return this.done(true);
            });
            return null;
          });
          return this.value(rating);
        })
      },
      ratingCount: {
        resource: 'productData',
        scraper: ScriptedResourceScraper(function() {
          var ratUrl, ratingCount;
          ratingCount = '';
          ratUrl = "http://www.sears.com/content/pdp/ratings/single/search/Sears/" + this.productSid + "&targetType=product&limit=1&offset=0";
          this.execBlock(function() {
            this.get(ratUrl, function(response) {
              ratingCount = JSON.parse(response);
              if (ratingCount['data']['review_count']) {
                ratingCount = ratingCount['data']['review_count'];
              }
              this.value(ratingCount);
              return this.done(true);
            });
            return null;
          });
          return this.value(ratingCount);
        })
      },
      reviews: {
        resource: 'productData',
        scraper: ScriptedResourceScraper(function() {
          var ratUrl, revs;
          ratUrl = "http://www.sears.com/content/pdp/ratings/single/search/Sears/" + this.productSid + "&targetType=product&limit=10000&offset=0";
          revs = [];
          this.execBlock(function() {
            this.get(ratUrl, function(response) {
              var author, entry, rat, revHash, reviews, _i, _j, _len, _len1, _ref, _ref1;
              reviews = JSON.parse(response);
              if (reviews['data']['reviews']) {
                _ref = reviews['data']['reviews'];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  entry = _ref[_i];
                  revHash = {};
                  author = {};
                  author["name"] = entry['author']['screenName'];
                  author["url"] = "http://www.sears.com/shc/s/PublicProfileView?requestType=public_profile&langId=-1&storeId=10153&key=" + entry['author']['extUserId'];
                  revHash["author"] = author;
                  revHash["searsVerifiedPurchase"] = entry['author']['isBuyer'];
                  revHash["title"] = entry['summary'];
                  revHash["review"] = entry['content'];
                  if (entry['attribute_rating']) {
                    _ref1 = entry['attribute_rating'];
                    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                      rat = _ref1[_j];
                      if (rat['attribute'] === "overall_rating" && rat['attribute_type'] === "numeric") {
                        revHash["rating"] = rat['value'];
                      }
                    }
                  }
                  revHash["time"] = entry['published_date'];
                  revs.push(revHash);
                }
              }
              this.value(revs);
              return this.done(true);
            });
            return null;
          });
          return this.value(revs);
        })
      },
      more: {
        resource: 'productPage',
        scraper: ScriptedResourceScraper(function() {
          var alternate, colors, descUrl, description, images, imgUrl, number, priceUrl, specs, switches, value;
          switches = {
            images: true,
            description: true,
            specifications: true,
            originalPrice: true,
            shipping: false
          };
          value = {};
          if (switches.images) {
            images = {};
            colors = {};
            alternate = [];
            imgUrl = "http://www.sears.com/content/pdp/config/products/v1/products/" + this.productSid + "?site=sears";
            this.execBlock(function() {
              this.get(imgUrl, function(response) {
                var address, addy, entry, imagesJSON, pocket, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3, _ref4;
                imagesJSON = JSON.parse(response);
                _ref = imagesJSON['data']['product']['assets']['imgs'];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  pocket = _ref[_i];
                  if (pocket['type'] === 'P') {
                    _ref1 = pocket['vals'];
                    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                      entry = _ref1[_j];
                      alternate.push(entry['src']);
                    }
                  } else if (pocket['type'] === 'A') {
                    _ref2 = pocket['vals'];
                    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                      entry = _ref2[_k];
                      alternate.push(entry['src']);
                    }
                  }
                }
                images["alternate"] = alternate;
                if (imagesJSON['data']['attributes']) {
                  if (imagesJSON['data']['attributes']['attributes']) {
                    _ref3 = imagesJSON['data']['attributes']['attributes'];
                    for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
                      address = _ref3[_l];
                      if ((address['name'] === "Color") || (address['name'] === "Color Family")) {
                        _ref4 = address['values'];
                        for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
                          addy = _ref4[_m];
                          colors[addy['name']] = addy['primaryImage']['src'];
                        }
                      }
                    }
                    images["colors"] = colors;
                  }
                }
                value.images = images;
                this.done(true);
                return this.value(value);
              });
              return null;
            });
          }
          if (switches.description) {
            descUrl = "http://www.sears.com/content/pdp/config/products/v1/products/" + this.productSid + "?site=sears";
            description = null;
            this.execBlock(function() {
              this.get(descUrl, function(response) {
                description = JSON.parse(response);
                if (description['data']['product']['desc'][0]['type'] === 'S') {
                  if (description['data']['product']['desc'][1]) {
                    value.description = description['data']['product']['desc'][0]['val'] + description['data']['product']['desc'][1]['val'];
                  } else {
                    value.description = description['data']['product']['desc'][0]['val'];
                  }
                } else if (description['data']['product']['seo']['desc']) {
                  value.description = description['data']['product']['seo']['desc'];
                }
                this.done(true);
                return this.value(value);
              });
              return null;
            });
          }
          if (switches.specifications) {
            descUrl = "http://www.sears.com/content/pdp/config/products/v1/products/" + this.productSid + "?site=sears";
            specs = {};
            this.execBlock(function() {
              this.get(descUrl, function(response) {
                var entry, specHash, specifications, thing, _i, _j, _len, _len1, _ref, _ref1;
                specifications = JSON.parse(response);
                if (specifications['data']['product']['specs']) {
                  _ref = specifications['data']['product']['specs'];
                  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                    entry = _ref[_i];
                    specHash = {};
                    _ref1 = entry['attrs'];
                    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                      thing = _ref1[_j];
                      specHash[thing['name']] = thing['val'];
                    }
                    specs[entry['grpName']] = specHash;
                  }
                  value.specifications = specs;
                }
                this.done(true);
                return this.value(value);
              });
              return null;
            });
          }
          if (switches.originalPrice) {
            number = this.productSid.value;
            if (number[number.length - 1] === 'P') {
              number = number.substr(0, number.length - 1);
            }
            priceUrl = "http://www.sears.com/content/pdp/products/pricing/" + number + "?variation=0&regionCode=0";
            this.execBlock(function() {
              this.get(priceUrl, function(response) {
                var altPriceUrl, originalPrice;
                originalPrice = JSON.parse(response);
                if (originalPrice['price-response']['item-response']['regular-price']) {
                  if (originalPrice['price-response']['item-response']['regular-price'] !== "0.00") {
                    value.originalPrice = originalPrice['price-response']['item-response']['regular-price'];
                  } else {
                    altPriceUrl = "http://www.sears.com/shc/s/ItemSavestoryAjax?storeId=10153&prdType=VARIATION&prdBeanType=ProductBean&ajaxFlow=true&partNumber=" + number + "P";
                    this.execBlock(function() {
                      this.get(altPriceUrl, function(response) {
                        originalPrice = response.match(/"prodRegPrice":([^,]+|[^"]+)/);
                        if (originalPrice) {
                          value.originalPrice = originalPrice[1];
                        }
                        this.done(true);
                        return this.value(value);
                      });
                      return null;
                    });
                  }
                }
                this.done(true);
                return this.value(value);
              });
              return null;
            });
          }
          return this.value(value);
        })
      }
    };

    return SearsProductScraper;

  })(ProductScraper);
});

//# sourceMappingURL=SearsProductScraper.map