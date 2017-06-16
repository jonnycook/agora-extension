// Generated by CoffeeScript 1.10.0
define(function() {
  return function() {
    var AmazonMostRecentReviewsWidget;
    return AmazonMostRecentReviewsWidget = (function() {
      AmazonMostRecentReviewsWidget.prototype.title = 'Most Recent Reviews';

      AmazonMostRecentReviewsWidget.prototype.expands = true;

      function AmazonMostRecentReviewsWidget(data) {
        var i, len, review, reviewEl, reviewI;
        this.el = $('<div />');
        for (reviewI = i = 0, len = data.length; i < len; reviewI = ++i) {
          review = data[reviewI];
          if (reviewI === 3) {
            break;
          }
          reviewEl = $("<div class='recentReview'> <div class='wrapper'> <a href='" + review.url + "' target='_blank' class='title'>" + review.title + "</a> <div class='rating'> <div><div /></div> <div><div /></div> <div><div /></div> <div><div /></div> <div><div /></div> </div> <div class='author'>" + review.author + "</div> </div> <!--<div class='review'>" + review.review + "</div>--> </div>");
          util2.setRating(reviewEl.find('.rating'), review.rating);
          this.el.append(reviewEl);
        }
      }

      AmazonMostRecentReviewsWidget.prototype.init = function() {};

      return AmazonMostRecentReviewsWidget;

    })();
  };
});

//# sourceMappingURL=AmazonMostRecentReviewsWidget.js.map
