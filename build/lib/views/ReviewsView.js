// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['View', 'Site', 'Formatter', 'util'], function(View, Site, Formatter, util) {
  var ReviewsView;
  return ReviewsView = (function(superClass) {
    extend(ReviewsView, superClass);

    function ReviewsView() {
      return ReviewsView.__super__.constructor.apply(this, arguments);
    }

    ReviewsView.nextId = 0;

    ReviewsView.id = function(args) {
      return ++this.nextId;
    };

    ReviewsView.prototype.initAsync = function(args, done) {
      return this.resolveObject(args, (function(_this) {
        return function(product) {
          _this.product = product;
          _this.data = _this.clientValue();
          return _this.product["interface"](function(productIface) {
            var updateData;
            updateData = function() {
              return productIface.reviews(function(data) {
                var i, len, ref, ref1, ref2, review, reviewContent, reviews;
                reviews = [];
                if (data) {
                  if (data.reviews) {
                    ref = data.reviews;
                    for (i = 0, len = ref.length; i < len; i++) {
                      review = ref[i];
                      reviewContent = util.stripHtml((ref1 = review.review) != null ? ref1 : review.content, []);
                      if (reviewContent.length > 200) {
                        reviewContent = reviewContent.substr(0, 200) + '...';
                      }
                      reviews.push({
                        url: review.url ? util.url(review.url) : _this.product.get('url'),
                        rating: parseInt(review.rating),
                        title: (ref2 = review.title) != null ? ref2 : '',
                        review: reviewContent
                      });
                    }
                  }
                  return _this.data.set({
                    reviews: reviews,
                    url: (data.url ? util.url(data.url) : _this.product.get('url')),
                    count: data.count
                  });
                }
              });
            };
            _this.product.field('reviews').observe(updateData);
            updateData();
            return done();
          });
        };
      })(this));
    };

    return ReviewsView;

  })(View);
});

//# sourceMappingURL=ReviewsView.js.map
