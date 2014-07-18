define ['View', 'Site', 'Formatter'], (View, Site, Formatter) ->
	class OffersView extends View
		@nextId: 0
		@id: (args) -> ++ @nextId
		
		initAsync: (args, done) ->
			@resolveObject args, (@product) =>
				product.retrieve 'offers'
				updateOffers = =>
					if product.get('offers')
						productOffers = product.get('offers')
						viewOffers = []
						for condition in ['new', 'used', 'refurbished']
							if productOffers[condition]
								theseOffers = productOffers[condition]
								cheapest = theseOffers[0]
								heading = condition.substr(0, 1).toUpperCase() + condition.substr(1)
								heading += " (#{Formatter.price cheapest.price})"

								o = 
									heading: heading
									offers: []

								for offer,i in theseOffers
									o.offers.push
										id: "#{condition}.#{i}"
										data:offer
										price: Formatter.price offer.price
										site: offer.site
										url: offer.url
										title: offer.title
										image: offer?.images?[0]
										api: offer.api

								viewOffers.push o
						offers.set viewOffers

						updateSelectedOffer()

				updateSelectedOffer = =>
					if product.get('offers') && product.get('offer')
						productOffers = product.get('offers')

						for condition in ['new', 'used', 'refurbished']
							if productOffers[condition]
								theseOffers = productOffers[condition]
								for offer,i in theseOffers
									if offer.url == product.get('offer').url && offer.price == product.get('offer').price
										selectedOffer.set "#{condition}.#{i}"
										return
					selectedOffer.set null

				offers = @clientValue()
				selectedOffer = @clientValue()

				product.field('offers').observe updateOffers
				updateOffers()

				product.field('offer').observe updateSelectedOffer

				
				@data = 
					offers:offers
					selectedOffer:selectedOffer

				done()

		methods:
			setOffer: (view, offer) ->
				@product.set 'offer', site:offer.site, url:offer.url, price:offer.price

