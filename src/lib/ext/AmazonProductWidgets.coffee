define ['util'], (util) ->
	(cb) ->
		@product.with 'more', (more) =>
			widgets = []

			if more.description
				tags = ['h1', 'h2', 'h3', 'h4', 'p', 'small', 'b', 'small', 'a', 'br', 'em']
				description = util.stripHtml more.description

				widgets.push
					type:'html'
					data:
						title:'Description'
						content:description

			if more.features && more.features.length
				widgets.push
					type:'AmazonFeatures'
					data:more.features

			if more.sizes && more.sizes.length
				widgets.push
					type:'AmazonSizes'
					data:
						sizes:more.sizes
						howItFits:more.howItFits

			if more.reviews?.mostHelpful?[0]
				review = more?.reviews?.mostHelpful?[0]
				widgets.push
					type:'AmazonMostHelpfulReview'
					data:
						rating:review.rating
						author:review.author
						review:util.stripHtml review.review
						title:review.title
						url:util.url review.url

			if more.reviews?.quotes?.length
				quotes = []
				for quote in more.reviews?.quotes
					quotes.push
						author:quote.author
						quote:util.stripHtml quote.quote
						url:util.url quote.url
				widgets.push
					type:'AmazonQuotes'
					data:quotes



			if more.reviews?.mostRecent?.length
				reviews = []
				for review in more.reviews?.mostRecent
					reviews.push
						rating:review.rating
						title:review.title
						author:review.author
						review:util.stripHtml review.review
						url:util.url review.url
				widgets.push
					type:'AmazonMostRecentReviews'
					data:reviews


			if more.details
				widgets.push
					type:'AmazonDetails'
					data:more.details



			cb widgets
