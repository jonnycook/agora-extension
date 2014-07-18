define ['View', 'Site', 'Formatter', 'util'], (View, Site, Formatter, util) ->
	class ReviewsView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId
		
		initAsync: (args, done) ->
			@resolveObject args, (@product) =>
				@data = @clientValue()
				product.interface (productIface) =>
					updateData = =>
						productIface.reviews (data) =>
							reviews = []
							if data
								if data.reviews
									for review in data.reviews
										reviewContent = util.stripHtml review.review ? review.content, []
										if reviewContent.length > 200
											reviewContent = reviewContent.substr(0, 200) + '...'

										reviews.push
											url:if review.url then util.url(review.url) else product.get('url')
											rating:parseInt review.rating
											title:review.title ? ''
											review:reviewContent

							@data.set reviews:reviews, url:(if data.url then util.url(data.url) else product.get('url')), count:data.count

					product.field('reviews').observe updateData
					updateData()

					done()
